--- === init.lua ===
--- Author: Jonathan Delgado
---
--- FSM initialization script.
---
-- Imports -------------------------------------------------
-- Parent folder for relative imports in other scripts
workingDir = 'Spoons/FinderSessionManager/'
-- Imports
json = require('lunajson')
helper = require(workingDir .. 'helper')
jxa = require(workingDir .. 'jxa')
fsm = require(workingDir .. 'fsm')


-- Watchers -------------------------------------------------
-- Callback functions ----------
local function finderActivated()
    fsm.update()
end

local function finderDeactivated()
    fsm.update()
end


-- Listeners ----------
local function activationWatcher(appName, eventType, appObject)
    if (appName == 'Finder') and (eventType == hs.application.watcher.activated) then
        finderActivated()
    end
end


local function deactivationWatcher(appName, eventType, appObject)
    if (appName == 'Finder') and (eventType == hs.application.watcher.deactivated) then
        finderDeactivated()
    end
end


-- Entry -------------------------------------------------
function fsm.start()
    loadSettings()
    fsm.newChooser()

    -- Start watchers --------------------------
    activeWatcher = hs.application.watcher.new(activationWatcher)
    activeWatcher:start()
    deactiveWatcher = hs.application.watcher.new(deactivationWatcher)
    deactiveWatcher:start()
end


-- Exit -------------------------------------------------
return fsm