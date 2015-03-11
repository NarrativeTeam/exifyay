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

find_program(PYTHON "python")

set(BINDINGS_VERSION "0.1.3")

if (PYTHON)
    set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/bindings.py.cmake")
    set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/bindings.py")
    set(DEPS        "exifyay")
    set(OUTPUT      "${CMAKE_CURRENT_BINARY_DIR}/python-timestamp")

    configure_file(${SETUP_PY_IN} ${SETUP_PY})

    add_custom_command(OUTPUT ${OUTPUT}
                       COMMAND ${PYTHON} ${SETUP_PY} build
                       COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
                       DEPENDS ${DEPS})

    add_custom_target(bindings_distutils ALL DEPENDS ${OUTPUT})
endif()

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/setup.py"
    )
