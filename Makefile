# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/felipe/Development/exifyay

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/felipe/Development/exifyay

#=============================================================================
# Targets provided globally by CMake.

# Special rule for the target edit_cache
edit_cache:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --cyan "Running interactive CMake command-line interface..."
	/usr/bin/cmake -i .
.PHONY : edit_cache

# Special rule for the target edit_cache
edit_cache/fast: edit_cache
.PHONY : edit_cache/fast

# Special rule for the target rebuild_cache
rebuild_cache:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --cyan "Running CMake to regenerate build system..."
	/usr/bin/cmake -H$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR)
.PHONY : rebuild_cache

# Special rule for the target rebuild_cache
rebuild_cache/fast: rebuild_cache
.PHONY : rebuild_cache/fast

# The main all target
all: cmake_check_build_system
	$(CMAKE_COMMAND) -E cmake_progress_start /home/felipe/Development/exifyay/CMakeFiles /home/felipe/Development/exifyay/CMakeFiles/progress.marks
	$(MAKE) -f CMakeFiles/Makefile2 all
	$(CMAKE_COMMAND) -E cmake_progress_start /home/felipe/Development/exifyay/CMakeFiles 0
.PHONY : all

# The main clean target
clean:
	$(MAKE) -f CMakeFiles/Makefile2 clean
.PHONY : clean

# The main clean target
clean/fast: clean
.PHONY : clean/fast

# Prepare targets for installation.
preinstall: all
	$(MAKE) -f CMakeFiles/Makefile2 preinstall
.PHONY : preinstall

# Prepare targets for installation.
preinstall/fast:
	$(MAKE) -f CMakeFiles/Makefile2 preinstall
.PHONY : preinstall/fast

# clear depends
depend:
	$(CMAKE_COMMAND) -H$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 1
.PHONY : depend

#=============================================================================
# Target rules for targets named bindings_distutils

# Build rule for target.
bindings_distutils: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 bindings_distutils
.PHONY : bindings_distutils

# fast build rule for target.
bindings_distutils/fast:
	$(MAKE) -f CMakeFiles/bindings_distutils.dir/build.make CMakeFiles/bindings_distutils.dir/build
.PHONY : bindings_distutils/fast

#=============================================================================
# Target rules for targets named exif

# Build rule for target.
exif: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 exif
.PHONY : exif

# fast build rule for target.
exif/fast:
	$(MAKE) -f libexif/CMakeFiles/exif.dir/build.make libexif/CMakeFiles/exif.dir/build
.PHONY : exif/fast

#=============================================================================
# Target rules for targets named jpeg

# Build rule for target.
jpeg: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 jpeg
.PHONY : jpeg

# fast build rule for target.
jpeg/fast:
	$(MAKE) -f libjpeg/CMakeFiles/jpeg.dir/build.make libjpeg/CMakeFiles/jpeg.dir/build
.PHONY : jpeg/fast

#=============================================================================
# Target rules for targets named JpegEncoderEXIF

# Build rule for target.
JpegEncoderEXIF: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 JpegEncoderEXIF
.PHONY : JpegEncoderEXIF

# fast build rule for target.
JpegEncoderEXIF/fast:
	$(MAKE) -f JpegEncoderEXIF/CMakeFiles/JpegEncoderEXIF.dir/build.make JpegEncoderEXIF/CMakeFiles/JpegEncoderEXIF.dir/build
.PHONY : JpegEncoderEXIF/fast

#=============================================================================
# Target rules for targets named exifyay

# Build rule for target.
exifyay: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 exifyay
.PHONY : exifyay

# fast build rule for target.
exifyay/fast:
	$(MAKE) -f bindings/CMakeFiles/exifyay.dir/build.make bindings/CMakeFiles/exifyay.dir/build
.PHONY : exifyay/fast

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... all (the default if no target is provided)"
	@echo "... clean"
	@echo "... depend"
	@echo "... bindings_distutils"
	@echo "... edit_cache"
	@echo "... rebuild_cache"
	@echo "... exif"
	@echo "... jpeg"
	@echo "... JpegEncoderEXIF"
	@echo "... exifyay"
.PHONY : help



#=============================================================================
# Special targets to cleanup operation of make.

# Special rule to run CMake to check the build system integrity.
# No rule that depends on this can have commands that come from listfiles
# because they might be regenerated.
cmake_check_build_system:
	$(CMAKE_COMMAND) -H$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 0
.PHONY : cmake_check_build_system

