local M = {}

function M.setup()
	print("bevJailbreak loaded")
end

local json = vim.json or require("vim.json")

M.copy_project = function()
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
	vim.fn.setreg("+", encoded)

	print("Copied " .. #out.files .. " files to clipboard as JSON.")
end

M.paste_project = function()
	local data = vim.fn.getreg("+")
	if not data or data == "" then
		print("Clipboard empty")
		return
	end

	local ok, decoded = pcall(vim.fn.json_decode, data)
	if not ok or not decoded or not decoded.files then
		print("Clipboard does not contain valid project JSON")
		return
	end

	local created = 0

	for _, item in ipairs(decoded.files) do
		local path = item.path
		local content = item.content

		-- ensure directory exists
		local dir = path:match("(.*/)")
		if dir then
			vim.fn.mkdir(dir, "p")
		end

		-- write file
		local f = io.open(path, "w")
		if f then
			f:write(content)
			f:close()
			created = created + 1
		else
			print("ERROR writing file: " .. path)
		end
	end

	print("Reconstructed " .. created .. " files from JSON clipboard.")
end

vim.api.nvim_create_user_command("BevCopy", function()
	M.copy_project()
end, {})

vim.api.nvim_create_user_command("BevPaste", function()
	M.paste_project()
end, {})

return M
