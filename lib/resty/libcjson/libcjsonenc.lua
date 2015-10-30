local open, clock, format = io.open, os.clock, string.format
local d = require "resty.libcjson".decode
local e = require "resty.libcjson".encode
local file = open("resty/libcjson/citylots.json", "rb")
local content = file:read "*a"
file:close()
local t = d(content)
local x = clock()
e(t)
local z = clock() - x
print(format("Encoding Time: %.6f", z))
