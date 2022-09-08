--- === init.lua ===
--- Author: Jonathan Delgado
---
--- FSM initialization script.
---
-- Parent folder for relative imports in other scripts
workingDir = 'Spoons/FinderSessionManager/'
-- Imports -------------------------------------------------
local fsm = require(workingDir .. 'fsm')
local helper = require(workingDir .. 'helper')
-- App icon
local res = require(workingDir .. 'res')
local appIcon = res.images.load('appIcon.png')


-- Notifications -------------------------------------------------
local defaultNotifySettings = {
    title='FSM',
    setIdImage=appIcon,
    contentImage=appIcon,
}

-- Generate a new notify with the provided callback function for feature
-- specific notifications
local function newNotifyObj(fn) return hs.notify.new(fn, defaultNotifySettings) end

-- Send a message
local function notify(message, subtitle)
    local notifyInstance = newNotifyObj(nil)
    notifyInstance:subTitle(subtitle)
    notifyInstance:informativeText(message)
    notifyInstance:send()
end


-- Send an alert.
-- Currently just another alias for notify
local function alert(message)
    -- local alertStyle = { textSize=30, radius=5 }
    notify(message)
end


-- Watchers -------------------------------------------------
-- Callback functions ----------
local function finderActivated()
    -- fsm.update()
    fsm.menu.show()
end

local function finderDeactivated()
    fsm.update()
    fsm.menu.hide()
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
    -- Initialize fsm, then start the watchers
    fsm.init()

    -- Start watchers --------------------------
    activeWatcher = hs.application.watcher.new(activationWatcher)
    activeWatcher:start()
    deactiveWatcher = hs.application.watcher.new(deactivationWatcher)
    deactiveWatcher:start()
end


-- Exit -------------------------------------------------
return fsm