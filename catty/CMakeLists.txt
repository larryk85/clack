add_library(catcute catcute.cpp catcute.hpp)
target_include_directories(catcute PUBLIC
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
   $<INSTALL_INTERFACE:include>)