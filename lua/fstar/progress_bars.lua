local progress_bars = {}
local options = { priority = 10 }
options._DEFAULTS = vim.deepcopy(options)

local signs = {
  'fstarSignStarted',
  'fstarSignInProgress',
  'fstarSignLaxOk',
  'fstarSignOk',
  'fstarSignFailed',
}

local proc_infos = {}

local function _update(bufnr)
  for _,n in ipairs(signs) do
    vim.fn.sign_unplace(n, { buffer = bufnr })
  end
  local diagnostics = {}

  for _, proc_info in ipairs(proc_infos[vim.uri_from_bufnr(bufnr)]) do
    local start_line = proc_info.range.start.line + 1
    local end_line = proc_info.range['end'].line + 1

    local n = nil
    if proc_info.kind == 'started' then
      n = 'fstarSignStarted'
    elseif proc_info.kind == 'in-progress' then
      n = 'fstarSignInProgress'
    elseif proc_info.kind == 'ok' then
      n = 'fstarSignOk'
    elseif proc_info.kind == 'lax-ok' then
      n = 'fstarSignLaxOk'
    -- elseif proc_info.kind == 'light-ok' then
    --   n = 'fstarSignLightOk'
    elseif proc_info.kind == 'failed' then
      n = 'fstarSignFailed'
    -- elseif proc_info.kind == 'light-failed' then
    --   n = 'fstarSignLightFailed'
    end
    if n then
      for line = start_line, end_line do
        vim.fn.sign_place(0, n, n, bufnr, {
          lnum = line,
          priority = options.priority,
        })
      end
    end
  end
end

-- Table from bufnr to timer object.
local timers = {}

function progress_bars.update(params)
  proc_infos[params.uri] = params.fragments

  if not progress_bars.enabled then
    return
  end
  -- TODO FIXME can potentially create new buffer
  local bufnr = vim.uri_to_bufnr(params.uri)

  if timers[bufnr] == nil then
    timers[bufnr] = vim.defer_fn(function()
      timers[bufnr] = nil
      _update(bufnr)
    end, 100)
  end
end

function progress_bars.enable(opts)
  options = vim.tbl_extend('force', options, opts)

  local function def(n, ch, hi)
    vim.fn.sign_define(n, { text = ch, texthl = n })
    if hi then vim.cmd.hi('def ' .. n .. ' ' .. hi) end
  end

  def('fstarSignStarted',     '⋮', 'guifg=gray ctermfg=gray')
  def('fstarSignInProgress',  '▮', 'guifg=orange ctermfg=215')
  def('fstarSignOk',          '│', 'guifg=green ctermfg=70')
  def('fstarSignLaxOk',       '│', 'guifg=blue ctermfg=68')
  def('fstarSignFailed',      '╳', 'guifg=red ctermfg=52')

  progress_bars.enabled = true
end

return progress_bars
