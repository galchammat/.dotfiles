-- Set errorformat to match file:line:message pattern
-- We'll filter by level (ERROR/WARN) in the autocmd
vim.o.errorformat = '%f:%l: %m'

-- Auto-filter quickfix to only show ERROR and WARN lines
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = vim.api.nvim_create_augroup('FilterQuickfix', { clear = true }),
  pattern = '*',
  callback = function()
    local qflist = vim.fn.getqflist()
    local filtered = vim.tbl_filter(function(item)
      local text = item.text or ''
      -- Keep only lines with ERROR: or WARN: in them
      return text:match 'ERROR:' or text:match 'WARN:'
    end, qflist)
    vim.fn.setqflist(filtered, 'r')
  end,
})
