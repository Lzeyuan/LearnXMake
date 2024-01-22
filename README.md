# learn_opengl
# 介绍
## 目的
1. 记录学习[xmake](https://github.com/xmake-io/xmake)笔记
2. 记录学习[LearnOpenGL](https://learnopengl-cn.github.io/)代码
## 环境
- Windows11
- MSVC + Clang-cl：VS2022
- xmake + xrepo：v2.8.6+HEAD.211710b67

# XMake笔记
## 添加包
添加依赖包选项具体看[add_requires](https://xmake.io/#/zh-cn/manual/global_interfaces?id=add_requires)

### 快速使用：
```lua
...
add_requires("glfw")
...

target("01_HelloWindow")
    ...
    add_packages("glfw")
    ...
```

### MSVC 特性
windows 默认安装的包是采用 `/MT` 编译的，如果要切换到 `/MD`，可以配置如下：

`add_requires("glfw", {configs = {vs_runtime = "MD"}})`

也可以在全局配置设置：

```lua
if is_plat("windows") then
    set_toolset("clang-cl")
    set_runtimes("MD")
end
```

# 子项目
因为本项目会重复使用例如：glfw、glad、等库，所有建立Base模块给其它模块或Case共享使用（因为是练习所以不在意导入了多余的库）。
## 演示
演示比较复杂，本质就是把所有配置include起来，详细查看ThirdPart下的子项目，和顶级工程文件的xmake.lua

```lua
-- Base/xmake.lua
add_rules("mode.release", "mode.debug")

add_requires("glfw")

target("base")
  set_kind("static")
  add_files("stdafx.cpp")
  add_includedirs("/", { public = true })
  add_packages("glfw", { public = true })       -- 添加包依赖
  add_deps("glad", { public = true })           -- 添加其它模块的依赖
  add_deps("glm", { public = true })            -- 添加其它模块的依赖
  add_deps("stb_image", { public = true })      -- 添加其它模块的依赖

-- Case/03_Textures/xmake.lua
add_rules("mode.release", "mode.debug")

target("01_HelloWindow")    -- 模块名
    ...
    add_deps("base")        -- 添加其它模块的依赖
    ...
```

## 预编译头文件
### 快速使用
作为基础模块，自然想到要上预编译头文件了，大概配置如下：
```lua
-- Src/Base/xmake.lua
add_rules("mode.release", "mode.debug")

add_requires("glfw")

target("base")
  set_kind("static")
  add_files("stdafx.cpp")

  add_includedirs("/", { public = true })
  set_pcxxheader("stdafx.hpp")  -- 预编译头文件

  add_packages("glfw", { public = true })
  add_deps("glad", { public = true })
  add_deps("glm", { public = true })
  add_deps("stb_image", { public = true })

-- Src/Case/03_Textures/xmake.lua
add_rules("mode.release", "mode.debug")

target("03_Textures")
    ...
    add_deps("base")    -- 添加依赖
    ...
```

### xmake没有共享预编译头文件功能
然后就发现一个问题，每次构建Case的时候，Case下源文件不会去复用Base的预编译好的头文件，而直接简单的链接Base库。

为什么这么说呢，本项目用的MSVC，使用预编译头文件的标志就是三个选项 `/Fp` `/Yu` `/Yc`。

用 `xmake -rv` 可以看到在编译Case下的源文件是没有使用到上面所说的选项。

相比 **CMake** 就有共享预编译头文件功能，只需像下面一样配置：
```CMake
# Base/CMakeLists.txt
cmake_minimum_required (VERSION 3.25)

project ("Base")

# 必须生成库而不是INTERFACE
add_library(
        ${PROJECT_NAME}
        STATIC
        stdafx.hpp
        stdafx.cpp
)

target_include_directories(${PROJECT_NAME} PUBLIC "/")
target_precompile_headers(${PROJECT_NAME} PUBLIC "stdafx.hpp")

# case1/CMakeLists.txt
cmake_minimum_required (VERSION 3.25)

project ("Case1")

# test1.cpp这些源文件内容仅有： #include <stdafx.hpp>
add_executable(
        ${PROJECT_NAME}
        main.cpp
        test1.cpp
        test2.cpp
        test3.cpp
        test4.cpp
        test5.cpp
        test6.cpp
        test7.cpp
        test8.cpp
        test9.cpp
        test10.cpp
        test11.cpp
        test12.cpp
        test13.cpp
        test14.cpp
        test15.cpp
)

target_include_directories(${PROJECT_NAME} PRIVATE "./src")
target_link_libraries(${PROJECT_NAME} PRIVATE Base)
# 重点：复用Base生成好的pch
target_precompile_headers(${PROJECT_NAME} REUSE_FROM Base)
```
