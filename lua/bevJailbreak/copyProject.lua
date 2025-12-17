local clipboard = require("bevJailbreak.clipboard")
local failover = require("bevJailbreak.failover")
local failover_file = failover.failover_file
local write_failover = failover.write_failover

local M = {}

function M.copy_project()
  local handle = io.popen("git ls-files")
  local files = handle:read("*a")
  handle:close()

  local out = { files = {} }

  for file in files:gmatch("[^\r\n]+") do
    local f = io.open(file, "r")
    if f then
      local content = f:read("*a")
      f:close()

      table.insert(out.files, {
        path = file,
        content = content,
      })
    end
  end

  local encoded = vim.fn.json_encode(out)
  -- Versuche + Register zu beschreiben
  local ok = clipboard.copy(encoded)

  if not ok then
    print("[bevJailbreak] WARNING: '+ register not available. Using failover file: " .. failover_file)
    write_failover(encoded)
  else
  end

end

return M
