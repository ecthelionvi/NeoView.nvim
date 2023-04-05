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

local NEOVIEW_DIR = fn.stdpath('cache') .. "/NeoView"
local VIEWS_DIR = NEOVIEW_DIR .. "/views"
local CURSOR_FILE = NEOVIEW_DIR .. "/cursor_data.json"

-- Create NeoView and views directories if they don't exist
fn.mkdir(NEOVIEW_DIR, "p")
fn.mkdir(VIEWS_DIR, "p")

NeoView.setup = function()
  cmd('set viewdir=' .. VIEWS_DIR)

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
end

-- Save-View
function NeoView.save_view()
  cmd('silent! mkview!')
end

-- Restore-View
function NeoView.restore_view()
  cmd('silent! loadview')
  vim.defer_fn(NeoView.restore_cursor_position, 10)
end

-- Save-Cursor-Position
function NeoView.save_cursor_position()
  local file_path_key = fn.expand('%:p')
  local cursor_position = fn.getpos('.')

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

return NeoView
