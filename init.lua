-------------------------------------------------------------------------------
------------------------- Finder Session Manager -------------------------
-------------------------------------------------------------------------------


------------------------- Imports -------------------------
-- Parent folder for relative imports in other scripts
workingDir = 'Spoons/FinderSessionManager/'
-- Imports
json = require('lunajson')
require(workingDir .. 'helper')
require(workingDir .. 'jxaHelper')
require(workingDir .. 'fsm')


------------------------- File IO -------------------------
function loadSettings()
    print('Loading FSM settings...')
    -- Settings defines projects and their pinned folders
    settings = jsonLoad('fsm_settings')

    -- Allow for default session
    -- for name in pairs(settings) do
    --     if settings['default'] ~= nil
end
loadSettings()


function updateSettings()
    jsonDump(settings, 'fsm_settings')
    -- alert('Settings updated.')
    print('Settings updated.')
end


function addSessionToSettings(name, desc, pinned, paths)
    settings[name] = {
        description=desc,
        pinned=pinned,
        paths=paths,
    }
end


---------- Settings parsing ----------
function getPaths(session) return settings[session].paths end
function getPinned(session) return settings[session].pinned end
function getDescription(session)
    desc = settings[session].description
    if desc == nil then desc = '' end
    return desc
end
function getFocus(session)
    return settings[session].focus
end


---------- Settings writing ----------
function setFocus(session, path)
    settings[session].focus = path
end


------------------------- Initialization -------------------------
function initChooser()
    local choices = {}

    ---------- Menu options ----------
    table.insert(choices, {
        text='New session',
        subText='Create a new finder session.',
        -- ID for identifying when a menu function is called
        uuid='__new__'
    })
    local numChoices = 1

    -- Create choices
    for session in pairs(settings) do
        numChoices = numChoices + 1

        local description = getDescription(session)
        table.insert(choices, {
            text=session,
            subText=description,
        })
    end

    -- Make the chooser
    chooser = hs.chooser.new(function(choice)
        -- Get focus regardless
        hs.application.launchOrFocus('Finder')

        if choice == nil then
            print('No choice made.')
        elseif choice.uuid ~= nil then
            -- Cases based on identifier
            if choice.uuid == '__new__' then
                newSession()
            end
        else 
            openSession(choice.text)
        end
    end)

    -- Customize the chooser
    chooser:choices(choices)
    chooser:searchSubText(true)
    -- Add one for padding
    if numChoices < 5 then
        chooser:rows(numChoices + 1)
    else
        chooser:rows(6)
    end
    chooser:bgDark(true)
end


local finder = hs.application.find("Finder")
initChooser()
-- Start with no session
currentSession = nil



-------------------------------------------------------------------------------
------------------------- Watchers -------------------------
-------------------------------------------------------------------------------
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.deactivated) then
    -- if (eventType == hs.application.watcher.activated) or 
    --     (eventType == hs.application.watcher.deactivated) then
        if (appName == 'Finder') then updateSessions() end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

---------- Bind hotkeys ----------
-- Show menu
hs.hotkey.bind({"ctrl", "alt"}, "P", function() chooser:show() end)
-- Detach session
hs.hotkey.bind({"ctrl", "alt"}, "O", detachSession)