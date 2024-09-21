--- Make language actions
-- Supporting this filetype allow the user
-- to use the compiler while editing a Makefile.

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "Run Project", value = "option1" },
  { text = "Run Makefile", value = "option2" },
}

--- Helper
-- Runs ./Makefile in the current working directory.
function M.run_makefile(type)
  local utils = require("compiler.utils")
  local makefile = nil

  if type == 1 then
    local projectFile = vim.loop.fs_stat("./project.json")

    if not projectFile then
      vim.notify(
        "   You must have a project.json file in your working directory! ",
        vim.log.levels.WARN,
        {
          title = "Compiler.nvim",
        }
      )
      return
    end

    if projectFile then
      local content = utils.read_file(vim.fn.getcwd() .. "/project.json")
      local makefile_path = utils.extract_makefile_path(content)

      -- Print the Makefile path
      if makefile_path then
        makefile = makefile_path
      else
        makefile = utils.os_path(vim.fn.getcwd() .. "/Makefile", true)
      end
    end
  elseif type == 2 then
    local stat = vim.loop.fs_stat("./Makefile")

    if not stat then
      vim.notify(
        "   You must have a Makefile in your working directory! ",
        vim.log.levels.WARN,
        {
          title = "Compiler.nvim",
        }
      )
      return
    end

    if stat then
      makefile = utils.os_path(vim.fn.getcwd() .. "/Makefile", true)
    end
  end

  -- Run makefile
  local overseer = require("overseer")
  local task = overseer.new_task({
    name = "- Make interpreter",
    strategy = {
      "orchestrator",
      tasks = {
        {
          name = "- Run Makefile → " .. makefile,
          cmd = "make -f " .. makefile, -- run
          components = { "default_extended" },
        },
      },
    },
  })
  task:start()
end

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  if selected_option == "option1" then
    _G.compiler_redo_type = "project"
    M.run_makefile(1)
  elseif selected_option == "option2" then
    _G.compiler_redo_type = "makefile"
    M.run_makefile(2)
  end
end

return M
