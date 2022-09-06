--- === helper.lua ===
--- Author: Jonathan Delgado
---
--- Helper scripts that provides basic programmatic functionality.
---
-- Module object
helper = {}


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


-- Concatenate two arrays
function helper.list.join(tab1, tab2)
    joinedTable = {}

    for _, value in pairs(tab1) do table.insert(joinedTable, value) end
    for _, value in pairs(tab2) do table.insert(joinedTable, value) end

    return joinedTable
end


-- JSON -------------------------------------------------
helper.json = {}


-- Convert the file name to a proper relative path
function jsonFilename(fname) return workingDir .. fname .. '.json' end


function helper.json.load(fname)
    local jsonFile = io.open(jsonFilename(fname), 'r')
    local jsonData = jsonFile:read('*a')
    local jsonAsTable = json.decode(jsonData)
    jsonFile:close()
    return jsonAsTable
end


function helper.json.dump(tab, fname)
    local jsonData = json.encode(tab)
    local jsonFile = assert(io.open(jsonFilename(fname), 'w'))
    jsonFile:write(jsonData)
    jsonFile:close()
    -- Prettify the json
    hs.execute('python3 ' .. workingDir .. 'json_pretty.py ' .. workingDir .. fname)
end


-- Exit -------------------------------------------------
return helper