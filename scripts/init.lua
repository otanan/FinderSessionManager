-- === init.lua ===
-- Author: Jonathan Delgado
--
-- Unifies and handles running specific types of external scripts, i.e. JXA, 
-- shell, Applescript, etc.
--
-- Module object
local scripts = {}
-- Imports ----------
scripts.shell = require(fsmPackagePath .. 'scripts.shell')
scripts.jxa = require(fsmPackagePath .. 'scripts.jxa')
scripts.apple = require(fsmPackagePath .. 'scripts.apple')



-- Exit -------------------------------------------------
return scripts