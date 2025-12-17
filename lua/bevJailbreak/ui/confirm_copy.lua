local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- files: string[]
-- on_confirm(): function
-- on_back(): function
function M.open(files, on_confirm, on_back)
  local lines = {
    "You have selected " .. #files .. " files",
    "",
    "Press <Enter> to copy",
    "Press <Esc> or q to go back and reselect files",
    "",
    "Files:",
  }

  for _, f in ipairs(files) do
    table.insert(lines, "  • " .. f)
  end

  pickers.new({}, {
    prompt_title = "Confirm bevJailbreak Copy",
    finder = finders.new_table({
      results = lines,
    }),
    sorter = conf.generic_sorter({}),
    previewer = false,
    attach_mappings = function(bufnr, map)
      -- ENTER → confirm
      actions.select_default:replace(function()
        actions.close(bufnr)
        on_confirm()
      end)

      -- ESC / q → go back
      map({ "i", "n" }, "<Esc>", function()
        actions.close(bufnr)
        on_back()
      end)

      map({ "i", "n" }, "q", function()
        actions.close(bufnr)
        on_back()
      end)

      return true
    end,
  }):find()
end

return M

