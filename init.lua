--- === init.lua ===
--- Author: Jonathan Delgado
---
--- FSM initialization script.
---
-- Parent folder for relative imports in other scripts
fsmPackagePath = 'Spoons/FinderSessionManager/'
-- Imports -------------------------------------------------
local fsm = require(fsmPackagePath .. 'fsm')
local helper = require(fsmPackagePath .. 'helper')
-- App icon
local res = require(fsmPackagePath .. 'res')
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
-- Currently just an alias for notify
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
    if fsm.hideWithFocusLoss then 
        fsm.menu.hide()
    end
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
local watchForActivate = hs.application.watcher.new(activationWatcher)
local watchForDeactivate = hs.application.watcher.new(deactivationWatcher)

-- Adds support for debugging mode
function fsm.start()
    -- Initialize fsm, then start the watchers
    fsm.init()

    -- Start watchers
    watchForActivate:start()
    watchForDeactivate:start()
end


function fsm.quit()
    print('Closing FSM...')
    -- Run last update 
    fsm.update()
    fsm.running = false
    -- Close menu
    fsm.menu.bar:delete()
    -- Close choose and kill call function (for rebindings)
    fsm.chooser:delete()
    -- Kill watchers
    watchForActivate:stop()
    watchForDeactivate:stop()
end


-- Exit -------------------------------------------------
return fsm