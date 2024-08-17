local fstar = {
  mappings = {
    n = {
      ['<LocalLeader>.'] = '<Cmd>FStarVerifyToPoint<CR>',
    },
    i = {},
  },
}

--- Setup function to be run in your init.lua (or init.vim).
---@param opts table: Configuration options
function fstar.setup(opts)
  opts = opts or {}

  opts.lsp = opts.lsp or {}
  if opts.lsp.enable ~= false then
    require'fstar.lsp'.enable(opts.lsp)
  end

  opts.progress_bars = opts.progress_bars or {}
  if opts.progress_bars.enable ~= false then
    require'fstar.progress_bars'.enable(opts.progress_bars)
  end

  opts.stderr = opts.stderr or {}
  if opts.stderr.enable ~= false then
    require'fstar.stderr'.enable(opts.stderr or {})
  end

  vim.cmd [[
    command! FStarRestart :lua require'fstar.lsp'.restart()
    command! FStarVerifyToPoint :lua require'fstar.lsp'.verify_to_pos()
    command! FStarLaxVerifyToPoint :lua require'fstar.lsp'.lax_verify_to_pos()
    command! FStarVerifyWholeFile :lua require'fstar.lsp'.verify()
    command! FStarLaxVerifyWholeFile :lua require'fstar.lsp'.lax_verify()
  ]]

  if opts.mappings == true then
    vim.cmd [[
      augroup fstar_nvim_mappings
        autocmd!
        autocmd FileType fstar lua require'fstar'.use_suggested_mappings(true)
      augroup END
    ]]
  end

  -- needed for testing
  fstar.config = opts
end

local function load_mappings(mappings, buffer)
  local opts = { noremap = true }
  for mode, mode_mappings in pairs(mappings) do
    for lhs, rhs in pairs(mode_mappings) do
      if buffer then
        vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
      else
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
      end
    end
  end
end

function fstar.use_suggested_mappings(buffer_local)
  local buffer = buffer_local and 0
  load_mappings(fstar.mappings, buffer)
end

--- Is the current buffer an F* buffer?
---@return boolean
function fstar.is_fstar_buffer()
  local filetype = vim.bo.filetype
  return filetype == 'fstar'
end

return fstar
