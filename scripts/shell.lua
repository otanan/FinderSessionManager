-- === shell.lua ===
-- Author: Jonathan Delgado
--
-- Adds shell functionality.
--
-- Module object
local shell = {}
-- Imports ----------

-- Currently just an alias for the execute command.
function shell.run(command) hs.execute(command) end


-- Exit -------------------------------------------------
return shell