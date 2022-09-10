-- === array.lua ===
-- Author: Jonathan Delgado
--
-- Array functionality (special case of table where keys are omitted).
--
-- Module object
local array = {}
-- Imports ----------

-- Clear an array
function array.clear(list)
    for key in pairs(list) do table.remove(list, key) end
end


-- Concatenate two arrays
function array.concat(list1, list2)
    joined = {}

    for _, value in ipairs(list1) do table.insert(joined, value) end
    for _, value in ipairs(list2) do table.insert(joined, value) end

    return joined
end


-- Copy arrays
function array.copy(list)
    copy = {}
    for i, value in ipairs(list) do copy[i] = value end
    return copy
end


-- Exit -------------------------------------------------
return array