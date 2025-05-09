macro( add_test name )
   add_executable( ${name} ${name}.cpp )
   target_link_libraries( ${name} PRIVATE clack::clack Catch2::Catch2WithMain )
   catch_discover_tests( ${name} )
endmacro()

add_test(cli_tests)