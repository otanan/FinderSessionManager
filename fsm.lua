--- === fsm.lua ===
--- Author: Jonathan Delgado
---
--- FinderSessionManager
---
-- Module object
local fsm = {}
-- Imports ----------
local helper = require(fsmPackagePath .. 'helper')
local strloop = helper.table.strloop
-- Resource handling
local res = require(fsmPackagePath .. 'res')
-- Finder interactions
fsm.finder = require(fsmPackagePath .. 'finder')


-- Initialization -------------------------------------------------
function fsm.init()
    -- Settings init ----------
    print('Loading FSM settings...')
    fsm.settings = res.settings.load()
    -- Running state, disable functionality when not running
    fsm.sessions = fsm.settings.sessions

    -- Set default flag values ----------
    fsm.running = true
    if fsm.settings.hideWithFocusLoss == nil then
        fsm.settings.hideWithFocusLoss = false
    end

    -- Set the active session
    -- Must use boolean since json is deleting null for some reason
    if not fsm.settings.default then
        fsm.active = nil
    else
        fsm.open(default)
    end

    -- GUI init ----------C
    fsm.newChooser()
    -- Refresh the menu to reflect changes
    fsm.softUpdate()
end


-- Inspecting FSM -------------------------------------------------
-- Inspect fsm properties such as the active session, checking
-- whether the session is empty, etc.


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


--- Checks whether there no pins for the active session.
---
--- Returns:
---  * true if the session is either detached or if it has no pins, false
--- otherwise.
function fsm.activeHasNoPins()
    return fsm.active == nil or helper.table.isEmpty(fsm.active.pinned)
end


-- Returns whether the active session is the default session
function fsm.activeIsDefault()
    if fsm.active == nil then return fsm.settings.default == '__null__' end

    return fsm.active.name == fsm.settings.default
end


-- Edit Sessions -------------------------------------------------
-- Changing session properties such as pinning paths, renaming it, etc.


function fsm.addPinToActive(pin)
    if fsm.active == nil then
        print('No active to add pin.')
        return
    end

    -- Check if already pinned
    if helper.table.has(fsm.active.pinned, pin) then
        alert(pin .. ' already pinned.')
        print(pin .. ' already pinned.')
        return
    end

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
            print('Pin ' .. pin .. ' removed.')
            alert('Pin ' .. pin .. ' removed.')
            return
        end
    end
end


function fsm.renameActive(name)
    if name == '' then
        print('Rename session canceled.')
        return
    end

    if name == fsm.active.name then
        print('Name is identical. Nothing changed.')
        return
    end

    -- Update settings ----------
    -- Store information under new name
    local oldName = fsm.active.name 
    print('Renaming Session: ' .. oldName .. ' -> ' .. name)
    alert('Renaming Session: ' .. oldName .. ' -> ' .. name)
    fsm.active.name = name -- rename active
    fsm.sessions[name] = fsm.active -- copy information
    fsm.sessions[oldName] = nil -- delete old session

    -- Update settings
    fsm.update()
    -- Remake chooser to reflect this new session option
    fsm.newChooser()
end


-- Delete active session
function fsm.deleteActive()
    if fsm.active == nil then return end

    fsm.sessions[fsm.active.name] = nil
    fsm.detach()
    -- Remake the chooser to reflect new options
    fsm.newChooser()
end


-- FSM -------------------------------------------------
-- Creating sessions, opening sessions, detaching sessions.


function fsm.newSession()
    -- Prompt user for input
    local cancelButtonLabel = 'Cancel'
    -- Name input ----------
    local buttonLabel, name = hs.dialog.textPrompt(
        'New session name',
        'Please input a name for the new session.',
        '', '', cancelButtonLabel
    )

    if buttonLabel == cancelButtonLabel then
        print('New session canceled')
        return
    end

    if name == '' then
        alert('No session name provided.')
        print('New session canceled.')
        return
    end

    -- Description input ----------
    local buttonLabel, description = hs.dialog.textPrompt(
        'New session description: ',
        'Provide a description for ' .. name .. ' session.'
    )

    if buttonLabel == cancelButtonLabel then
        alert('New session canceled.')
        print('New session canceled')
        return
    end
    alert(description)

    -- Update the settings
    -- Default to home folder
    fsm.sessions[name] = {
        name=name,
        description=description,
        pinned={},
        paths={'/Users/Otanan'},
    }
    local session = fsm.sessions[name]
    -- Set focus
    session.focus = session.paths[0]

    -- Open this session
    fsm.open(name)
    -- Remake chooser to reflect this new session option
    fsm.newChooser()
end


