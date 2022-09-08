--- === images.lua ===
--- Author: Jonathan Delgado
---
--- Load and save image resources.
---
-- Module object
local images = {}
-- Imports ----------
local helper = require(workingDir .. 'helper')


-- Opens a file explorer to get an image and returns the path to the image
function images.chooseFromFileSystem()
    local paths = hs.dialog.chooseFileOrFolder(
        'Choose an image', '~/Pictures', true, false, false,
        { 'jpg', 'jpeg', 'png' }, true
    )

    if paths == nil then return nil end
    return paths['1']
end


-- Returns the path to the saved image
function images.getSavedPath(name) return workingDir .. 'icons/' .. name end


-- Copies the image to an images folder and returns the new path to the image
function images.save(path)
    local name = helper.file.name(path)
    -- Copy the file to the new folder
    helper.file.copy(path, images.getSavedPath(name))
    return name
end


-- Load image from saved images path by name
function images.load(name)
    return hs.image.imageFromPath(images.getSavedPath(name))
end


-- Exit -------------------------------------------------
return images