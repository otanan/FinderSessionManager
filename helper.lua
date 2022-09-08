--- === helper.lua ===
--- Author: Jonathan Delgado
---
--- Helper scripts that provides basic programmatic functionality.
--- This module should be logically independent of FSM.
---
-- Module object
local helper = {}
local json = require('lunajson')


-- Table operations -------------------------------------------------
helper.table = {}
helper.list = {}
-- Check if value exists in table
function helper.table.has(tab, val)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end


-- Clear a table
function helper.table.clear(tab)
    for key in pairs(tab) do tab[key] = nil end
end


-- Check if table is empty
local next = next -- optimization by localizing next function
function helper.table.isEmpty(tab) return next(tab) == nil end


-- Concatenate two arrays
function helper.list.join(tab1, tab2)
    joinedTable = {}

    for _, value in pairs(tab1) do table.insert(joinedTable, value) end
    for _, value in pairs(tab2) do table.insert(joinedTable, value) end

    return joinedTable
end


-- File Operations -------------------------------------------------
helper.file = {}


function helper.file.delete(path)
    print('Deleting: ' .. path)
    hs.execute('rm ' .. path)
end


function helper.file.copy(oldPath, newPath)
    hs.execute('cp ' .. oldPath .. ' ' .. newPath)
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
function helper.file.name(path) return path:match("^.+/(.+)$") end


--- Function
--- Gets the full path to a parent folder containing a given file.
--- i.e. images/file.txt will return images/
--- 
--- Parameters:
---  * path - string of the full path.
---
--- Returns:
---  * string representing the folder path
function helper.file.folderPath(path) return path:match('(.*/)') end


--- Function
--- Renames a given file.
---
--- Parameters:
---  * path - string of the full file path.
---  * newName - the new name for the file (not the full path).
---
--- Returns:
---  * returns the new full file path.
function helper.file.rename(path, newName)
    local newPath = helper.file.folderPath(path) .. newName
    hs.execute('mv ' .. path .. ' ' .. newPath)
    return newPath
end


-- JSON -------------------------------------------------
helper.json = {}


-- Convert the file name to a proper relative path
function helper.json.nameToPath(fname) return workingDir .. fname .. '.json' end


function helper.json.load(fname)
    local jsonFile = io.open(helper.json.nameToPath(fname), 'r')
    -- No file found
    if jsonFile == nil then return nil end
    local jsonData = jsonFile:read('*a')
    local jsonAsTable = json.decode(jsonData)
    jsonFile:close()
    return jsonAsTable
end


function helper.json.dump(tab, fname)
    local jsonData = json.encode(tab)
    local jsonFile = assert(io.open(helper.json.nameToPath(fname), 'w'))
    jsonFile:write(jsonData)
    jsonFile:close()
    -- Prettify the json
    -- hs.execute('python3 ' .. workingDir .. 'json_pretty.py ' .. workingDir .. fname)
end


-- Exit -------------------------------------------------
return helper