local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}


local function select_all_when_ready(picker, tries)
  tries = tries or 0
  if tries > 20 then
    return -- Notfallbremse
  end

  if picker.manager and picker.prompt_bufnr then
    actions.select_all(picker.prompt_bufnr)
  else
    vim.defer_fn(function()
      select_all_when_ready(picker, tries + 1)
    end, 20)
  end
end

local function unique_files_from_qf()
  local qf = vim.fn.getqflist()
  local seen = {}
  local files = {}

  for _, item in ipairs(qf) do
    if item.bufnr and item.bufnr > 0 then
      local name = vim.api.nvim_buf_get_name(item.bufnr)
      if name ~= "" and not seen[name] then
        seen[name] = true
        table.insert(files, name)
      end
    end
  end

  return files
end

function M.open(on_confirm)
  local files = unique_files_from_qf()

  if #files == 0 then
    print("[bevJailbreak] Quickfix list is empty")
    return
  end

  picker = pickers.new({}, {
    prompt_title = "Select files from Quickfix",
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
      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()

        local selected = {}
        for _, e in ipairs(selections) do
          table.insert(selected, e.value)
        end

        actions.close(prompt_bufnr)
        on_confirm(selected)
      end)

      return true
    end,
  })

  picker:find()

  select_all_when_ready(picker)
end



return M

