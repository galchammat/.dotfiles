return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim', -- Make sure Telescope loads first
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup {}
    -- Telescope integration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end
      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            map('i', '<C-d>', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_bufnr)

              harpoon:list():remove_at(selected_entry.index)
              current_picker:refresh(require('telescope.finders').new_table {
                results = vim.tbl_map(function(item)
                  return item.value
                end, harpoon:list().items),
              })
            end)
            return true
          end,
        })
        :find()
    end
    -- Keymaps
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Harpoon [A]dd file' })
    vim.keymap.set('n', '<C-e>', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })
    -- Jump to files
    vim.keymap.set('n', '<leader>1', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon file 1' })
    vim.keymap.set('n', '<leader>2', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon file 2' })
    vim.keymap.set('n', '<leader>3', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon file 3' })
    vim.keymap.set('n', '<leader>4', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon file 4' })
    -- Navigate through list
    vim.keymap.set('n', '<C-S-P>', function()
      harpoon:list():prev()
    end, { desc = 'Harpoon prev' })
    vim.keymap.set('n', '<C-S-N>', function()
      harpoon:list():next()
    end, { desc = 'Harpoon next' })

    -- Smart replace: moves old file to end before replacing
    local function smart_replace(slot)
      local list = harpoon:list()
      local current_file = vim.api.nvim_buf_get_name(0)
      local old_file = list.items[slot]
      if old_file and old_file.value ~= current_file then
        list:add(old_file)
      end
      list:replace_at(slot)
    end

    vim.keymap.set('n', '<leader>r1', function()
      smart_replace(1)
    end, { desc = 'Harpoon smart replace slot 1' })
    vim.keymap.set('n', '<leader>r2', function()
      smart_replace(2)
    end, { desc = 'Harpoon smart replace slot 2' })
    vim.keymap.set('n', '<leader>r3', function()
      smart_replace(3)
    end, { desc = 'Harpoon smart replace slot 3' })
    vim.keymap.set('n', '<leader>r4', function()
      smart_replace(4)
    end, { desc = 'Harpoon smart replace slot 4' })
    require('which-key').add {
      { '<leader>r', group = '+Harpoon [r]eplace' },
    }
  end,
}
