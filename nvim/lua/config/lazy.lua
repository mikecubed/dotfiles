local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
    -- extras are managed via lazyvim.json (:LazyExtras)
    {
      "KostkaBrukowa/copilot-cli.nvim",
      lazy = true,
      keys = {
        { "<leader>ag", "<cmd>Copilot toggle<cr>", desc = "Toggle Copilot CLI" },
        { "<leader>aa", "<cmd>Copilot ask<cr>", desc = "Ask Copilot", mode = { "n", "v" } },
        { "<leader>af", "<cmd>Copilot add_file<cr>", desc = "Add File" },
      },
      dependencies = {
        "folke/snacks.nvim",
      },
      config = true,
    },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
