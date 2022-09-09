--- === json.lua ===
--- Author: Jonathan Delgado
---
--- Basic JSON operations.
---
-- Module object
local jsonModule = {}
-- Imports ----------
local python = require(fsmPackagePath .. 'scripts.python')
-- JSON for Luna, wrapping around this module
local json = require('lunajson')

-- Convert the file name to a proper relative path
function jsonModule.nameToPath(fname) return fsmPackagePath .. fname .. '.json' end


function jsonModule.load(fname)
    local jsonFile = io.open(jsonModule.nameToPath(fname), 'r')
    -- No file found
    if jsonFile == nil then return nil end
    local jsonData = jsonFile:read('*a')
    local jsonAsTable = json.decode(jsonData)
    jsonFile:close()
    return jsonAsTable
end


function jsonModule.dump(tab, fname, readable)
    local jsonData = json.encode(tab)
    local jsonFile = assert(io.open(jsonModule.nameToPath(fname), 'w'))
    jsonFile:write(jsonData)
    jsonFile:close()
    -- Prettify the json
    if readable then
        jsonModule.makeReadable(fsmPackagePath .. fname)
    end
end


-- Make json files readable
function jsonModule.makeReadable(path)
    python.runFile(fsmPackagePath .. 'scripts/readable_json.py', path)
end


-- Exit -------------------------------------------------
return jsonModule