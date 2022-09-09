--- === res.lua ===
--- Author: Jonathan Delgado
---
--- Resource manager, such as for images, icons etc. Any external files
--- with specific IO conventions (paths etc.)
---
-- Module object
local res = {}
res.settings = require(fsmPackagePath .. 'res.settings')
res.images = require(fsmPackagePath .. 'res.images')


-- Exit -------------------------------------------------
return res