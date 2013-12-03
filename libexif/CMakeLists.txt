INCLUDE (CheckIncludeFiles)
INCLUDE (CheckFunctionExists)

set (PACKAGE "libexif")
set (PACKAGE_VERSION "0.6.21")
set (PACKAGE_BUGREPORT "libexif-devel@lists.sourceforge.net")
set (PACKAGE_NAME "EXIF library")
set (PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set (PACKAGE_TARNAME ${PACKAGE})
set (PACKAGE_URL "")

set (GETTEXT_PACKAGE "libexif-12")
set (LOCALEDIR "/usr/local/share/locale")
set (VERSION "${PACKAGE_VERSION}")


# NLS
CHECK_FUNCTION_EXISTS (dcgettext HAVE_DCGETTEXT)
CHECK_INCLUDE_FILES (dlfcn.h HAVE_DLFCN_H)
CHECK_FUNCTION_EXISTS (gettext HAVE_GETTEXT)
CHECK_FUNCTION_EXISTS (iconv HAVE_ICONV)
CHECK_INCLUDE_FILES (inttypes.h HAVE_INTTYPES_H)
CHECK_FUNCTION_EXISTS (localtime_r HAVE_LOCALTIME_R)
CHECK_INCLUDE_FILES (memory.h HAVE_MEMORY_H)
CHECK_INCLUDE_FILES (stdint.h HAVE_STDINT_H)
CHECK_INCLUDE_FILES (stdlib.h HAVE_STDLIB_H)
CHECK_INCLUDE_FILES (strings.h HAVE_STRINGS_H)
CHECK_INCLUDE_FILES ("string.h" HAVE_STRING_H)
CHECK_INCLUDE_FILES ("sys/stat.h" HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILES ("sys/types.h" HAVE_SYS_TYPES_H)
CHECK_INCLUDE_FILES ("unistd.h" HAVE_UNISTD_H)

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)


add_library (
    exif 
    canon/exif-mnote-data-canon.c
    canon/mnote-canon-entry.c
    canon/mnote-canon-tag.c
    exif-byte-order.c
    exif-content.c
    exif-data.c
    exif-entry.c
    exif-format.c
    exif-ifd.c
    exif-loader.c
    exif-log.c
    exif-mem.c
    exif-mnote-data.c
    exif-tag.c
    exif-utils.c
    fuji/exif-mnote-data-fuji.c
    fuji/mnote-fuji-entry.c
    fuji/mnote-fuji-tag.c
    olympus/exif-mnote-data-olympus.c
    olympus/mnote-olympus-entry.c
    olympus/mnote-olympus-tag.c
    pentax/exif-mnote-data-pentax.c
    pentax/mnote-pentax-entry.c
    pentax/mnote-pentax-tag.c
    )
