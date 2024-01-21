add_rules("mode.release", "mode.debug")

add_requires("glfw")

target("01_HelloWindow")
    set_kind("binary")
    add_files("*.cpp")

    add_packages("glfw")
    add_deps("glad")