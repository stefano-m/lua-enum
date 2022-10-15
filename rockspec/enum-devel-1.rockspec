package = "enum"
 version = "devel-1"
 source = {
    url = "git://github.com/stefano-m/lua-enum",
    tag = "master"
 }
 description = {
    summary = "Simulate enumerations in Lua",
    detailed = "Simulate enumerations in Lua",
    homepage = "git+https://github.com/stefano-m/lua-enum",
    license = "Apache v2.0"
 }
 dependencies = {
    "lua >= 5.1",
 }
 supported_platforms = { "linux", "unix", "cygwin", "windows", "freebsd" }
 build = {
    type = "builtin",
    modules = {
      ["enum.init"] = "./src/enum/init.lua",
    },
    copy_directories = { "./docs", "./tests"}
 }
