add_rules("mode.release", "mode.debug")

target("glad")
  set_kind("static")
  add_includedirs("include",{public=true})
  add_files("src/*.c")