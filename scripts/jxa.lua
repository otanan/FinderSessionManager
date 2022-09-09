--- === jxa.lua ===
--- Author: Jonathan Delgado
---
--- Add additional functionality through JXA.
---
-- Module object
local jxa = {}


-- Main functionality -------------------------------------------------
function jxa.run(codeString)
    local status, result = hs.osascript.javascript(codeString)
    if not status then
        alert('Failed JXA execution.')
        print('Failed JXA execution.')
        print('Printing failed script...')
        print(codeString)
    end
    return result
end


-- Exit -------------------------------------------------
return jxa