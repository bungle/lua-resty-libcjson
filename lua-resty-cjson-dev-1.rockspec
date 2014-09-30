package = "lua-resty-libcjson"
version = "dev-1"
source = {
    url = "git://github.com/bungle/lua-resty-libcjson.git"
}
description = {
    summary = "LuaJIT FFI-based cJSON library (tested with OpenResty too).",
    detailed = "lua-resty-libcjson is a JSON library for cJSON C-library (LuaJIT bindings).",
    homepage = "https://github.com/bungle/lua-resty-libcjson",
    maintainer = "Aapo Talvensaari <aapo.talvensaari@gmail.com>",
    license = "BSD"
}
dependencies = {
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        ["resty.libcjson"] = "lib/resty/libcjson.lua"
    }
}
