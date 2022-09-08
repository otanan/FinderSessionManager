--- === json.lua ===
--- Author: Jonathan Delgado
---
--- Basic JSON operations.
---
-- Module object
local jsonModule = {}
-- Imports ----------
-- JSON for Luna, wrapping around this module
local json = require('lunajson')


-- Convert the file name to a proper relative path
function jsonModule.nameToPath(fname) return workingDir .. fname .. '.json' end


function jsonModule.load(fname)
    local jsonFile = io.open(jsonModule.nameToPath(fname), 'r')
    -- No file found
    if jsonFile == nil then return nil end
    local jsonData = jsonFile:read('*a')
    local jsonAsTable = json.decode(jsonData)
    jsonFile:close()
    return jsonAsTable
end


function jsonModule.dump(tab, fname)
    local jsonData = json.encode(tab)
    local jsonFile = assert(io.open(jsonModule.nameToPath(fname), 'w'))
    jsonFile:write(jsonData)
    jsonFile:close()
    -- Prettify the json
    -- hs.execute('python3 ' .. workingDir .. 'json_pretty.py ' .. workingDir .. fname)
end


-- Exit -------------------------------------------------
return jsonModule