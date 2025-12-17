local M = {}
-- 🔧 Defaults
local defaults = {
  failover_file = ".bevContent",
  failover = true,
  osc52 = true,
  setreg = true,
}

local projectCopy = require("bevJailbreak.copyProject")
local projectPaste = require("bevJailbreak.pasteProject")

M.paste_project = projectPaste.paste_project
M.copy_project = projectCopy.copy_project


function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", defaults, opts or {})
  print("bevJailbreak loaded")

  require("bevJailbreak.clipboard").setup({
    osc52  = M.opts.osc52,
    setreg = M.opts.setreg,
  })

  require ("bevJailbreak.failover").setup({
    enabled = M.opts.failover,
    failover_file    = M.opts.failover_file,
  })

  vim.api.nvim_create_user_command("BevCopy", function()
    M.copy_project()
  end, {})

  vim.api.nvim_create_user_command("BevPaste", function()
    M.paste_project()
  end, {})
end



return M
