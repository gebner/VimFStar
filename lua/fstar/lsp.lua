local lsp = { handlers = {} }

local bundled_server_url = 'https://github.com/FStarLang/fstar-vscode-assistant/releases/download/v0.12.0/fstar-language-server-0.12.0.js'

local bundled_server_path =
  vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))) .. '/' .. vim.fs.basename(bundled_server_url)

function lsp.download_lsp_server()
  if not vim.uv.fs_stat(bundled_server_path) then
    vim.system({'curl', '-L', bundled_server_url, '-o', bundled_server_path}):wait()
    print('Downloaded ' .. vim.fs.basename(bundled_server_url))
  end
  return path
end

function lsp.enable(opts)
  opts.handlers = vim.tbl_extend('keep', opts.handlers or {}, {
    ['$/fstar/status'] = lsp.handlers.status_handler,
  });
  -- opts.init_options = vim.tbl_extend('keep', opts.init_options or {}, {
  -- })
  require'lspconfig.configs'['fstar'] = {
    default_config = {
      cmd = { 'node', bundled_server_path, '--stdio' },
      filetypes = { 'fstar' },
      root_dir = function(startpath)
        if opts.auto_download ~= false then
          lsp.download_lsp_server()
        end
        return require'lspconfig.util'.find_git_ancestor(startpath)
      end,
      settings = {
        fstarVSCodeAssistant = {
          verifyOnOpen = false,
          verifyOnSave = false,
          flyCheck = true,
          debug = false,
        },
      },
    },
    docs = {
      description = [[
  https://github.com/FStarLang/fstar-vscode-assistant
  ]],
    },
  }
  require('lspconfig.configs').fstar.setup(opts)
end

--- Finds the vim.lsp.client object for the F* server associated to the
--- given bufnr.
---@param bufnr? number
function lsp.get_fstar_server(bufnr)
  local fstar_client
  vim.lsp.for_each_buffer_client(bufnr, function(client)
    if client.name == 'fstar' then
      fstar_client = client
    end
  end)
  return fstar_client
end

function lsp.handlers.status_handler(err, params)
  if err ~= nil then return end
  require'fstar.progress_bars'.update(params)
end

---Restart the F* server for an open F* file.
---@param bufnr? number
function lsp.restart(bufnr)
  bufnr = bufnr or 0
  local client = lsp.get_fstar_server(bufnr)
  local uri = vim.uri_from_bufnr(bufnr)
  client.notify('$/fstar/restart', { uri = uri })
end

---Restart the Z3 process for an open F* file.
---@param bufnr? number
function lsp.restart_solver(bufnr)
  bufnr = bufnr or 0
  local client = lsp.get_fstar_server(bufnr)
  local uri = vim.uri_from_bufnr(bufnr)
  client.notify('$/fstar/killAndRestartSolver', { uri = uri })
end

---@class lsp.Position
---@field line integer
---@field character integer

---@return lsp.Position
function lsp.get_cur_pos(bufnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  return { line = row-1, character = col }
end

---@param bufnr? number
---@return lsp.Position
function lsp.get_end_pos(bufnr)
  local lines = vim.api.nvim_buf_line_count(bufnr or 0)
  return { line = lines, character = 0 }
end

---Verify until the given position
---@param bufnr? number
---@param pos lsp.Position
---@param lax boolean
function lsp.verify_to_position(bufnr, pos, lax)
  bufnr = bufnr or 0
  local client = lsp.get_fstar_server(bufnr)
  local uri = vim.uri_from_bufnr(bufnr)
  client.notify('$/fstar/verifyToPosition', {
    uri = uri,
    position = pos,
    lax = lax,
  })
end

function lsp.verify_to_pos(bufnr)
  lsp.verify_to_position(bufnr, lsp.get_cur_pos(bufnr), false)
end
function lsp.lax_verify_to_pos(bufnr)
  lsp.verify_to_position(bufnr, lsp.get_cur_pos(bufnr), true)
end
function lsp.verify(bufnr)
  lsp.verify_to_position(bufnr, lsp.get_end_pos(bufnr), false)
end
function lsp.lax_verify(bufnr)
  lsp.verify_to_position(bufnr, lsp.get_end_pos(bufnr), true)
end

return lsp
