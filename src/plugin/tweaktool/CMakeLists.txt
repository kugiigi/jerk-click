set(PLUGIN_DIR TweakTool)

#include(FindPkgConfig)
pkg_check_modules(QGSETTINGS REQUIRED gsettings-qt)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${QGSETTINGS_INCLUDE_DIRS}
)

#add the sources to compile
set(tw_SRCS
    systemfile.cpp
    singleprocess.cpp
    applicationsmodel.cpp
    desktopfileutils.cpp
    package.cpp
    package_p.h
    packagesmodel.cpp
    scopehelper.cpp
    devicecapabilities.cpp
    clickinstaller.cpp
    storagemanager.cpp
    systeminfo.cpp
    backend.cpp
)

add_library(tweaktoolplugin MODULE
    ${tw_SRCS}
)

qt5_use_modules(tweaktoolplugin Qml Quick DBus)
target_link_libraries(tweaktoolplugin ${QGSETTINGS_LIBRARIES})

# Copy the plugin, the qmldir file and other assets to the build dir for running in QtCreator
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
add_custom_command(TARGET tweaktoolplugin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:tweaktoolplugin> ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")

# Install plugin file
install(TARGETS tweaktoolplugin DESTINATION ${QT_IMPORTS_DIR}/${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/${PLUGIN_DIR})
