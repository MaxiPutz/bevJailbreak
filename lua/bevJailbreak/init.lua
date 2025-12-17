local M = {}

local projectCopy = require("bevJailbreak.copyProject")
local projectPaste = require("bevJailbreak.pasteProject")

M.paste_project = projectPaste.paste_project
M.copy_project = projectCopy.copy_project


function M.setup(opts)
  M.opts = opts or {}
  print("bevJailbreak loaded")

  vim.api.nvim_create_user_command("BevCopy", function()
    M.copy_project()
  end, {})

  vim.api.nvim_create_user_command("BevPaste", function()
    M.paste_project()
  end, {})
end



return M
