--- === imageHelper.lua ===
--- Author: Jonathan Delgado
---
--- Module which assists with copying images and loading them.
---
-- Module object
module = {}

-- Image operations -------------------------------------------------

-- Opens a file explorer to get an image and returns the path to the image
function module.chooseImageFromFileSystem()
    local paths = hs.dialog.chooseFileOrFolder(
        'Choose an image', '~/Pictures', true, false, false,
        { 'jpg', 'jpeg', 'png' }, true
    )

    if paths == nil then return nil end
    return paths['1']
end


-- Returns the path to the saved image
function module.getSavedImagePath(name)
    return workingDir .. 'icons/' .. name
end


-- Copies the image to an images folder and returns the new path to the image
function module.saveImage(path)
    local name = helper.file.name(path)
    -- Copy the file to the new folder
    helper.file.copy(path, module.getSavedImagePath(name))

    return name
end


-- Load image from saved images path by name
function module.loadImage(name)
    return hs.image.imageFromPath(module.getSavedImagePath(name))
end


-- Exit -------------------------------------------------
return module