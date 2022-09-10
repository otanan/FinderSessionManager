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


-- Exit -------------------------------------------------
return table_