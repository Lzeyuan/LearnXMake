add_rules("mode.release", "mode.debug")

add_requires("glfw")

target("02_Triangle")
    set_kind("binary")
    add_files("*.cpp")
    
    add_packages("glfw")
    add_deps("glad")