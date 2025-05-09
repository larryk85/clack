function(clack_generate_sphinx_docs)
   # Define argument types
   set(options VERBOSE)
   set(oneValueArgs DOX_OUTPUT_DIR)

   # Parse function arguments
   cmake_parse_arguments(ARGS "" "${oneValueArgs}" ${ARGN})

   set(VERBOSE ${ARGS_VERBOSE})
   if(NOT VERBOSE)
      set(VERBOSE FALSE)
   endif()

   # Ensure Sphinx is available
   find_package(Sphinx REQUIRED ${VERBOSE})
   set(SPHINX_SOURCE_DIR ${PROJECT_SOURCE_DIR}/docs)
   set(SPHINX_BUILD_DIR ${PROJECT_BINARY_DIR}/docs/sphinx)
   set(SPHINX_INDEX_FILE ${SPHINX_BUILD_DIR}/index.html)

   message(STATUS "DOXY OUTPUT DIR: ${ARGS_DOX_OUTPUT_DIR}")
   message(STATUS "SPHINX SOURCE DIR: ${SPHINX_SOURCE_DIR}")

   add_custom_command(
      OUTPUT ${SPHINX_INDEX_FILE}
      COMMAND
         ${SPHINX_EXECUTABLE} -b html
         -Dbreathe_projects.clack=${ARGS_DOX_OUTPUT_DIR}/xml
         ${SPHINX_SOURCE_DIR} ${SPHINX_BUILD_DIR}
      WORKING_DIRECTORY 
         ${PROJECT_BINARY_DIR}
      DEPENDS
         ${SPHINX_SOURCE_DIR}/index.rst
      MAIN_DEPENDENCY 
         ${SPHINX_SOURCE_DIR}/conf.py
      COMMENT
         "Generating documentation with Sphinx"
   )

   add_custom_target(Sphinx ALL DEPENDS ${SPHINX_INDEX_FILE})
endfunction()