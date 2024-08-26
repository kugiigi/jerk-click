file(GLOB_RECURSE QML_SRCS *.qml *.js)

find_package(Qt5Core)
find_package(Qt5Gui)
find_package(Qt5Qml)
find_package(Qt5Quick)

add_definitions(
  -DGETTEXT_PACKAGE=\"${PROJECT_NAME}\"
  -DGETTEXT_LOCALEDIR=\"${CMAKE_INSTALL_LOCALEDIR}\"
)

configure_file(
    config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    @ONLY
)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(jerk-click_SRCS
    main.cpp
    ${QML_SRCS}
)

add_executable(jerk-click ${jerk-click_SRCS})

qt5_use_modules(jerk-click Gui Qml Quick)

# Require the `OLD` policy in order to evaluate `@VERSION@`
cmake_policy(SET CMP0053 OLD)
find_program(SED_TOOL NAMES sed)
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
add_custom_target(jerk-click-qmlfiles ALL
    COMMAND ${SED_TOOL} -i 's_\\\(readonly property var appVersion:\\\).*_\\1 \\"@VERSION@\\"_' ${CMAKE_CURRENT_SOURCE_DIR}/qml/main.qml
    COMMAND cp -r ${CMAKE_CURRENT_SOURCE_DIR}/qml ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${QMLFILES}
)
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")

install(DIRECTORY qml DESTINATION ${DATA_DIR})

if(CLICK_MODE)
  install(TARGETS jerk-click DESTINATION ${BIN_DIR})
else()
  install(TARGETS jerk-click RUNTIME DESTINATION bin)
endif()
