-------------------------------------------------------------------------------
------------------------- Helper functionality -------------------------
-------------------------------------------------------------------------------

------------------------- Table operations -------------------------
-- Check if value exists in list
function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end


-- Clear an array
function clearList(list)
    for key in pairs(list) do
        list[key] = nil
    end
end


------------------------- Json -------------------------
json = require('lunajson')


-- Convert the file name to a proper relative path
function jsonFname(fname)
    return workingDir .. fname .. '.json'
end


function jsonLoad(fname)
    local jsonFile = io.open(jsonFname(fname), 'r')
    local jsonData = jsonFile:read('*a')
    local jsonAsTable = json.decode(jsonData)
    jsonFile:close()
    return jsonAsTable
end

function jsonDump(tab, fname)
    local jsonData = json.encode(tab)
    local jsonFile = assert(io.open(jsonFname(fname), 'w'))
    jsonFile:write(jsonData)
    jsonFile:close()
    -- Prettify the json
    hs.execute('python3 ' .. workingDir .. 'json_pretty.py ' .. workingDir .. fname)
end



-- function sleep(n)
--     os.execute("sleep " .. tonumber(n))
-- end


-- function centerWindow()
--     print('Centering window...')
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local max = win:screen():frame()

--     f.w = 1200
--     f.h = 800
--     f.x = (max.w - f.w) / 2
--     f.y = (max.h - f.h) / 2
--     win:setFrame(f)
-- end
