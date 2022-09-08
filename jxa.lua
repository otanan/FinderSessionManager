--- === jxa.lua ===
--- Author: Jonathan Delgado
---
--- Add additional functionality through JXA.
---
-- Module object
jxa = {}


-- Common functionality -------------------------------------------------
jxa.functions = {}
-- Base to every JXA call
local jxaBase = [[
    const finder = Application('Finder');
    finder.includeStandardAdditions = true;

    // Get current finder path in given window
    function pathFromWindow(window) {
        // Gives file://...
        let fileURLString = window.target().url();
        // Convert to standard path
        return $.NSURL.alloc.initWithString(fileURLString).fileSystemRepresentation
    }
]]


jxa.functions.openPathInTab = [[
    function openPathInTab(path) {
        path = path.replace(' ', '\%%20'); // fix spaces
        finder.openLocation('file://' + path);
    }
]]


-- Functions -------------------------------------------------

--- Function
--- Gets the directory each finder window is currently in as well as the window 
--- in focus.
---
--- Returns:
---  * returns a table of list of 2 items, the first item being a list of paths
---  the second being a string of the path the focus window is on.
function jxa.getFinderPaths()
    local command = jxaBase .. [[
        // Get all finder paths through all windows
        function getPaths() {
            let paths = [];
            let windows = finder.finderWindows();
            for (let window of windows) paths.push(pathFromWindow(window));
            // First path is focus path
            return [paths, pathFromWindow(windows[0])]
        }

        // Run the script
        getPaths();
    ]]

    _, data = hs.osascript.javascript(command)
    return data
end


function jxa.getFocusedFinderPath()
    local command = jxaBase .. [[
        let windows = finder.finderWindows();
        pathFromWindow(windows[0]);
    ]]

    _, data = hs.osascript.javascript(command)
    return data
end


function convertPathsListToPathString(paths)
    pathString = ''
    for _, path in pairs(paths) do
        pathString = pathString .. '"' .. path .. '"' .. ', '
    end
    return pathString
end


function jxa.openPath(path)
    -- Call the function
    local command = jxaBase .. jxa.functions.openPathInTab .. [[
        openPathInTab("%s");
    ]]
    -- Run the command
    hs.osascript.javascript(string.format(command, path))
end


function jxa.setFinderTabs(paths, focus)
    local command = jxaBase .. [[
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

    ]] .. jxa.functions.openPathInTab .. [[

        // Sets the paths while preserving the current open window
        function setTabs(paths) {
            finder.activate(); // get focus
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
        if (focus.length !== 0)
            openPathInTab(focus);
    ]]
    local pathString = convertPathsListToPathString(paths)
    print(string.format(command, pathString, focus))
    -- Run the command
    x = hs.osascript.javascript(string.format(command, pathString, focus))
    print(x)
end



-- Exit -------------------------------------------------
return jxa