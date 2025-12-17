local M = {}

local clipboard = require("bevJailbreak.clipboard")
local failover = require("bevJailbreak.failover")
local clear_failover = failover.clear_failover
local read_failover = failover.read_failover

function M.paste_project()
  local data = vim.fn.getreg("+")
  local source = ""

  -- 1) Versuch Clipboard
  if data and data ~= "" then
    source = "+ register"
  else
    -- 2) Versuch Failover
    local fallback = read_failover()
    if fallback then
      print("[bevJailbreak] WARNING: Clipboard empty → using failover file")
      data = fallback
      source = "failover file"
    else
      print("[bevJailbreak] ERROR: No JSON found")
      return
    end
  end

  -- JSON parse retry logic
  local ok, decoded = pcall(vim.fn.json_decode, data)
  if not ok or type(decoded) ~= "table" or type(decoded.files) ~= "table" then
    -- Try failover ONLY if clipboard was used
    if source == "+ register" then
      local fallback = read_failover()
      if fallback then
        print("[bevJailbreak] WARNING: JSON invalid → retrying with failover")
        ok, decoded = pcall(vim.fn.json_decode, fallback)
        if not ok or type(decoded) ~= "table" or type(decoded.files) ~= "table" then
          print("[bevJailbreak] ERROR: Failover JSON invalid too")
          return
        end
      else
        print("[bevJailbreak] ERROR: Clipboard JSON invalid AND no failover")
        return
      end
    else
      print("[bevJailbreak] ERROR: Failover JSON invalid")
      return
    end
  end

  -- At this point decoded.files is guaranteed to exist
  local created = 0

  for _, item in ipairs(decoded.files) do
    local path = item.path
    local content = item.content or ""

    local dir = path:match("(.*/)")
    if dir then
      vim.fn.mkdir(dir, "p")
    end

    local f = io.open(path, "w")
    if f then
      f:write(content)
      f:close()
      created = created + 1
    else
      print("[bevJailbreak] ERROR: Cannot write file " .. path)
    end
  end

  print("Reconstructed " .. created .. " files from " .. source .. ".")
  clear_failover()
end

return M
