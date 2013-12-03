cmake_minimum_required(VERSION 2.8)
project (EXIFYAY)

# Make the scripts available in the 'cmake' directory available for the
# 'include()' command, 'find_package()' command.
set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/cmake )

# Include the CMake script UseCython.cmake.  This defines add_cython_module().
# Instruction for use can be found at the top of cmake/UseCython.cmake.
include( UseCython )

include_directories("${PROJECT_BINARY_DIR}")
add_subdirectory (libexif) 
add_subdirectory (libjpeg) 
add_subdirectory (JpegEncoderEXIF) 
add_subdirectory (bindings) 
