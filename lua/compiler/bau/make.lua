--- Makefile bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(option, path)
  path = path or "./Makefile"

  local overseer = require("overseer")
  local task = overseer.new_task({
    name = "- Make interpreter",
    strategy = {
      "orchestrator",
      tasks = {
        {
          name = "- Run makefile → make " .. option,
          cmd = "make -f " .. path .. " " .. option, -- run
          components = { "default_extended" },
        },
      },
    },
  })
  task:start()
end

return M
