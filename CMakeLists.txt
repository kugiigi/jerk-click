project(jerk-click.kugiigi C CXX)
cmake_minimum_required(VERSION 2.8.9)

set(UBUNTU_MANIFEST_PATH "click/manifest.json.in" CACHE INTERNAL "Relative path to the manifest file")
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra -fPIC")

# Debugging purpose. Keep commented unless you need it.
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")

include(FindPkgConfig)
include(GNUInstallDirs)

option(INSTALL_TESTS    "Install the tests on make install" on)
option(CLICK_MODE       "Installs to a contained location" on)

set(APP_NAME           "jerk-click")
set(DESKTOP_FILE        "${PROJECT_NAME}.desktop")
set(LP_PROJECT          jerk-click)
set(ICON_FILE           jerk-click.svg)
set(VERSION             "1.0.0")

# Sets BZR_REVNO
execute_process(
    COMMAND bzr revno ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE BZR_REVNO
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT BZR_REVNO)
    set(BZR_REVNO "latest")
endif(NOT BZR_REVNO)

# Find out the architecture for package building
# to determine the plugin's installation path
execute_process(
  COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
  OUTPUT_VARIABLE ARCH_TRIPLET
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND dpkg-architecture -qDEB_HOST_ARCH
  OUTPUT_VARIABLE CLICK_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

include(Click)

add_subdirectory(po)
add_subdirectory(click)
add_subdirectory(data)
add_subdirectory(src)

