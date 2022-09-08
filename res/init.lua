--- === res.lua ===
--- Author: Jonathan Delgado
---
--- Resource manager, such as for images, icons etc. Any external files
--- with specific IO conventions (paths etc.)
---
-- Module object
local res = {}
res.settings = require(workingDir .. 'res.settings')
res.images = require(workingDir .. 'res.images')


-- Exit -------------------------------------------------
return res