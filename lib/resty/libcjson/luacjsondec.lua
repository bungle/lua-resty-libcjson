local open, clock, format = io.open, os.clock, string.format
local d = require "cjson.safe".decode
local file = open("resty/libcjson/citylots.json", "rb")
local content = file:read "*a"
file:close()
local x = clock()
d(content)
local z = clock() - x
print(format("Decoding Time: %.6f", z))
