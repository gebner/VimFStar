if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = 1

vim.opt.wildignore:append [[*.checked]]
vim.bo.comments = [[s0:(*,mb:\ ,ex:*),://]]
vim.bo.commentstring = [[// %s]]

vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
