-------------------------------------------------------------------------------
------------------------- Finder Session Manager -------------------------
-------------------------------------------------------------------------------
-- Parent folder for relative imports in other scripts
workingDir = 'Spoons/FinderSessionManager/'
-- Imports
require(workingDir .. 'helper')
require(workingDir .. 'jxaHelper')
json = require('lunajson')


------------------------- Initialization -------------------------
local finder = hs.application.find("Finder")
-- Start with no session
currentSession = nil


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
initChooser()


------------------------- Manager -------------------------
-- Load the given session
function openSession(session)
    -- Get focus
    hs.application.launchOrFocus('Finder')

    if session == currentSession then
        print('Session unchanged.')
        do return end
    end

    -- Update current session before changing
    if currentSession ~= nil then updateSessions() end

    print('Loading session: ' .. session)

    ---------- Setting tab session ----------
    -- Loop through folders and make path array string for jxa
    pinnedPathString = ''
    for _, path in pairs(getPinned(session)) do
        pinnedPathString = pinnedPathString .. '"' .. path .. '"' .. ', '
    end

    pathString = ''
    for _, path in pairs(getPaths(session)) do
        pathString = pathString .. '"' .. path .. '"' .. ', '
    end


    setTabsWithPathArrayStrings(pinnedPathString, pathString)
    currentSession = session
    -- Padding to indicate complete session
    print()
end


function setTabsWithPathArrayStrings(pinnedPathString, pathString)
    -- Fix empty strings throwing errors with format
    if pathString == '' then pathString = ' ' end
    if pinnedPathString == '' then pinnedPathString = ' ' end
    command = string.format(jxaSetTabsCommand, pinnedPathString, pathString)
    hs.osascript.javascript(command)
end


-- Update the sessions dictionary then the settings file
function updateSessions()
    -- alert("Updating finder session...") 
    local paths = getOpenFinderPaths(finder)

    if currentSession == nil then
        print('No active session...')
        return
    end

    local savedPaths = getPaths(currentSession)
    local pinned = getPinned(currentSession)

    -- Clear old paths
    clearList(savedPaths)
    -- Update paths, skip pinned paths
    for _, path in pairs(paths) do
        if not hasValue(pinned, path) then
            table.insert(savedPaths, path)
        end
    end

    -- Update the actual file
    updateSettings()
end


-- Get the paths currently open in finder as an array
function getOpenFinderPaths()
    _, paths = hs.osascript.javascript(jxaGetPathsCommand)
    return paths
end


function closeFinderWindows()
    -- Get focus for menu item
    hs.application.launchOrFocus('Finder')
    finder:selectMenuItem({'File', 'Close Window'})
end


-- Detach from any given session
function detachSession()
    updateSessions()
    alert('Session detached.')
    currentSession = nil
end


function newSession()
    -- Prompt user for input
    _, name = hs.dialog.textPrompt(
        'New session name: ',
        'Please input a name for the new session.'
    )
    _, description = hs.dialog.textPrompt(
        'New session description: ',
        'Provide a description for ' .. name .. ' session.'
    )

    -- Update the settings
    -- Default to home folder
    addSessionToSettings(name, description, {}, {'/Users/Otanan'})
    -- Open file
    updateSettings()
    -- Remake chooser to reflect this new session option
    initChooser()
    -- Open this session
    openSession(name)
end


-------------------------------------------------------------------------------
------------------------- Watchers -------------------------
-------------------------------------------------------------------------------
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) or 
        (eventType == hs.application.watcher.deactivated) then
        if (appName == "Finder") then
            updateSessions()
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Bind project selector
hs.hotkey.bind({"ctrl", "alt"}, "P", function() chooser:show() end)
hs.hotkey.bind({"ctrl", "alt"}, "O", detachSession)