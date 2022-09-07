--- === finderLink.lua ===
--- Author: Jonathan Delgado
---
--- Provides Finder link to Finder and additional functionality.
---
-- Module object
module = {}

-- Finder app local to this module
local finder = hs.appfinder.appFromName('Finder')


-- Finder -------------------------------------------------
function module.isOpen()
    local main = finder:mainWindow()
    if main == nil then return false end

    return finder:mainWindow():title() ~= ''
end

-- Get focus, does not open new window if none exists
function module.focus() finder:activate() end


function module.open() hs.application.launchOrFocus('Finder') end


-- Exit -------------------------------------------------
return module