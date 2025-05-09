cmake_minimum_required(VERSION 3.18)

project(clack VERSION 1.0.0.0)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads)
link_libraries(Threads::Threads)

include(CMakeDependentOption)
option(CLACK_ENABLE_TESTS    "Enable building of unit tests" ON)
option(CLACK_ENABLE_DOCS     "Enable creation of the documentation" ON)
option(CLACK_ENABLE_INSTALL  "Enable installation" ON)
option(CLACK_ENABLE_PEDANTIC "Enable pedantic warnings" OFF)

message( STATUS "Building clack v${clack_VERSION}..." )
if (MSVC)
   if (CMAKE_SIZEOF_VOID_P EQUAL 8)
      add_compile_definitions(_AMD64_)
   else()
      add_compile_definitions(_X86_)
   endif()
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

#add_executable(test_cpp ${PROJECT_SOURCE_DIR}/scripts/test.cpp)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(clack INTERFACE)

target_include_directories(clack INTERFACE
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
   $<INSTALL_INTERFACE:include>)

if(CLACK_ENABLE_PEDANTIC)
   target_compile_options(clack INTERFACE
      $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic -Werror>
      $<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra -Wpedantic -Werror>)
endif()

target_compile_options(clack INTERFACE
   $<$<CXX_COMPILER_ID:MSVC>:/Zc:preprocessor>)

target_compile_definitions(clack INTERFACE
   $<$<CONFIG:Debug>:CLACK_DEBUG>
   $<$<CONFIG:Release>:CLACK_RELEASE>
   $<$<CONFIG:RelWithDebInfo>:CLACK_RELWITHDEBINFO>
   $<$<CONFIG:MinSizeRel>:CLACK_MINSIZEREL>)

add_library(clack::clack ALIAS clack)

add_subdirectory(./catty)

include(FetchContent)
if(CLACK_ENABLE_TESTS)
   FetchContent_Declare(
      Catch2
      GIT_REPOSITORY https://github.com/catchorg/Catch2
      GIT_TAG v3.6.0
   )

   FetchContent_GetProperties(Catch2)
   if (NOT Catch2_POPULATED)
      FetchContent_MakeAvailable(Catch2)
      list(APPEND CMAKE_MODULE_PATH "${catch2_SOURCE_DIR}/contrib")
   endif()

   include(CTest)
   include(Catch)

   enable_testing()
   add_subdirectory(tests)
endif()

if(CLACK_ENABLE_DOCS)
   #include(cmake/Doxy.cmake)
   #clack_generate_doxygen_docs()
   find_package(Doxygen REQUIRED)
   include(cmake/Sphinx.cmake)

   # Find all the public headers
   get_target_property(CATTY_PUBLIC_HEADER_DIR catcute INTERFACE_INCLUDE_DIRECTORIES)
   file(GLOB_RECURSE CATTY_PUBLIC_HEADERS ${CATTY_PUBLIC_HEADER_DIR}/*.h)

   #This will be the main output of our command
   set(DOXYGEN_INDEX_FILE ${CMAKE_CURRENT_BINARY_DIR}/html/index.html)

   configure_file(${CMAKE_CURRENT_SOURCE_DIR}/docs/Doxyfile
      ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile COPYONLY)

   add_custom_command(OUTPUT ${DOXYGEN_INDEX_FILE}
                     DEPENDS ${CATTY_PUBLIC_HEADERS}
                     COMMAND ${DOXYGEN_EXECUTABLE} Doxyfile
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     MAIN_DEPENDENCY Doxyfile
                     COMMENT "Generating docs")

   add_custom_target(Doxygen ALL DEPENDS ${DOXYGEN_INDEX_FILE})

   clack_generate_sphinx_docs(
      NAME "clack"
      DOX_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}
      ONLY_PROVIDED_DIRS
   )
endif()

include(GNUInstallDirs)

# ##################################################################################################
# Configure version info.
# ##################################################################################################
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/clack-config-version.cmake.in
               ${CMAKE_CURRENT_BINARY_DIR}/clack-config-version.cmake @ONLY)

# ##################################################################################################
# Installation.
# ##################################################################################################
if(CLACK_ENABLE_INSTALL)
   include(CMakePackageConfigHelpers)
   include(GNUInstallDirs)

   message(STATUS "Installing clack ...")
   set(clack_INCLUDE_DIRS ${CMAKE_INSTALL_INCLUDEDIR})
   configure_package_config_file(cmake/clack-config.cmake.in
      ${CMAKE_CURRENT_BINARY_DIR}/clack-config.cmake
      INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/clack
      PATH_VARS clack_INCLUDE_DIRS
   )
   write_basic_package_version_file(
      ${CMAKE_CURRENT_BINARY_DIR}/clack-config-version.cmake
      VERSION ${clack_VERSION}
      COMPATIBILITY SameMajorVersion
   )

   install(TARGETS clack
           EXPORT clack-targets
           LIBRARY
           PUBLIC_HEADER
              DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
              COMPONENT Headers
   )
   install(EXPORT clack-targets
      NAMESPACE clack::
      DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/clack
   )
   install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
           DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
   )
   install(FILES ${CMAKE_CURRENT_BINARY_DIR}/clack-config.cmake
                 ${CMAKE_CURRENT_BINARY_DIR}/clack-config-version.cmake
                 DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/clack
   )
endif()