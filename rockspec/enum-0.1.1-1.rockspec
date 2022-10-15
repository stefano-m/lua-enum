package = "enum"
version = "0.1.1-1"
source = {
   url = "git://github.com/stefano-m/lua-enum",
   tag = "v0.1.1"
}
description = {
   summary = "Simulate enumerations in Lua",
   detailed = "Simulate enumerations in Lua",
   homepage = "git+https://github.com/stefano-m/lua-enum",
   license = "Apache v2.0"
}
supported_platforms = {
   "linux",
   "unix",
   "cygwin",
   "windows",
   "freebsd"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["enum.init"] = "./src/enum/init.lua"
   },
   copy_directories = {
      "./docs",
      "./tests"
   }
}
