-- === python.lua ===
-- Author: Jonathan Delgado
--
-- Run Python scripts.
--
-- Module object
local python = {}
-- Imports ----------
local shell = require(fsmPackagePath .. 'scripts.shell')


-- Run python scripts from shell
function python.runFile(path, argString)
    shell.run('python3 ' .. path .. ' ' .. argString)
end


-- Exit -------------------------------------------------
return python