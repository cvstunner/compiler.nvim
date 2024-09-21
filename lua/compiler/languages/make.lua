--- Make language actions
-- Supporting this filetype allow the user
-- to use the compiler while editing a Makefile.

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "Run Makefile", value = "option1" },
}

--- Helper
-- Runs ./Makefile in the current working directory.
function M.run_makefile()
  local stat = vim.loop.fs_stat("./Makefile")
  local projectFile = vim.loop.fs_stat("./project.json")

  print("stat: ", stat)
  print("projectFile: ", projectFile)

  if not (stat or projectFile) then
    vim.notify(
      "You must have a Makefile or Project.json in your working directory",
      vim.log.levels.WARN,
      {
        title = "Compiler.nvim",
      }
    )
    return
  end

  local utils = require("compiler.utils")
  local makefile = nil

  if projectFile then
    local content = utils.read_file(vim.fn.getcwd() .. "/project.json")
    local makefile_path = utils.extract_makefile_path(content)

    -- Print the Makefile path
    if makefile_path then
      makefile = makefile_path
    else
      makefile = utils.os_path(vim.fn.getcwd() .. "/Makefile", true)
    end
  else
    makefile = utils.os_path(vim.fn.getcwd() .. "/Makefile", true)
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
  if selected_option == "option1" then M.run_makefile() end
end

return M
