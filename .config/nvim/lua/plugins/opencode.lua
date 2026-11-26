return {
  'NickvanDyke/opencode.nvim',
  branch = 'main', -- The stable tags target OpenCode V1.
  dependencies = {
    -- Input, picker, and the integrated terminal.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    local terminal = require('snacks.terminal')
    local terminal_opts = { win = { position = 'right', enter = false } }

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          terminal.open('opencode', terminal_opts)
        end,
      },
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ 'n' }, '<leader>oa', function()
      require('opencode').ask '@this: '
    end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n' }, '<leader>ox', function()
      require('opencode').select()
    end, { desc = 'Execute opencode action…' })
    local function toggle_opencode()
      terminal.toggle('opencode', terminal_opts)
    end
    vim.keymap.set('n', '<leader>o.', toggle_opencode, { desc = 'Toggle opencode' })
    vim.keymap.set('n', '<leader>oo', toggle_opencode, { desc = 'Toggle opencode' })
    require('which-key').add {
      { '<leader>o', group = '+[o]pencode' },
    }

    vim.keymap.set({ 'n', 'x' }, 'go', function()
      return require('opencode').operator '@this '
    end, { expr = true, desc = 'Add range to opencode' })
    vim.keymap.set('n', 'goo', function()
      return require('opencode').operator '@this ' .. '_'
    end, { expr = true, desc = 'Add line to opencode' })

    -- V2 scrolls in the TUI; the server's command API only runs slash commands.
    local function scroll_opencode(key)
      local win = terminal.get('opencode', { create = false })
      if win and win:buf_valid() then
        -- CSI-u encoding for the V2 half-page bindings (Ctrl+Alt+U/D).
        vim.api.nvim_chan_send(vim.bo[win.buf].channel, string.format('\27[%d;7u', key:byte()))
      end
    end
    vim.keymap.set('n', '<S-C-u>', function()
      scroll_opencode 'u'
    end, { desc = 'opencode half page up' })
    vim.keymap.set('n', '<S-C-d>', function()
      scroll_opencode 'd'
    end, { desc = 'opencode half page down' })
  end,
}
