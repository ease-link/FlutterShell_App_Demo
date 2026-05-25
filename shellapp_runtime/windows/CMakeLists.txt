cmake_minimum_required(VERSION 3.14)
project(shellapp_runtime_plugin VERSION 0.1.0 LANGUAGES CXX)

set(PLUGIN_NAME "shellapp_runtime_plugin")
add_library(${PLUGIN_NAME} INTERFACE)

set(shellapp_runtime_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/shellapp_runtime.dll"
  PARENT_SCOPE
)
