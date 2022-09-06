-------------------------------------------------------------------------------
------------------------- Management System -------------------------
-------------------------------------------------------------------------------


-- Load the given session
function openSession(session)
    -- Get focus
    hs.application.launchOrFocus('Finder')

    if session == currentSession then
        alert('Session already open.')
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


    setTabsWithPathArrayStrings(pinnedPathString, pathString, getFocus(session))
    currentSession = session
    -- Padding to indicate complete session
    print()
end


function setTabsWithPathArrayStrings(pinnedPathString, pathString, focus)
    -- Fix empty strings throwing errors with format
    if pathString == '' then pathString = ' ' end
    if pinnedPathString == '' then pinnedPathString = ' ' end
    command = string.format(
        jxaSetTabsCommand, pinnedPathString, pathString, focus
    )
    hs.osascript.javascript(command)
end


-- Update the sessions dictionary then the settings file
function updateSessions()
    -- alert("Updating finder session...") 
    local data = getOpenFinderPaths(finder)
    paths = data[1]
    focus = data[2]

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

    -- Set focus path
    setFocus(currentSession, focus)

    -- Update the actual file
    updateSettings()
end


-- Get the paths currently open in finder as an array and the focused path
-- Returns a table with two elements, the paths, and the focus path
function getOpenFinderPaths()
    _, data = hs.osascript.javascript(jxaGetPathsCommand)
    return data
end


function closeFinderWindows()
    -- Get focus for menu item
    hs.application.launchOrFocus('Finder')
    finder:selectMenuItem({'File', 'Close Window'})
end


-- Discontinue tab tracking
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
