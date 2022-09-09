--- === file.lua ===
--- Author: Jonathan Delgado
---
--- General file IO operations.
---
-- Module object
local file = {}
-- Imports ----------
local shell = require(fsmPackagePath .. 'scripts.shell')



function file.delete(path)
    print('Deleting: ' .. path)
    shell.run('rm ' .. path)
end


function file.copy(oldPath, newPath)
    shell.run('cp ' .. oldPath .. ' ' .. newPath)
end


-- Converts a path to a filename, i.e. folder/image.png will be image.png
--- Function
--- Pulls the file name from a path. i.e. images/screenshot.png will return
--- screenshot.png
---
--- Parameters:
---  * path - string of the full path.
---
--- Returns:
---  * filename string
function file.name(path) return path:match("^.+/(.+)$") end


--- Function
--- Gets the full path to a parent folder containing a given file.
--- i.e. images/file.txt will return images/
--- 
--- Parameters:
---  * path - string of the full path.
---
--- Returns:
---  * string representing the folder path
function file.folderPath(path) return path:match('(.*/)') end


--- Function
--- Renames a given file.
---
--- Parameters:
---  * path - string of the full file path.
---  * newName - the new name for the file (not the full path).
---
--- Returns:
---  * returns the new full file path.
function file.rename(path, newName)
    local newPath = file.folderPath(path) .. newName
    shell.run('mv ' .. path .. ' ' .. newPath)
    return newPath
end


-- Exit -------------------------------------------------
return file