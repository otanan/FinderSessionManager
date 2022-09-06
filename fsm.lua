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
    local default = fsm.settings.default
    -- Must use __null__ since json is deleting null for some reason
    if default == '__null__' then
        fsm.active = nil
    else
        fsm.open(default)
    end
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
    return  helper.table.isEmpty(session.pinned)
        and helper.table.isEmpty(session.paths)
end

--- Function
--- Checks whether there no pins for the active session.
---
--- Returns:
---  * true if the session is either detached or if it has no pins, false
--- otherwise.
function fsm.activeHasNoPins()
    return fsm.active == nil or helper.table.isEmpty(fsm.active.pinned)
end


function fsm.addPinToActive(pin)
    if fsm.active == nil then
        print('No active to add pin.')
        return
    end

    -- Init an empty table if there are no existing pins
    -- if fsm.activeHasNoPins() then fsm.active.pinned = {} end

    table.insert(fsm.active.pinned, pin)
    alert(pin .. ' pinned.')
    print(pin .. ' pinned.')
end


function fsm.removePinFromActive(pinToRemove)
    if fsm.activeHasNoPins() then return end

    for key, pin in pairs(fsm.active.pinned) do
        -- Remove the first instance of the pin
        if pin == pinToRemove then
            fsm.active.pinned[key] = nil
            print('Pin' .. pin .. ' removed.')
            alert('Pin' .. pin .. ' removed.')
            return
        end
    end
end


function fsm.newSession()
    -- Prompt user for input
    local cancelText = 'Cancel'
    -- Name input ----------
    buttonText, name = hs.dialog.textPrompt(
        'New session name',
        'Please input a name for the new session.',
        '', '', cancelText
    )

    if buttonText == cancelText then
        print('New session canceled')
        return
    end

    if name == '' then
        alert('No session name provided.')
        print('New session canceled.')
        return
    end

    -- Description input ----------
    buttonText, description = hs.dialog.textPrompt(
        'New session description: ',
        'Provide a description for ' .. name .. ' session.'
    )

    if buttonText == cancelText then
        alert('New session canceled.')
        print('New session canceled')
        return
    end

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
        print('No active session.')
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
    image = hs.image.imageFromURL('https://cdn.pixabay.com/photo/2021/02/25/14/12/rinnegan-6049194_960_720.png')


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
            image=image,
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
fsm.menu = {}
fsm.menu.bar = hs.menubar.new()

-- Menu table creation --------------------------
function fsm.menu.newSession()
    return { title='New Session', fn=fsm.newSession }
end


function fsm.menu.addPin()
    local title = 'Pin path'
    if fsm.active == nil then
        return { title=title, disabled=true }
    end

    -- Open a file explorer to choose a new pin
    local function browserForPin()
        local paths = hs.dialog.chooseFileOrFolder(
            'this is a message',
            '', true, true, false
        )

        -- Keys are strings for some reason
        path = paths['1']

        -- Allow multiple selection is false, there will only be one path
        fsm.addPinToActive(path)
        -- Open path
        jxa.openPath(path)
    end

    return { title=title, fn=browserForPin }
end

function fsm.menu.removePins()
    local removePinsTable
    if fsm.activeHasNoPins() then
        return {
            title='Remove pins',
            disabled=true
        }   
    end 

    -- Valid active session with pins
    local pinsTable = {}
    for _, pin in pairs(fsm.active.pinned) do
        table.insert(pinsTable, {
            title=pin,
            fn=function(_, pin) fsm.removePinFromActive(pin.title) end
        })
    end

    return {
        title='Remove pins',
        menu=pinsTable,
    }
end


local function setMenu(keys)
    if keys.alt then
        alert('alt modifier was pressed')
        fsm.chooser:show()
        return
    end

    -- Table setup ----------
    return {
        fsm.menu.newSession(),
        { title='-' }, -- separator
        fsm.menu.addPin(),
        fsm.menu.removePins(),
     }
end
fsm.menu.bar:setMenu(setMenu)



function fsm.updateMenu()
    local state
    if fsm.active == nil then
        state = 'None'
    else
        state = fsm.active.name
    end

    fsm.menu.bar:setTitle('FSM: ' .. state)
end


-- Exit -------------------------------------------------
return fsm