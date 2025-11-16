local M = {}

function M.setup()
	print("bevJailbreak loaded")
end

local failover_file = ".bevContent"

local function write_failover(content)
	local f = io.open(failover_file, "w")
	f:write(content)
	f:close()
end

local function read_failover()
	local f = io.open(failover_file, "r")
	if not f then
		return nil
	end
	local data = f:read("*a")
	f:close()
	if data == "" then
		return nil
	end
	return data
end

local function clear_failover()
	local f = io.open(failover_file, "w")
	f:write("")
	f:close()
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
	local ok = pcall(vim.fn.setreg, "+", encoded)

	if not ok then
		print("[bevJailbreak] WARNING: '+ register not available. Using failover file: " .. failover_file)
		write_failover(encoded)
	else
		local verify = vim.fn.getreg("+")
		if not verify or verify == "" then
			print("[bevJailbreak] WARNING: '+ register empty after write → Using failover file.")
			write_failover(encoded)
		else
			print("Copied " .. #out.files .. " files to + register!")
		end
	end
end

function M.paste_project()
	local data = vim.fn.getreg("+")

	local source = ""

	-- 1. Prüfen ob + Register verwendbar ist
	if data and data ~= "" then
		source = "+ register"
	else
		-- 2. Failover probieren
		local fallback = read_failover()
		if fallback then
			print("[bevJailbreak] WARNING: '+ register empty. Using failover file: " .. failover_file)
			data = fallback
			source = "failover file"
		else
			print("[bevJailbreak] ERROR: Neither '+ register nor failover file contain data.")
			return
		end
	end

	-- JSON parsen
	local ok, decoded = pcall(vim.fn.json_decode, data)
	if not ok or not decoded or not decoded.files then
		print("[bevJailbreak] ERROR: Invalid JSON in " .. source)
		return
	end

	local created = 0

	for _, item in ipairs(decoded.files) do
		local path = item.path
		local content = item.content

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

	-- Failover aufräumen
	clear_failover()
end

vim.api.nvim_create_user_command("BevCopy", function()
	M.copy_project()
end, {})

vim.api.nvim_create_user_command("BevPaste", function()
	M.paste_project()
end, {})

return M
