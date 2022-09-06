-------------------------------------------------------------------------------
------------------------- Helper through JXA -------------------------
-------------------------------------------------------------------------------


-- Base to every JXA call
jxaBase = [[
    var finder = Application('Finder');
    finder.includeStandardAdditions = true;

    // Get current finder path in given window
    function pathFromWindow(window) {
        // Gives file://...
        var fileURLString = window.target().url();
        // Convert to standard path
        return $.NSURL.alloc.initWithString(fileURLString).fileSystemRepresentation
    }
]]


jxaGetPathsCommand = jxaBase .. [[
    // Get all finder paths through all windows
    function getPaths() {
        var paths = [];
        var windows = finder.finderWindows();
        for (var window of windows) paths.push(pathFromWindow(window));
        // First path is focus path
        return [paths, pathFromWindow(windows[0])]
    }

    // Run the script
    getPaths();
]]


jxaSetTabsCommand = jxaBase .. [[
    var pinnedPaths = [%s];
    var paths = [%s];
    var focus = "%s"

    // Close all tabs first
    function closeTabsButOne() {
        var windows = finder.finderWindows();
        for (var i in windows) {
            // Close all but one, prevents need for resizing
            if (i == windows.length - 1) break;

            windows[i].close();
        }
        return windows[i];
    }


    function openPathInTab(path) {
        path = path.replace(' ', '\%%20'); // fix spaces
        console.log(path)
        finder.openLocation('file://' + path);
    }

    // Sets the paths while preserving the current open window
    function setTabs(paths) {
        finder.activate(); // get focus
        var lastTab = closeTabsButOne();
        var lastPath = pathFromWindow(lastTab);

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

    setTabs(pinnedPaths.concat(paths));
    // Draw focus by setting tab again
    openPathInTab(focus);
]]