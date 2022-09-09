-- === applescript.lua ===
-- Author: Jonathan Delgado
--
-- Provides AppleScript functionality.
--
-- Module object
local apple = {}
-- Imports ----------


function apple.run(codeString)
    local status, result = hs.osascript.applescript(codeString)
    if not status then 
        alert('Failed AppleScript execution.')
        print('Failed AppleScript execution.')
        print('Printing failed script...')
        print(codeString)
    end
    return result
end


-- Exit -------------------------------------------------
return apple