-- Load the given session
function fsm.open(name)
    -- Update current session before changing
    if fsm.active ~= nil then fsm.update() end

    -- Get focus, if window was closed the home directory won't be saved
    -- since update was already called
    fsm.finder.open()

    local session = fsm.sessions[name]
    print('Loading session: ' .. session.name)

    -- Paths to open
    local allPaths = helper.table.concatArray(session.pinned, session.paths)

    if helper.table.isEmpty(allPaths) then
        -- The session had nothing open and nothing pinned, just default to
        -- home directory.
        print('Session has no associated paths... defaulting to Home.')
        alert('Session has no paths... defaulting to Home.')
        allPaths = { os.getenv('HOME') }
    end
    fsm.finder.setPaths(allPaths, session.focus)

    fsm.active = session
    fsm.softUpdate()
    -- Padding
    print()
end


-- Show the FSM, which is currently just showing the chooser
function fsm.show() if fsm.running then fsm.chooser:show() end end



-- Discontinue tab tracking
function fsm.detach()
    if not fsm.running then return end
    fsm.update()
    fsm.active = nil
    alert('Session detached.')
    fsm.softUpdate()
end


-- Updating -------------------------------------------------

--- Helper function which sees which open paths are already pinned.
-- Goes through the collection of open paths to inspect whether it
-- is pinned and hence already accounted for versus which is a new tab
-- to with the session. Updates settings directly.
-- @param paths array: paths to compare with the active pins.
-- @return array: the paths to store as proper sessions.
local function compareOpenPathsWithPinned(paths)
    local pathsToKeep = {}
    -- Boolean dictionary which uses the pin as a key and a value of
        -- whether the pin has been accounted for
    local pinLegend = {}

    for _, pin in ipairs(fsm.active.pinned) do
        pinLegend[pin] = false

    end

    -- Update paths, skip activePinned paths
    for i, path in ipairs(paths) do
        print(path)
        local pinCase = pinLegend[path]
        if pinCase == nil then
            -- Path isn't pinned, keep it
            table.insert(pathsToKeep, path)
        else
            if pinCase then
                -- This path was accounted for as a pin, this is another
                -- instance of the same tab, we need to keep it
                table.insert(pathsToKeep, path)
            else 
                -- This is the first instance of this pinned path
                -- mark it in case duplicates exist.
                pinLegend[path] = true
            end
        end
    end

    return pathsToKeep
end


--- Function
--- Updates all relevant information. Typically done on focus change or before
--- changing sessions. Will save fsm state to file.
function fsm.update()
    -- TESTING
    fsm.finder.getPaths()
    if fsm.active == nil then
        print('No active session.')
        return
    end

    -- Get Finder paths and process data ----------
    local paths, focus
    local data = fsm.finder.getPaths()
    if data == nil then
        -- No finder windows opened
        paths = {}
        focus = ''
    else
        paths = data.paths
        focus = data.focus
    end
    -- Update the focus and paths
    fsm.active.paths = compareOpenPathsWithPinned(data.paths)
    fsm.active.focus = focus
    -- Pass boolean of whether the settings should be pretty printed
    res.settings.update(fsm.settings, fsm.debugging)
end


--- Function
--- Update views while not updating settings file. Useful for things like
--- updating menubar for a new session being opened, which wouldn't need a file
--- update.
function fsm.softUpdate()
    fsm.menu.update()
end


-- Chooser -------------------------------------------------
-- Choice function for chooser
local function chosen(choice)
    -- Get focus (if a window exists) regardless of choice
    if fsm.finder.isOpen() then fsm.finder.focus() end

    if choice == nil then
        print('No choice made.')
        -- Get focus for detached session
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

        local image
        if session.image ~= nil then
            image = res.images.load(session.image)
        end

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
    local rows = 7
    if numChoices < 5 then rows = numChoices + 1 end
    fsm.chooser:rows(rows)
    fsm.chooser:bgDark(true)
end


-- Menu -------------------------------------------------
fsm.menu = {}
fsm.menu.bar = hs.menubar.new()

-- Menu table creation --------------------------
function fsm.menu.newSession()
    return { title='New Session...', fn=fsm.newSession }
end


function fsm.menu.changeSession()
    local title = 'Change Session'
    if helper.table.isEmpty(fsm.sessions) then
        return {
            title=title,
            disabled=true
        }
    end

    local sessionNames = {}
    for _, session in pairs(fsm.sessions) do
        table.insert(sessionNames, {
            title=session.name,
            fn=function(_, choice) fsm.open(choice.title) end
        })
    end

    return {
        title=title,
        menu=sessionNames,
    }
end


function fsm.menu.detachSession()
    local title = 'Detach Session'
    if fsm.active == nil then
        return { title=title, disabled=true }
    end
    return { title=title, fn=fsm.detach }
end


function fsm.menu.deleteActiveSession()
    local title = 'Delete Active Session'
    if fsm.active == nil then return { title=title, disabled=true } end

    local function deleteActiveSessionPrompt()
        local confirmButtonLabel = 'Confirm'

        buttonLabel = hs.dialog.blockAlert(
            'Delete: ' .. fsm.active.name,
            '',
            confirmButtonLabel, 'Cancel'
        )

        if buttonLabel == confirmButtonLabel then fsm.deleteActive() end
    end

    return { title=title, fn=deleteActiveSessionPrompt }
