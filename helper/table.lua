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
function table_.concatArray(list1, list2)
    joined = {}

    for _, value in ipairs(list1) do table.insert(joined, value) end
    for _, value in ipairs(list2) do table.insert(joined, value) end

    return joined
end


-- Copy arrays
function table_.copy(list)
    copy = {}
    for _, value in ipairs(list) do table.insert(copy, value) end
    return copy
end


-- Exit -------------------------------------------------
return table_