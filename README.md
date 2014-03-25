# lua-resty-cjson

LuaJIT FFI-based cJSON library for OpenResty.

## Lua API
#### mixed json.decode(value)

Decodes JSON value or structure (JSON array or object), and returns either Lua `table` or some simple value (e.g. `boolean`, `string`, `number`, `nil` or `ngx.null`).

##### Example

```lua
local json = require "resty.cjson"
local obj = json.decode "{}"     -- table (with obj.__jsontype == "object")
local arr = json.decode "[]"     -- table (with arr.__jsontype == "array")
local nbr = json.decode "1"      -- 1
local bln = json.decode "true"   -- true
local str = json.decode '"test"' -- "test"
local nul = json.decode "null"   -- ngx.null
local nul = json.decode '""'     -- ""
local nul = json.decode ""       -- nil
local nul = json.decode nil      -- nil
local nul = json.decode()        -- nil
```

Nested JSON structures are parsed as nested Lua tables.

#### string json.encode(value, formatted)

Encodes Lua value or table, and returns equivalent JSON value or structure as a string. Optionally you may pass `formatted` argument with value of `false` to get unformatted JSON string as output.

##### Example

```lua
local json = require "resty.cjson"
local str = json.encode{}                              -- "[]"
local str = json.encode(1)                             -- "1"
local str = json.encode(1.1)                           -- "1.100000"
local str = json.encode"test"                          -- '"test"'
local str = json.encode""                              -- '""'
local str = json.encode(false)                         -- "false"
local str = json.encode(nil)                           -- "null"
local str = json.encode(ngx.null)                      -- "null"
local str = json.encode()                              -- "null"
local str = json.encode{ a = "b" }                     -- '{"a":"b"}'
local str = json.encode(setmetatable({}, json.object)) -- "{}"
```

Nested Lua tables are encoded as nested JSON structures (JSON objects or arrays).

## License

`lua-resty-cjson` uses two clause BSD license.

```
LuaJIT FFI-based cJSON library for OpenResty

Copyright (c) 2013, Aapo Talvensaari
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
