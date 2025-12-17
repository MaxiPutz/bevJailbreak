local M = {}

local has_osc52, osc52 = pcall(require, "vim.ui.clipboard.osc52")


M.copy = function(content)
  -- 1️⃣ OSC52
  if has_osc52 then
    local osc_ok = pcall(function()
      osc52.copy("+")({content})
      osc52.copy("*")({content})
    end)

    if osc_ok then
      print("copied via osc52")
      return true
    end
  end

  -- 2️⃣ System Clipboard
  local clip_ok = pcall(function()
    vim.fn.setreg("+", content)
    vim.fn.setreg("*", content)
  end)

  if clip_ok and vim.fn.getreg("+") ~= "" then
    print("has_osc52", has_osc52)
    print("copied via system clipboard")
    return true
  end

  return false
end

return M
