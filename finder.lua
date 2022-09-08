--- === finderLink.lua ===
--- Author: Jonathan Delgado
---
--- Provides link to Finder and additional functionality.
---
-- Module object
local finder = {}

-- Current implementation of most finder interactions makes use of JXA
local jxa = require(workingDir .. 'jxa')
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
    // Get current finder path in given window
    function pathFromWindow(window) {
        // Gives file://...
        let fileURLString = window.target().url();
        // Convert to standard path
        return $.NSURL.alloc.initWithString(fileURLString).fileSystemRepresentation
    }
]]
jxaStrings.fn.openPathInTab = [[
    function openPathInTab(path) {
        path = path.replace(' ', '\%%20'); // fix spaces
        finder.openLocation('file://' + path);
    }
]]


-- Implementations --------------------------
function finder.openPath(path)
    local codeString = jxaBase .. jxaStrings.fn.openPathInTab .. [[
        openPathInTab("%s");
    ]]
    -- Run the formatted string
    jxa.run(string.format(codeString, path))
end


function finder.getFocusedPath()
    local codeString = jxaStrings.base .. jxaStrings.fn.pathFromWindow .. [[
        let windows = finder.finderWindows();
        pathFromWindow(windows[0]);
    ]]

    return jxa.run(codeString)
end


--- Gets the cwd of each finder window.
--
-- @return dictionary: a dictionary containing the paths list and the path of 
-- the focused window as strings.
function finder.getPaths()
    local codeString = jxaStrings.base .. jxaStrings.fn.pathFromWindow .. [[
        // Get all finder paths through all windows
        function getPaths() {
            let paths = [];
            let windows = finder.finderWindows();
            for (let window of windows) paths.push(pathFromWindow(window));
            return {
                'paths': paths,
                'focus': pathFromWindow(windows[0])
            }
        }

        // Run the script
        getPaths();
    ]]

    return jxa.run(codeString)
end


-- Helper function, converts list of path strings to a single js string
local function convertPathsListToPathString(paths)
    local pathString = ''
    for _, path in pairs(paths) do
        pathString = pathString .. '"' .. path .. '"' .. ', '
    end
    return pathString
end


--- Changes all open finder windows and sets their cwd to the list of paths.
--
-- @param paths list: list of strings containing the paths to move to.
-- @param focus string: the path to focus the tab on.
function finder.setPaths(paths, focus)
    local command = jxaStrings.base .. [[
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
    jxa.run(string.format(command, pathString, focus))
end



-- Exit -------------------------------------------------
return finder