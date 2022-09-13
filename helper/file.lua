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


--- Checks whether a given path is a subfolder of another path.
-- Takes a path to a folder and checks if it contains the substring of the
-- parentFolder path.
-- @param path string: the folder to check.
-- @param path string: the potential parent folder.
-- @return boolean: true if path points to subfolder of parentFolder.
function file.isSubfolder(path, parentFolder)
    return path:match(parentFolder) ~= nil
end


--- Scores a path as being a subfolder to a given parent folder.
-- Assesses whether the folder pointed to by path is a descendant of the parent 
-- folder, and provides a score depending on how deep the child folder is.
-- @param path string: the potential child folder.
-- @param parentFolder string: the potential parent folder.
-- @return int: the score. Returns -1 if the path is not a subdirectory of the 
-- parentFolder, 0 if the path is exactly the parent folder, or a positive 
-- integer which represents the number of descendant folders of parentFolder 
-- are parent folders to path.
function file.scoreSubfolder(path, parentFolder)
    -- Remove the first instance of the subpath
    local subpath, count = string.gsub(path, parentFolder, '', 1)
    -- This is not a subpath of the parent folder
    if count == 0 then return -1 end
    -- Tests for case where path is similar to parentFolder but differ.
    -- i.e. parentFolder    = /Users/user/vi
    --      path            = /Users/user/vim
    -- path is not a child of parentFolder but will give a nonzero count
        -- for removal, so we test the first character.
    local firstChar = subpath:sub(1, 1)
    if firstChar ~= '/' and firstChar ~= '' then return -1 end

    -- Count the number of directories deep, this will be its score
    _, count = string.gsub(subpath, '/', '')
    return count
end


-- Exit -------------------------------------------------
return file