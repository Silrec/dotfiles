-- The active theme is picked by ~/.local/bin/theme-sync,
-- which writes its name into lua/current-theme.lua
local ok, theme = pcall(dofile, vim.fn.stdpath("config") .. "/lua/current-theme.lua")

return {
    -- these two come with LazyVim; listing them again only merges in extra opts
    {
        "folke/tokyonight.nvim",
        opts = {
            transparent = true,
            styles = { sidebars = "transparent", floats = "transparent" }, -- file tree, popups
        },
    },
    { "catppuccin/nvim", name = "catppuccin", opts = { transparent_background = true } },

    { "ellisonleao/gruvbox.nvim", lazy = true, opts = { transparent_mode = true } },
    { "rebelot/kanagawa.nvim", lazy = true, opts = { transparent = true } },
    { "rose-pine/neovim", name = "rose-pine", lazy = true, opts = { styles = { transparency = true } } },
    { "gbprod/nord.nvim", lazy = true, opts = { transparent = true } },
    { "Mofiqul/dracula.nvim", lazy = true, opts = { transparent_bg = true } },

    { "LazyVim/LazyVim", opts = { colorscheme = ok and theme or "tokyonight" } },
}
