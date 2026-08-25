return {
  'folke/tokyonight.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    require('tokyonight').setup {
      style = 'storm',
      transparent = true,
      terminal_colors = true,

      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = 'transparent',
        floats = 'transparent',
      },

      -- 👇 add these (even if you don't customize yet)
      on_colors = function(colors)
        -- you can tweak base colors here later
      end,

      on_highlights = function(hl, colors)
        -- you can tweak specific highlight groups here later
      end,
    }

    vim.cmd.colorscheme 'tokyonight'
  end,
}
