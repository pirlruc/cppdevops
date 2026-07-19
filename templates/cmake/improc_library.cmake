# Shared CMake helpers for image_proc libraries (OpenCV-style layout).

macro(improc_library_defaults LIB_NAME)
  if(NOT DEFINED IMPROC_SUPERPROJECT_VERSION)
    set(IMPROC_SUPERPROJECT_VERSION 1.0.0)
  endif()
  if(IMPROC_WITH_TESTS OR IMPROC_WITH_COVERAGE)
    list(APPEND VCPKG_MANIFEST_FEATURES "tests")
  endif()
  string(REPLACE "-" "_" _alias ${LIB_NAME})
  set(IMPROC_${_alias}_WITH_TESTS OFF CACHE BOOL "Build ${LIB_NAME} tests")
endmacro()

function(improc_add_header_library TARGET)
  cmake_parse_arguments(ARG "" "NAMESPACE;ALIAS" "HEADERS;DEPS" ${ARGN})
  add_library(${TARGET} INTERFACE ${ARG_HEADERS})
  if(ARG_ALIAS)
    add_library(${ARG_ALIAS} ALIAS ${TARGET})
  endif()
  target_include_directories(${TARGET} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)
  if(ARG_DEPS)
    target_link_libraries(${TARGET} INTERFACE ${ARG_DEPS})
  endif()
  set_target_properties(${TARGET} PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON)
endfunction()

function(improc_add_shared_library TARGET)
  cmake_parse_arguments(ARG "" "ALIAS" "SOURCES;HEADERS;DEPS;COMPILE_DEFS" ${ARGN})
  if(NOT ARG_SOURCES)
    add_library(${TARGET} INTERFACE)
    if(ARG_HEADERS)
      target_sources(${TARGET} INTERFACE ${ARG_HEADERS})
    endif()
  else()
    add_library(${TARGET} SHARED ${ARG_SOURCES} ${ARG_HEADERS})
    if(ARG_COMPILE_DEFS)
      target_compile_definitions(${TARGET} PRIVATE ${ARG_COMPILE_DEFS})
    endif()
    set_target_properties(${TARGET} PROPERTIES
      CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
      VERSION ${IMPROC_SUPERPROJECT_VERSION})
  endif()
  if(ARG_ALIAS)
    add_library(${ARG_ALIAS} ALIAS ${TARGET})
  endif()
  if(ARG_SOURCES)
    target_include_directories(${TARGET} PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>)
    set_target_properties(${TARGET} PROPERTIES
      CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
      VERSION ${IMPROC_SUPERPROJECT_VERSION})
  else()
    target_include_directories(${TARGET} INTERFACE
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>)
  endif()
  if(ARG_DEPS)
    if(ARG_SOURCES)
      target_link_libraries(${TARGET} PUBLIC ${ARG_DEPS})
    else()
      target_link_libraries(${TARGET} INTERFACE ${ARG_DEPS})
    endif()
  endif()
endfunction()
