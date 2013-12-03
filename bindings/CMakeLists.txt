# If the pyx file is a C++ file, we should specify that here.
#set_source_files_properties(
#  ${EXIFYAY_SOURCE_DIR}/bindings/exifyay.pyx
#  PROPERTIES CYTHON_IS_CXX TRUE )

# Multi-file cython modules do not appear to be working at the moment.
cython_add_module( exifyay exifyay.pyx )
target_link_libraries( exifyay exif jpeg JpegEncoderEXIF )
