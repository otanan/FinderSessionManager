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
    if status == false then
        alert('Failed JXA execution.')
        print('Failed JXA execution.')
    end
    return result
end


-- Exit -------------------------------------------------
return jxa