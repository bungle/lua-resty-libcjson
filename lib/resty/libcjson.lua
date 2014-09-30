local ffi        = require "ffi"
local ffi_new    = ffi.new
local ffi_typeof = ffi.typeof
local ffi_cdef   = ffi.cdef
local ffi_load   = ffi.load
local ffi_str    = ffi.string
local next       = next
local floor      = math.floor
local max        = math.max
local type       = type
local next       = next
local pairs      = pairs
local ipairs     = ipairs
local null       = {}
if ngx and ngx.null then
    null = ngx.null
end

ffi_cdef[[
typedef struct cJSON {
    struct cJSON *next, *prev;
    struct cJSON *child;
    int    type;
    char  *valuestring;
    int    valueint;
    double valuedouble;
    char  *string;
} cJSON;

cJSON *cJSON_Parse(const char *value);
char  *cJSON_Print(cJSON *item);
char  *cJSON_PrintUnformatted(cJSON *item);
void   cJSON_Delete(cJSON *c);
int    cJSON_GetArraySize(cJSON *array);
cJSON *cJSON_CreateNull(void);
cJSON *cJSON_CreateTrue(void);
cJSON *cJSON_CreateFalse(void);
cJSON *cJSON_CreateBool(int b);
cJSON *cJSON_CreateNumber(double num);
cJSON *cJSON_CreateString(const char *string);
cJSON *cJSON_CreateArray(void);
cJSON *cJSON_CreateObject(void);
void   cJSON_AddItemToArray(cJSON *array, cJSON *item);
void   cJSON_AddItemToObject(cJSON *object,const char *string,cJSON *item);
void   cJSON_Minify(char *json);
]]

local ok, new_tab = pcall(require, "table.new")

if not ok then
    new_tab = function (narr, nrec) return {} end
end

local cjson = ffi_load("libcjson")
local json = new_tab(0, 6)
local char_t = ffi_typeof("char[?]")
local mt_arr = { __index = { __jsontype = "array"  }}
local mt_obj = { __index = { __jsontype = "object" }}

local function is_array(t)
    local m, c = 0, 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k < 0 or floor(k) ~= k then
            return false
        else
            m = max(m, k)
            c = c + 1
        end
    end
    return c == m
end

function json.decval(j)
    local t = j.type
    if     t == 0 then
        return false
    elseif t == 1 then
        return true
    elseif t == 2 then
        return null
    elseif t == 3 then
        return j.valuedouble
    elseif t == 4 then
        return ffi_str(j.valuestring)
    elseif t == 5 then
        return setmetatable(json.parse(j.child, cjson.cJSON_GetArraySize(j), 0) or {}, mt_arr)
    elseif t == 6 then
        return setmetatable(json.parse(j.child, 0, cjson.cJSON_GetArraySize(j)) or {}, mt_obj)
    else
        return nil
    end
end

function json.parse(j, narr, nrec)
    if j == nil then
        return nil
    else
        local c = j;
        local r = new_tab(narr, nrec)
        repeat
            local n
            if c.string ~= nil then
                n = ffi_str(c.string)
            else
                n = #r + 1
            end
            r[n] = json.decval(c)
            c = c.next
        until c == nil
        return r
    end
end

function json.decode(value)
    if type(value) ~= "string" then
        return value
    end
    local j = cjson.cJSON_Parse(value)
    if j == nil then
        return nil
    end
    local r
    local t = j.type
    if t == 5 then
        r = setmetatable(json.parse(j.child, cjson.cJSON_GetArraySize(j), 0) or {}, mt_arr)
    elseif t == 6 then
        r = setmetatable(json.parse(j.child, 0, cjson.cJSON_GetArraySize(j)) or {}, mt_obj)
    else
        r = json.decval(j)
    end
    cjson.cJSON_Delete(j)
    return r
end

function json.encval(value)
    local  t = type(value)
    local  j
    if     t == "string" then
        j = cjson.cJSON_CreateString(value)
    elseif t == "number" then
        j = cjson.cJSON_CreateNumber(value)
    elseif t == "boolean" then
        if value then
            j = cjson.cJSON_CreateTrue()
        else
            j = cjson.cJSON_CreateFalse()
        end
    elseif t == "nil" then
        j = cjson.cJSON_CreateNull()
    elseif t == "table" then
        if next(value) == nil then
            if getmetatable(value) ~= mt_obj and is_array(value) then
                j = cjson.cJSON_CreateArray()
            else
                j = cjson.cJSON_CreateObject()
            end
        else
            if getmetatable(value) ~= mt_obj and is_array(value) then
                j = cjson.cJSON_CreateArray()
                for _, v in ipairs(value) do
                    cjson.cJSON_AddItemToArray(j[0], json.encval(v))
                end
            else
                j = cjson.cJSON_CreateObject()
                for k, v in pairs(value) do
                    if type(k) ~= "string" then
                        k = tostring(k)
                    end
                    cjson.cJSON_AddItemToObject(j[0], k, json.encval(v))
                end
            end
        end
    elseif value == null then
        j = cjson.cJSON_CreateNull()
    end
    return j
end

function json.encode(value, formatted)
    local j = json.encval(value)
    if j == nil then
        return nil
    else
        local f = formatted ~= false
        local r
        if f then
            r = ffi_str(cjson.cJSON_Print(j))
        else
            r = ffi_str(cjson.cJSON_PrintUnformatted(j))
        end
        cjson.cJSON_Delete(j)
        return r
    end
end

function json.minify(value)
    local t = value
    if type(t) ~= "string" then
        t = json.encode(t)
    end
    local m = ffi_new(char_t, #t, t)
    cjson.cJSON_Minify(m)
    return ffi_str(m)
end

return {
    decode = json.decode,
    encode = json.encode,
    minify = json.minify,
    array  = mt_arr,
    object = mt_obj,
    null   = null
}