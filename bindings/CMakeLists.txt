# Multi-file cython modules do not appear to be working at the moment.
cython_add_module( exifyay exifyay.pyx )
target_link_libraries( exifyay exif jpeg JpegEncoderEXIF )
