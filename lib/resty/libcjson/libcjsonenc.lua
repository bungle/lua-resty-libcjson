local open, clock, format = io.open, os.clock, string.format
local e = require "resty.libcjson".encode
local file = open("resty/libcjson/citylots.json", "rb")
local content = file:read "*a"
file:close()
local x = clock()
e(content)
local z = clock() - x
print(format("Encoding Time: %.6f", z))
