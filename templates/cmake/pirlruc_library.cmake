# Shared CMake helpers for pirlruc C++ libraries.
# Canonical source for standalone library repos. Copy this file to
# cmake/pirlruc_library.cmake; do not edit the copies in place.
#
# Modern target usage (CPP-BUILD):
# - C++20 via target_compile_features, not CXX_STANDARD properties
# - headers via target_sources FILE_SET HEADERS
# - EXPORT_NAME on the library target
# - compiled libraries honor BUILD_SHARED_LIBS (shared when unset)
# - hidden visibility, SOVERSION, and an optional IPO switch

if(NOT DEFINED PIRLRUC_ENABLE_IPO)
  option(PIRLRUC_ENABLE_IPO "Enable interprocedural optimization when the compiler supports it" OFF)
endif()

macro(pirlruc_library_defaults LIB_NAME)
  if(NOT DEFINED PIRLRUC_SUPERPROJECT_VERSION)
    set(PIRLRUC_SUPERPROJECT_VERSION 1.0.0)
  endif()
  if(PIRLRUC_WITH_TESTS OR PIRLRUC_WITH_COVERAGE)
    list(APPEND VCPKG_MANIFEST_FEATURES "tests")
  endif()
endmacro()

function(_pirlruc_apply_ipo TARGET)
  if(NOT PIRLRUC_ENABLE_IPO)
    return()
  endif()
  include(CheckIPOSupported)
  check_ipo_supported(RESULT _pirlruc_ipo OUTPUT _pirlruc_ipo_error)
  if(_pirlruc_ipo)
    set_property(TARGET ${TARGET} PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
  else()
    message(STATUS "PIRLRUC_ENABLE_IPO ignored for ${TARGET}: ${_pirlruc_ipo_error}")
  endif()
endfunction()

# Resolve GTest from vcpkg (CONFIG) or, for local Docker runs without vcpkg, FetchContent.
function(pirlruc_enable_gtest)
  if(TARGET GTest::gtest_main)
    return()
  endif()
  find_package(GTest CONFIG QUIET)
  if(TARGET GTest::gtest_main)
    return()
  endif()
  find_package(GTest QUIET)
  if(TARGET GTest::gtest_main)
    return()
  endif()
  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
  set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
  set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)
  if(NOT TARGET GTest::gtest_main)
    add_library(GTest::gtest ALIAS gtest)
    add_library(GTest::gtest_main ALIAS gtest_main)
  endif()
endfunction()

function(pirlruc_add_header_library TARGET)
  include(GNUInstallDirs)
  cmake_parse_arguments(ARG "" "NAMESPACE;ALIAS;EXPORT_NAME" "HEADERS;DEPS" ${ARGN})
  if(NOT ARG_EXPORT_NAME)
    set(ARG_EXPORT_NAME ${TARGET})
  endif()
  add_library(${TARGET} INTERFACE)
  if(ARG_ALIAS)
    add_library(${ARG_ALIAS} ALIAS ${TARGET})
  endif()
  if(ARG_HEADERS)
    target_sources(${TARGET} INTERFACE
      FILE_SET HEADERS
      BASE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include"
      FILES ${ARG_HEADERS})
  endif()
  target_include_directories(${TARGET} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
  target_compile_features(${TARGET} INTERFACE cxx_std_20)
  if(ARG_DEPS)
    target_link_libraries(${TARGET} INTERFACE ${ARG_DEPS})
  endif()
  set_target_properties(${TARGET} PROPERTIES EXPORT_NAME ${ARG_EXPORT_NAME})
endfunction()

function(pirlruc_add_shared_library TARGET)
  include(GNUInstallDirs)
  cmake_parse_arguments(ARG "" "ALIAS;EXPORT_NAME" "SOURCES;HEADERS;DEPS;COMPILE_DEFS" ${ARGN})
  if(NOT ARG_EXPORT_NAME)
    set(ARG_EXPORT_NAME ${TARGET})
  endif()

  if(NOT ARG_SOURCES)
    pirlruc_add_header_library(${TARGET} ALIAS ${ARG_ALIAS} EXPORT_NAME ${ARG_EXPORT_NAME}
      HEADERS ${ARG_HEADERS} DEPS ${ARG_DEPS})
    return()
  endif()

  set(_kind SHARED)
  if(DEFINED BUILD_SHARED_LIBS AND NOT BUILD_SHARED_LIBS)
    set(_kind STATIC)
  endif()
  add_library(${TARGET} ${_kind})
  target_sources(${TARGET} PRIVATE ${ARG_SOURCES})

  string(TOUPPER "${TARGET}" _export_base)
  include(GenerateExportHeader)
  generate_export_header(${TARGET}
    BASE_NAME ${_export_base}
    EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/include/${TARGET}/export.hpp")
  target_sources(${TARGET} PUBLIC
    FILE_SET HEADERS
    BASE_DIRS
      "${CMAKE_CURRENT_SOURCE_DIR}/include"
      "${CMAKE_CURRENT_BINARY_DIR}/include"
    FILES ${ARG_HEADERS} "${CMAKE_CURRENT_BINARY_DIR}/include/${TARGET}/export.hpp")
  target_include_directories(${TARGET} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>)

  if(ARG_COMPILE_DEFS)
    target_compile_definitions(${TARGET} PRIVATE ${ARG_COMPILE_DEFS})
  endif()
  if(ARG_ALIAS)
    add_library(${ARG_ALIAS} ALIAS ${TARGET})
  endif()
  target_include_directories(${TARGET} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
  target_compile_features(${TARGET} PUBLIC cxx_std_20)
  if(ARG_DEPS)
    target_link_libraries(${TARGET} PUBLIC ${ARG_DEPS})
  endif()

  set(_version "${PROJECT_VERSION}")
  if(NOT _version)
    set(_version "${PIRLRUC_SUPERPROJECT_VERSION}")
  endif()
  set(_soversion "${PROJECT_VERSION_MAJOR}")
  if(NOT _soversion)
    set(_soversion 0)
  endif()
  set_target_properties(${TARGET} PROPERTIES
    EXPORT_NAME ${ARG_EXPORT_NAME}
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    VERSION ${_version}
    SOVERSION ${_soversion})
  _pirlruc_apply_ipo(${TARGET})
endfunction()

# Single entry point. Pass HEADER_ONLY, or SOURCES for a compiled library.
function(pirlruc_add_library TARGET)
  cmake_parse_arguments(ARG "HEADER_ONLY" "NAMESPACE;ALIAS;EXPORT_NAME" "SOURCES;HEADERS;DEPS;COMPILE_DEFS" ${ARGN})
  if(ARG_HEADER_ONLY OR NOT ARG_SOURCES)
    pirlruc_add_header_library(${TARGET}
      ALIAS ${ARG_ALIAS}
      EXPORT_NAME ${ARG_EXPORT_NAME}
      HEADERS ${ARG_HEADERS}
      DEPS ${ARG_DEPS})
  else()
    pirlruc_add_shared_library(${TARGET}
      ALIAS ${ARG_ALIAS}
      EXPORT_NAME ${ARG_EXPORT_NAME}
      SOURCES ${ARG_SOURCES}
      HEADERS ${ARG_HEADERS}
      DEPS ${ARG_DEPS}
      COMPILE_DEFS ${ARG_COMPILE_DEFS})
  endif()
endfunction()
