--- === table.lua ===
--- Author: Jonathan Delgado
---
--- Basic table operations.
---
-- Module object
local table_ = {}
-- Imports ----------


-- Tables -------------------------------------------------
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


--- Iterate through table with integer keys that are strings.
-- Provides ordered features of ipairs but for keys that are strings, i.e. 
-- {'1'=val}. Useful for json and jxa which returns tables with string keys.
-- @param tab table: the table to iterate through
-- @return function: the iterator.
function table_.strloop(tab)
    -- Convert to ordered table
    local tableWithIntKeys = {}
    for strkey, val in pairs(tab) do
        tableWithIntKeys[tonumber(strkey)] = val
    end

    local function iterator(list, i) return next(list, i) end
    return iterator, tableWithIntKeys, nil
end


-- Arrays -------------------------------------------------
-- Concatenate two arrays
function table_.concatArray(list1, list2)
    joined = {}

    counter = 1
    for _, value in ipairs(list1) do
        joined[counter] = value
        counter = counter + 1
    end
    for _, value in ipairs(list2) do
        joined[counter] = value
        counter = counter + 1
    end

    return joined
end


-- Copy arrays
function table_.copy(list)
    copy = {}
    for _, value in ipairs(list) do table.insert(copy, value) end
    return copy
end


--- Converts a list with string keys to an array, i.e. '1' -> 1.
--
-- @param list table: the list to convert.
-- @return array: the array.
function table_.strToIntKeys(tab)
    local list = {}
    for key, val in pairs(tab) do list[tonumber(key)] = val end 
    return list
end


-- Exit -------------------------------------------------
return table_