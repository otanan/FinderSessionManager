--- === table.lua ===
--- Author: Jonathan Delgado
---
--- Basic table operations.
---
-- Module object
local table_ = {}
-- Imports ----------


-- Check if value exists in table
function table_.has(tab, val)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end


-- Clear a table
function table_.clear(tab)
    for key in pairs(tab) do tab[key] = nil end
end


-- Check if table is empty
local next = next -- optimization by localizing next function
function table_.isEmpty(tab) return next(tab) == nil end


-- Concatenate two arrays
function table_.join(tab1, tab2)
    joinedTable = {}

    for _, value in pairs(tab1) do table.insert(joinedTable, value) end
    for _, value in pairs(tab2) do table.insert(joinedTable, value) end

    return joinedTable
end


-- Exit -------------------------------------------------
return table_