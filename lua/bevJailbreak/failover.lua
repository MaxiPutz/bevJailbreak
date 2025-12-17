local M = {}


local config = {
  enabled = true,
  failover_file = ".bevContent",
}

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- --- helpers -------------------------------------------------

local function git_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not handle then return nil end
  local root = handle:read("*a")
  handle:close()
  root = root:gsub("%s+$", "")
  return root ~= "" and root or nil
end

local function ensure_gitignore_entry(entry)
  local root = git_root()
  if not root then return end

  local path = root .. "/.gitignore"

  local seen = {}
  local f = io.open(path, "r")
  if f then
    for line in f:lines() do
      seen[line] = true
    end
    f:close()
  end

  if seen[entry] then return end

  f = io.open(path, "a")
  if not f then return end
  if next(seen) ~= nil then f:write("\n") end
  f:write(entry .. "\n")
  f:close()
end

-- --- public API ---------------------------------------------

function M.write_failover(content)
  if not config.enabled then
    return false
  end

  local f = io.open(config.failover_file, "w")
  if not f then return false end
  f:write(content)
  f:close()

  ensure_gitignore_entry(config.failover_file)
  return true
end

function M.read_failover()
  if not config.enabled then
    return false
  end

  local f = io.open(config.failover_file, "r")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  return data ~= "" and data or nil
end

function M.clear_failover()
  if not config.enabled then
    return false
  end

  local f = io.open(config.failover_file, "w")
  if f then f:write("") f:close() end
end

return M