end


function fsm.menu.addPin()
    local title = 'Pin Path...'
    if fsm.active == nil then return { title=title, disabled=true } end

    -- Open a file explorer to choose a new pin
    local function browserForPin()
        local paths = hs.dialog.chooseFileOrFolder(
            'Choose path to pin', '', true, true, false
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


function fsm.menu.pinFocused()
    local title = 'Pin Focused Tab'
    if fsm.active == nil then return { title=title, disabled=true } end

    -- Open a file explorer to choose a new pin
    local function getFocusedAndPin()
        local focusedPath = jxa.getFocusedFinderPath()
        fsm.addPinToActive(focusedPath)
    end

    return { title=title, fn=getFocusedAndPin }
end


function fsm.menu.removePins()
    local title = 'Remove Pins'
    local removePinsTable
    if fsm.activeHasNoPins() then
        return {
            title=title,
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
        title=title,
        menu=pinsTable,
    }
end


function fsm.menu.renameActive()
    local title = 'Rename Session...'
    if fsm.active == nil then return { title=title, disabled=true } end


    -- Function for parsing the input
    local function renameActivePrompt() 
        local cancelButtonLabel = 'Cancel'
        -- Name input ----------
        local buttonLabel, name = hs.dialog.textPrompt(
            'New session name',
            'Please input a name for the new session.',
            '', '', cancelButtonLabel
        )

        if buttonLabel == cancelButtonLabel then
            print('Rename canceled.')
            return
        end

        -- Name submitted
        fsm.renameActive(name)
    end 


    return { title=title, fn=renameActivePrompt }
end


-- function fsm.menu.editSessionDescription()

-- end


function fsm.menu.setSessionIcon()
    local title = 'Set Session Icon'
    if fsm.active == nil then
        return { title=title, disabled=true }
    end

    local function getImageForIcon()
        local path = res.images.chooseFromFileSystem()

        -- Canceled icon choice.
        if path == nil then return end

        -- Delete any existing icons
        if fsm.active.image ~= nil then
            local oldPath = res.images.getSavedPath(fsm.active.image)
            helper.file.delete(oldPath)
        end

        -- Save the image 
        local imageName = res.images.save(path)
        local image = res.images.load(imageName)

        fsm.active.image = imageName
        -- Save result to file
        fsm.update()
        -- Update the chooser to show the image
        fsm.newChooser()

        alert('Session icon updated.')
    end

    return { title=title, fn=getImageForIcon }
end


function fsm.menu.setSessionDefault()
    local title = 'Set as Default Session'

    if fsm.activeIsDefault() then return { title=title, disabled=true } end

    local function setActiveSessionAsDefault()
        if fsm.active == nil then
            fsm.settings.default = '__null__'
            -- Need to update settings here since settings aren't usually
                -- updated when session is detached
            res.settings.update(fsm.settings, fsm.debugging)
        else fsm.settings.default = fsm.active.name end

        -- Logging
        alert('Default updated.')
        print('Changing default to: ' .. default)
    end

    
    return { title=title, fn=setActiveSessionAsDefault }
end


function fsm.menu.quit()
    return { title='Quit', fn=fsm.quit }
end


-- Create the menu --------------------------
local function setMenu(keys)
    if keys.alt then
        -- Just show the search when clicking with Alt modifier
        fsm.chooser:show()
        -- Don't open the menu
        return {}
    end

    -- Table setup ----------
    return {
        fsm.menu.newSession(),
        fsm.menu.changeSession(),
        fsm.menu.detachSession(),
        fsm.menu.deleteActiveSession(),
        { title='-' }, -- separator
        fsm.menu.renameActive(),
        -- fsm.menu.editSessionDescription(),
        fsm.menu.setSessionIcon(),
        fsm.menu.setSessionDefault(),
        { title='-' },
        fsm.menu.addPin(),
        fsm.menu.pinFocused(),
        fsm.menu.removePins(),
        { title='-' },
        fsm.menu.quit(),
     }
end
fsm.menu.bar:setMenu(setMenu)



function fsm.menu.update()
    local state, image
    if fsm.active == nil then
        state = 'None'
    else
        state = fsm.active.name
        image = fsm.active.image
    end

    fsm.menu.bar:setTitle('FSM: ' .. state)
    -- if image ~= nil then
    --     fsm.menu.bar:setIcon(res.images.load(image):setSize({w=16,h=16}))
    -- end
end


function fsm.menu.show()
    fsm.menu.bar:returnToMenuBar()
    fsm.menu.update()
end


function fsm.menu.hide()
    fsm.menu.bar:removeFromMenuBar()
end


-- Exit -------------------------------------------------
return fsm