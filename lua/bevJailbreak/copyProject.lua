local clipboard = require("bevJailbreak.clipboard")
local failover = require("bevJailbreak.failover")
local failover_file = failover.failover_file
local write_failover = failover.write_failover
local ui = require("bevJailbreak.ui.select_files")

local M = {}

local function git_files()
  local h = io.popen("git ls-files")
  if not h then return {} end
  local data = h:read("*a")
  h:close()

  local files = {}
  for f in data:gmatch("[^\r\n]+") do
    table.insert(files, f)
  end
  return files
end

function M.copy_files(files)
  if type(files) ~= "table" then
    print("[bevJailbreak] ERROR: copy_files expects a table of files")
    return
  end

  local out = { files = {} }

  for _, file in ipairs(files) do
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

  local ok = clipboard.copy(encoded)
  if not ok then
    print("[bevJailbreak] WARNING: Clipboard unavailable, using failover")
    write_failover(encoded)
  end
end


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

function M.copy_project_select()
  local files = git_files()

  ui.open(files, function(selected)
    local out = { files = {} }

    for _, file in ipairs(selected) do
      local f = io.open(file, "r")
      if f then
        table.insert(out.files, {
          path = file,
          content = f:read("*a"),
        })
        f:close()
      end
    end

    local encoded = vim.fn.json_encode(out)
    local ok = clipboard.copy(encoded)

    if not ok then
      failover.write_failover(encoded)
    end
  end)
end

return M
