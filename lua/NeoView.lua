--[[

 /$$   /$$                     /$$    /$$ /$$
| $$$ | $$                    | $$   | $$|__/
| $$$$| $$  /$$$$$$   /$$$$$$ | $$   | $$ /$$  /$$$$$$  /$$  /$$  /$$
| $$ $$ $$ /$$__  $$ /$$__  $$|  $$ / $$/| $$ /$$__  $$| $$ | $$ | $$
| $$  $$$$| $$$$$$$$| $$  \ $$ \  $$ $$/ | $$| $$$$$$$$| $$ | $$ | $$
| $$\  $$$| $$_____/| $$  | $$  \  $$$/  | $$| $$_____/| $$ | $$ | $$
| $$ \  $$|  $$$$$$$|  $$$$$$/   \  $/   | $$|  $$$$$$$|  $$$$$/$$$$/
|__/  \__/ \_______/ \______/     \_/    |__/ \_______/ \_____/\___/

--]]
local NeoView = {}

local fn = vim.fn
local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local user_cmd = vim.api.nvim_create_user_command

local NEOVIEW_DIR = fn.stdpath('cache') .. "/NeoView"
local VIEWS_DIR = NEOVIEW_DIR .. "/views"
local CURSOR_FILE = NEOVIEW_DIR .. "/cursor_data.json"

-- Create NeoView and views directories if they don't exist
fn.mkdir(NEOVIEW_DIR, "p")
fn.mkdir(VIEWS_DIR, "p")

NeoView.setup = function()
  cmd('silent! set viewdir=' .. VIEWS_DIR)

  autocmd({ "BufWinEnter" }, {
    group = augroup("NeoView", { clear = true }),
    callback = function()
      pcall(function() NeoView.restore_view() end)
    end,
  })

  autocmd({ "BufWinLeave" }, {
    group = "NeoView",
    callback = function()
      pcall(function() NeoView.save_view() end)
      pcall(function() NeoView.save_cursor_position() end)
    end,
  })
  -- Clear-NeoView
  user_cmd("ClearNeoView", "lua require('NeoView').clear_neoview()", {})
end

-- Save-View
function NeoView.save_view()
  if NeoView.valid_buffer() then
    cmd('silent! mkview!')
  end
end

-- Restore-View
function NeoView.restore_view()
  if NeoView.valid_buffer() then
    cmd('silent! loadview')
    vim.defer_fn(NeoView.restore_cursor_position, 10)
  end
end

-- Save-Cursor-Position
function NeoView.save_cursor_position()
  local file_path_key = fn.expand('%:p')
  local cursor_position = fn.getpos('.')

  if not NeoView.valid_buffer() then return end

  local cursor_data_all = {}
  if fn.filereadable(CURSOR_FILE) == 1 then
    local file_content = table.concat(fn.readfile(CURSOR_FILE))
    cursor_data_all = fn.json_decode(file_content) or {}
  end

  cursor_data_all[file_path_key] = { cursor = cursor_position }
  local encoded_data = fn.json_encode(cursor_data_all)
  fn.writefile({ encoded_data }, CURSOR_FILE)
end

-- Restore-Cursor-Position
function NeoView.restore_cursor_position()
  if not NeoView.valid_buffer() then return end

  if fn.filereadable(CURSOR_FILE) == 1 then
    local file_content = table.concat(fn.readfile(CURSOR_FILE))
    local cursor_data_all = fn.json_decode(file_content)

    local file_path_key = fn.expand('%:p')
    local cursor_data = cursor_data_all[file_path_key]

    if cursor_data then
      fn.setpos('.', cursor_data.cursor)
    end
  end
end

-- Notify-NeoView
function NeoView.notify_NeoView()
  vim.notify("NeoView Data Cleared")

  -- Clear the message area after 3 seconds (3000 milliseconds)
  vim.defer_fn(function()
    api.nvim_echo({ { '' } }, false, {})
  end, 3000)
end

-- Validate-Buffer
function NeoView.valid_buffer()
  local buftype = vim.bo.buftype
  local disabled = { "help", "nofile", "terminal" }
  if not vim.tbl_contains(disabled, buftype) then return true end
end

-- Clear-NeoView
function NeoView.clear_neoview()
  -- Delete all view files in the views directory
  for _, view_file in ipairs(fn.glob(VIEWS_DIR .. "/*", 0, 1)) do
    fn.delete(view_file)
  end

  -- Delete the cursor file
  if fn.filereadable(CURSOR_FILE) == 1 then
    fn.delete(CURSOR_FILE)
  end
  NeoView.notify_NeoView()
end

return NeoView
