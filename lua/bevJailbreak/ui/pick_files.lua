local pickers = require("telescope.pickers") local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions") local action_state = require("telescope.actions.state")

local confirm = require("bevJailbreak.ui.confirm_copy")

local M = {}

function M.open(files, on_confirm)
  local function open_picker()
    local picker

    picker = pickers.new({}, {
      prompt_title = "Select files to copy (C-y toggle)",
      finder = finders.new_table({
        results = files,
        entry_maker = function(file)
          return {
            value = file,
            display = file,
            ordinal = file,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),

      attach_mappings = function(prompt_bufnr, map)
        -- Toggle selection
        map({ "i", "n" }, "<C-y>", function()
          actions.toggle_selection(prompt_bufnr)
          actions.move_selection_next(prompt_bufnr)
        end)

        -- Confirm
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selections = picker:get_multi_selection()

          local selected = {}
          for _, entry in ipairs(selections) do
            table.insert(selected, entry.value)
          end

          actions.close(prompt_bufnr)

          confirm.open(
            selected,
            function() on_confirm(selected) end,
            function() open_picker() end
          )
        end)

        return true
      end,
    })

    picker:find()
  end

  open_picker()
end

return M

