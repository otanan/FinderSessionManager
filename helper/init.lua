--- === helper.lua ===
--- Author: Jonathan Delgado
---
--- Helper scripts that provides basic programmatic functionality.
--- This module should be logically independent of FSM.
---
-- Module object
local helper = {}
helper.table = require(fsmPackagePath .. 'helper.table')
helper.array = require(fsmPackagePath .. 'helper.array')
helper.file = require(fsmPackagePath .. 'helper.file')
helper.json = require(fsmPackagePath .. 'helper.json')


-- Exit -------------------------------------------------
return helper