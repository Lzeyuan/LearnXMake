add_rules("mode.release", "mode.debug")

add_requires("glfw")

target("base")
  set_kind("static")
  add_includedirs("/", { public = true })
  -- add_files("stdafx.cpp")
  set_pcxxheader("stdafx.hpp")
  add_packages("glfw", { public = true })
  add_deps("glad", { public = true })
  add_deps("glm", { public = true })
  add_deps("stb_image", { public = true })