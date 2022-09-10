--- === finderLink.lua ===
--- Author: Jonathan Delgado
---
--- Provides link to Finder and additional functionality.
---
-- Module object
local finder = {}
-- Imports ----------
local helper = require(fsmPackagePath .. 'helper')
local strloop = helper.table.strloop
-- Current implementation of most finder interactions makes use of JXA
local jxa = require(fsmPackagePath .. 'scripts.jxa')
local scripts = require(fsmPackagePath .. 'scripts')

-- Finder app local to this module
local finderApp = hs.appfinder.appFromName('Finder')


-- Focus -------------------------------------------------
function finder.isOpen()
    local mainWindow = finderApp:mainWindow()
    if mainWindow == nil then return false end

    return mainWindow:title() ~= ''
end

-- Get focus, does not open new window if none exists
function finder.focus() finderApp:activate() end


function finder.open() hs.application.launchOrFocus('Finder') end


-- Tabs -------------------------------------------------
-- JXA --------------------------
-- Table for jxa command uses to implement finder interactions
local jxaStrings = {}
-- Base to every JXA call
jxaStrings.base = [[
    const finder = Application('Finder');
    finder.includeStandardAdditions = true;
]]
-- Store commonly used function commands
jxaStrings.fn = {}
jxaStrings.fn.pathFromWindow = [[
    function pathFromWindow(window) {
        let target = window.target();
        // Gives file://...
        try { var url = target.url(); } catch {
            // Cannot access .url(), such as in network drive
            return null;
        }
        // Convert to standard path
        return $.NSURL.alloc.initWithString(url).fileSystemRepresentation
    }
]]
jxaStrings.fn.openPathInTab = [[
    function openPathInTab(path) {
        path = path.replace(' ', '\%%20'); // fix spaces
        finder.openLocation('file://' + path);
    }
]]
-- AppleScript --------------------------
local appleStrings = {}
-- Store commonly used function commands
appleStrings.fn = {}
-- Make the new tab
-- Changes target of new tab since new window defaults to a target that
-- is currently unreadable for jxa, so we avoid issues with this
appleStrings.fn.newTab = [[
    tell application "Finder" to make new Finder window to home
]]



-- Implementations --------------------------
function finder.openPath(path)
    local codeString = jxaStrings.base .. jxaStrings.fn.openPathInTab .. [[
        openPathInTab("%s");
    ]]
    -- Run the formatted string
    jxa.run(string.format(codeString, path))
end


function finder.getFocusedPath()
    local codeString = jxaStrings.base .. jxaStrings.fn.pathFromWindow .. [[
        let windows = finder.finderWindows();
        // No open window to get focus for
        if (windows.length > 0) pathFromWindow(windows[0]);
    ]]

    return jxa.run(codeString)
end


--- Gets the cwd of each finder window.
-- Gets a focused window and manipulates tabs in order to get their order.
-- @return dict: key of focus gives the focused path as a string, and key of 
-- paths gives a list of path strings for each window in order of tab 
-- appearance.
function finder.getPaths()
    local codeString = jxaStrings.base .. jxaStrings.fn.pathFromWindow .. [[
        // Get all finder paths through all windows
        function getPaths() {
            let paths = [];
            let windows = finder.finderWindows();
            // No windows open
            if (windows.length == 0) return null;

            for (let window of windows) {
                let path = pathFromWindow(window)
                // Failed path retrieval, move on
                if (path == null) continue;
                paths.push(path);
            }
            return {
                'paths': paths,
                'focus': pathFromWindow(windows[0])
            }
        }

        // Run the script
        getPaths();
    ]]
    data = jxa.run(codeString)
    if data == nil then
        print('No open finder window to get paths for.')
        -- No open window
        data = { paths={}, focus='' }
    end
    return data
end


-- Helper function, converts list of path strings to a single string
-- Used for formatting code strings that will be parsed and will iterate 
-- through a list of paths
local function convertPathsListToPathString(paths)
    local numPaths = #paths
    if numPaths == 0 then return '' end

    local pathString = ''
    for i, path in strloop(paths) do
        if i == numPaths then break end
        pathString = pathString .. '"' .. path .. '"' .. ', '
    end
    -- No trailing comma
    return pathString .. '"' .. paths[numPaths] .. '"'
end


--- Changes all open finder windows and sets their cwd to the list of paths.
--
-- @param paths list: list of strings containing the paths to move to.
-- @param focus string: the path to focus the tab on.
function finder.setPaths(paths, focus)
    local codeString = jxaStrings.base .. [[
        let paths = [%s];
        let focus = "%s".trim();

        // Close tabs first
        function closeTabsButOne() {
            let windows = finder.finderWindows();
            let numWindows = windows.length;
            for (let i in windows) {
                // Close all but one, prevents need for resizing
                if (i == numWindows - 1) break;

                windows[i].close();
            }
            return windows[numWindows - 1];
        }

    ]] .. jxaStrings.fn.openPathInTab .. jxaStrings.fn.pathFromWindow .. [[

        // Sets the paths while preserving the current open window
        function setTabs(paths) {
            finder.activate(); // get app focus
            let lastTab = closeTabsButOne();
            let lastPath = pathFromWindow(lastTab);

            // Remove trailing '/' since lastPath will not have it, for comparison
            compPath = paths[0]
            if (compPath.slice(-1) == '/') compPath = compPath.slice(0, -1);

            // Check to see if remaining tab is the path we want already
                // if so, continue
            if (compPath !== lastPath) {
                // Make a new tab but remember to close this window
                openPathInTab(compPath);
                paths.shift();
                lastTab.close();
            }

            for (path of paths) openPathInTab(path);
        }

        setTabs(paths);
        // Draw focus by setting tab again
        if (focus.length !== 0) openPathInTab(focus);
    ]]
    local pathString = convertPathsListToPathString(paths)
    codeString = string.format(codeString, pathString, focus)
    print('Settings paths...')
    print(codeString)
    jxa.run(codeString)
end



-- Exit -------------------------------------------------
return finder