local ffi        = require "ffi"
local ffi_new    = ffi.new
local ffi_cdef   = ffi.cdef
local ffi_load   = ffi.load
local ffi_str    = ffi.string
local C          = ffi.C
local ffi_string = ffi.string

local cjson = ffi_load("cjson")

ffi_cdef[[
typedef struct cJSON {
    struct cJSON *next, *prev;
    struct cJSON *child;
    int type;
    char *valuestring;
    int valueint;
    double valuedouble;
    char *string;
} cJSON;

typedef struct cJSON_Hooks {
    void *(*malloc_fn)(size_t sz);
    void (*free_fn)(void *ptr);
} cJSON_Hooks;

void cJSON_InitHooks(cJSON_Hooks* hooks);
cJSON *cJSON_Parse(const char *value);
char  *cJSON_Print(cJSON *item);
char  *cJSON_PrintUnformatted(cJSON *item);
void   cJSON_Delete(cJSON *c);
int	  cJSON_GetArraySize(cJSON *array);
cJSON *cJSON_GetArrayItem(cJSON *array,int item);
cJSON *cJSON_GetObjectItem(cJSON *object,const char *string);
const char *cJSON_GetErrorPtr(void);
cJSON *cJSON_CreateNull(void);
cJSON *cJSON_CreateTrue(void);
cJSON *cJSON_CreateFalse(void);
cJSON *cJSON_CreateBool(int b);
cJSON *cJSON_CreateNumber(double num);
cJSON *cJSON_CreateString(const char *string);
cJSON *cJSON_CreateArray(void);
cJSON *cJSON_CreateObject(void);

cJSON *cJSON_CreateIntArray(const int *numbers,int count);
cJSON *cJSON_CreateFloatArray(const float *numbers,int count);
cJSON *cJSON_CreateDoubleArray(const double *numbers,int count);
cJSON *cJSON_CreateStringArray(const char **strings,int count);

void cJSON_AddItemToArray(cJSON *array, cJSON *item);
void cJSON_AddItemToObject(cJSON *object,const char *string,cJSON *item);
void cJSON_AddItemReferenceToArray(cJSON *array, cJSON *item);
void cJSON_AddItemReferenceToObject(cJSON *object,const char *string,cJSON *item);

cJSON *cJSON_DetachItemFromArray(cJSON *array,int which);
void   cJSON_DeleteItemFromArray(cJSON *array,int which);
cJSON *cJSON_DetachItemFromObject(cJSON *object,const char *string);
void   cJSON_DeleteItemFromObject(cJSON *object,const char *string);

void cJSON_ReplaceItemInArray(cJSON *array,int which,cJSON *newitem);
void cJSON_ReplaceItemInObject(cJSON *object,const char *string,cJSON *newitem);

cJSON *cJSON_Duplicate(cJSON *item,int recurse);
cJSON *cJSON_ParseWithOpts(const char *value,const char **return_parse_end,int require_null_terminated);

void cJSON_Minify(char *json);
]]


local function parse(j)
    if j == nil then return nil end
    local r = {}
    repeat
        local t = j.type
        local n = #r + 1
        if j.string ~= nil then
            n = ffi_str(j.string)
        end
        if t == 0 then
            r[n] = false
        elseif t == 1 then
            r[n] = true
        elseif t == 2 then
            r[n] = nil
        elseif t == 3 then
            r[n] = j.valuedouble
        elseif t == 4 then
            r[n] = ffi_str(j.valuestring)
        elseif t == 5 then
            r[n] = parse(j.child)
        elseif t == 6 then
            r[n] = parse(j.child)
        end
        j = j.next
    until j == nil
    return r
end

local function decode(json)
    local j = cjson.cJSON_Parse(json)
    if j == nil then return nil end
    if j.type == 5 or j.type == 6 then
        return parse(j.child)
    else
        return parse(j)
    end
end