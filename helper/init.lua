--- === helper.lua ===
--- Author: Jonathan Delgado
---
--- Helper scripts that provides basic programmatic functionality.
--- This module should be logically independent of FSM.
---
-- Module object
local helper = {}
helper.table = require(workingDir .. 'helper.table')
helper.file = require(workingDir .. 'helper.file')
helper.json = require(workingDir .. 'helper.json')


-- Exit -------------------------------------------------
return helper