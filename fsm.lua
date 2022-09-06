--- === fsm.lua ===
--- Author: Jonathan Delgado
---
--- FinderSessionManager
---
-- Module object
fsm = {}


-- Initialization -------------------------------------------------
-- Load the settings, should only need to be done once.
function loadSettings()
    print('Loading FSM settings...')
    -- Settings defines projects and their pinned folders
    fsm.settings = helper.json.load('settings')
    fsm.sessions = fsm.settings.sessions

    -- Set the current session
    fsm.active = nil
    -- Allow for default session
    -- for name in pairs(settings) do
    --     if settings['default'] ~= nil
end


-- Sessions -------------------------------------------------
--- Function
--- Reports whether the session has no associated paths.
---
--- Parameters:
---  * session - the session to inspect.
---
--- Returns:
---  * true if there are no paths (including pinned), false otherwise
function fsm.isEmptySession(session)
    for _, path in pairs(session.pinned) do return false end
    for _, path in pairs(session.paths) do return false end

    return true
end


function fsm.newSession()
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
    fsm.sessions[name] = {
        description=description,
        pinned={},
        paths={'/Users/Otanan'},
    }
    session = fsm.sessions[name]
    -- Set focus
    session.focus = session.pinned[0]

    -- Open this session
    fsm.open(session)
    -- Remake chooser to reflect this new session option
    fsm.newChooser()
end


-- Load the given session
function fsm.open(name)
    -- Get focus
    hs.application.launchOrFocus('Finder')

    session = fsm.sessions[name]
    -- Nothing to change
    if session == fsm.active then
        alert('Session already open.')
        print('Session unchanged.')
        do return end
    end

    -- Changing session ----------

    -- Update current session before changing
    if fsm.active ~= nil then fsm.update() end

    print('Loading session: ' .. session.name)

    paths = helper.list.join(session.pinned, session.paths)
    jxa.setFinderTabs(paths, session.focus)
    
    fsm.active = session
    fsm.softUpdate()
    -- Padding
    print()
end


-- Discontinue tab tracking
function fsm.detach()
    fsm.update()
    fsm.active = nil
    alert('Session detached.')
    fsm.softUpdate()
end



-- Updating -------------------------------------------------
--- Function
--- Updates all relevant information. Typically done on focus change or before
--- changing sessions. Will save fsm state to file.
function fsm.update()
    if fsm.active == nil then
        print('No active session...')
        return
    end

    local paths, focus = table.unpack(jxa.getFinderPaths(finder))

    local activePaths = fsm.active.paths
    local activePinned = fsm.active.pinned
    fsm.active.focus = focus

    -- Clear old paths
    helper.table.clear(activePaths)
    -- Update paths, skip activePinned paths
    for _, path in pairs(paths) do
        if not helper.table.has(activePinned, path) then
            table.insert(activePaths, path)
        end
    end

    -- Update the actual file
    helper.json.dump(fsm.settings, 'settings')
    print('Settings updated.')
end


--- Function
--- Update views while not updating settings file. Useful for things like
--- updating menubar for a new session being opened, which wouldn't need a file
--- update.
function fsm.softUpdate()
    fsm.updateMenu()
end


-- Chooser -------------------------------------------------
-- Choice function for chooser
local function chosen(choice)
    -- Get focus regardless
    hs.application.launchOrFocus('Finder')

    if choice == nil then
        print('No choice made.')
    elseif choice.uuid ~= nil then
        -- Cases based on identifier
        if choice.uuid == '__new__' then
            fsm.newSession()
        end
    else 
        fsm.open(choice.text)
    end
end


function fsm.newChooser()
    local choices = {}

    -- Menu options --------------------------
    table.insert(choices, {
        text='New session',
        subText='Create a new finder session.',
        -- ID for identifying when a menu function is called
        uuid='__new__'
    })
    local numChoices = 1

    -- Create choices
    for _, session in pairs(fsm.sessions) do
        numChoices = numChoices + 1

        local desc = session.description
        if desc == nil then desc = '' end

        table.insert(choices, {
            text=session.name,
            subText=desc,
        })
    end

    -- Make the chooser
    fsm.chooser = hs.chooser.new(chosen)

    -- Customize the chooser
    fsm.chooser:choices(choices)
    fsm.chooser:searchSubText(true)
    -- Add one for padding
    if numChoices < 5 then
        fsm.chooser:rows(numChoices + 1)
    else
        fsm.chooser:rows(6)
    end
    fsm.chooser:bgDark(true)
end


-- Menu -------------------------------------------------
fsm.menubar = hs.menubar.new()
fsm.menubar:setClickCallback(function() fsm.chooser:show() end)

function fsm.updateMenu()
    local state = fsm.active.name
    if state == nil then state = 'None' end

    fsm.menubar:setTitle('FSM: ' .. state)
end


-- Exit -------------------------------------------------
return fsm