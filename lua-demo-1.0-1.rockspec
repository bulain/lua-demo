package = "lua-demo"
version = "1.0-1"
source = {
   url = "https://github.com/bulain/lua-demo"
}
description = {
   homepage = "https://github.com/bulain/lua-demo",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      hello = "src/hello.lua"
   },
   install = {
      bin = {
         "bin/openresty-restart.bat",
         "bin/openresty-start.bat",
         "bin/openresty-status.bat",
         "bin/openresty-stop.bat"
      }
   }
}
