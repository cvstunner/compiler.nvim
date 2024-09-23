--- ### Frontend for compiler.nvim

local M = {}

function M.show()
  -- If working directory is home, don't open telescope.
  if vim.loop.os_homedir() == vim.loop.cwd() then
    vim.notify(
      "   You must :cd your project dir first.\n\t\tHome is not allowed as working dir! ",
      vim.log.levels.WARN,
      {
        title = "Compiler.nvim",
      }
    )
    return
  end

  -- Dependencies
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local utils = require("compiler.utils")
  local utils_bau = require("compiler.utils-bau")

  local buffer = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })

  -- POPULATE
  -- ========================================================================

  -- Programatically require the backend for the current language.
  local language = utils.require_language(filetype)

  -- On unsupported languages, default to make.
  if not language then language = utils.require_language("make") or {} end

  -- Also show options discovered on Makefile, Cmake... and other bau.
  if not language.bau_added then
    language.bau_added = true
    local bau_opts = utils_bau.get_bau_opts()

    -- Insert a separator on telescope for every bau.
    local last_bau_value = nil
    for _, item in ipairs(bau_opts) do
      if last_bau_value ~= item.bau then
        table.insert(language.options, { text = "", value = "separator" })
        last_bau_value = item.bau
      end
      table.insert(language.options, item)
    end
  end

  -- Add numbers in front of the options to display.
  local index_counter = 0
  for _, option in ipairs(language.options) do
    if option.value ~= "separator" then
      index_counter = index_counter + 1
      if index_counter >= 22 then _G.compiler_telescope_height = 0.7 end

      if index_counter >= 1 and index_counter <= 9 then
        option.text = " " .. index_counter .. " - " .. option.text
      else
        option.text = index_counter .. " - " .. option.text
      end
    end
  end

  -- RUN ACTION ON SELECTED
  -- ========================================================================

  --- On option selected → Run action depending of the language.
  local function on_option_selected(prompt_bufnr)
    actions.close(prompt_bufnr) -- Close Telescope on selection
    local selection = state.get_selected_entry()

    -- FIX: separator is missing
    if selection.value == "separator" then return end -- Ignore separators

    if selection then
      -- Do the selected option belong to a build automation utility?
      local bau = nil
      local makefile_path = nil
      local selectedIndex = selection.ordinal

      for _, value in ipairs(language.options) do
        if value.text == selection.display then
          bau = value.bau
          makefile_path = value.path
        end
      end

      if bau then -- call the bau backend.
        bau = utils_bau.require_bau(bau)
        if bau then bau.action(selection.value, makefile_path) end
        -- then
        -- clean redo (language)
        _G.compiler_redo_selection = nil
        _G.compiler_redo_path = nil
        -- save redo (bau)
        _G.compiler_redo_bau_selection = selection.value
        _G.compiler_redo_path = makefile_path
        _G.compiler_redo_bau = bau

        _G.compiler_redo_telescope_selected = tonumber(
          selectedIndex:match("%d+")
        ) + 1
      else -- call the language backend.
        language.action(selection.value)
        -- then
        -- save redo (language)
        _G.compiler_redo_selection = selection.value
        _G.compiler_redo_filetype = filetype
        -- clean redo (bau)
        _G.compiler_redo_bau_selection = nil
        _G.compiler_redo_bau = nil
        _G.compiler_redo_telescope_selected =
          tonumber(selectedIndex:match("%d+"))
      end
    end
  end

  -- SHOW TELESCOPE
  -- ========================================================================
  local function open_telescope()
    pickers
      .new({}, {
        prompt_title = "Compiler",
        results_title = "Options",
        finder = finders.new_table({
          results = language.options,
          entry_maker = function(entry)
            return {
              display = entry.text,
              value = entry.value,
              ordinal = entry.text,
            }
          end,
        }),
        sorter = conf.generic_sorter(),
        layout_config = {
          width = 0.3, -- Set width as a percentage of the screen (e.g., 80%)
          height = _G.compiler_telescope_height or 0.6, -- Set height as a percentage of the screen (e.g., 60%)
          prompt_position = "top", -- You can set this to "bottom" as well
        },
        default_selection_index = _G.compiler_redo_telescope_selected,
        attach_mappings = function(_, map)
          map(
            "i",
            "<CR>",
            function(prompt_bufnr) on_option_selected(prompt_bufnr) end
          )
          map(
            "n",
            "<CR>",
            function(prompt_bufnr) on_option_selected(prompt_bufnr) end
          )
          return true
        end,
      })
      :find()
  end
  open_telescope() -- Entry point
end

return M
