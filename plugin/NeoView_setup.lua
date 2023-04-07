if vim.g.loaded_neoview then
  return
end

require('NeoView').setup()

vim.g.loaded_neoview = true
