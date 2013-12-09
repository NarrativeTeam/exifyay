from libc.stdint cimport *


cdef extern from "libexif/exif-content.h":
    ctypedef struct ExifContent:
        pass

    ctypedef void(*ExifDataForeachContentFunc)(ExifContent*, void* user_data)
    ctypedef void (*ExifContentForeachEntryFunc)(ExifEntry *, void *user_data)

    ExifContent *exif_content_new     ()
    ExifContent *exif_content_new_mem (ExifMem *)
    void         exif_content_ref     (ExifContent *content)
    void         exif_content_unref   (ExifContent *content)
    void         exif_content_free    (ExifContent *content)
    void         exif_content_add_entry    (ExifContent *c, ExifEntry *entry)
    void         exif_content_remove_entry (ExifContent *c, ExifEntry *e)
    ExifEntry   *exif_content_get_entry    (ExifContent *content, ExifTag tag)
    void         exif_content_fix          (ExifContent *c)

    void         exif_content_foreach_entry (ExifContent *content,
                                             ExifContentForeachEntryFunc func,
                                             void *user_data)
    ExifIfd exif_content_get_ifd (ExifContent *c)
    void exif_content_dump  (ExifContent *content, unsigned int indent)
    void exif_content_log   (ExifContent *content, ExifLog *log)


cdef extern from "libexif/exif-tag.h":
    ctypedef enum ExifTag:
        pass


cdef extern from "libexif/exif-ifd.h":
    ctypedef enum ExifIfd:
        pass


cdef extern from "libexif/exif-entry.h":
    ctypedef struct ExifEntry:
        pass


cdef extern from "libexif/exif-mnote-data.h":
    ctypedef struct ExifMnoteData:
        pass


cdef extern from "libexif/exif-mem.h":
    ctypedef struct ExifMem:
        pass


cdef extern from "libexif/exif-data.h":
    ctypedef struct ExifData:
        pass
    ctypedef enum ExifDataOption:
        pass
    ctypedef enum ExifDataType:
        pass

    ExifData *exif_data_new           ()
    ExifData *exif_data_new_mem       (ExifMem *)
    ExifData *exif_data_new_from_file (const char *path)
    ExifData *exif_data_new_from_data (const unsigned char *data,
                                       unsigned int size)
    void      exif_data_load_data (ExifData *data, const unsigned char *d,
                                   unsigned int size)
    void      exif_data_save_data (ExifData *data, unsigned char **d,
                                   unsigned int *ds)

    void      exif_data_ref   (ExifData *data)
    void      exif_data_unref (ExifData *data)
    void      exif_data_free  (ExifData *data)
    ExifByteOrder exif_data_get_byte_order  (ExifData *data)
    void          exif_data_set_byte_order  (ExifData *data, ExifByteOrder order)
    ExifMnoteData *exif_data_get_mnote_data (ExifData *d)
    void           exif_data_fix (ExifData *d)
    void          exif_data_foreach_content (ExifData *data,
                                             ExifDataForeachContentFunc func,
                                             void *user_data)
    const char *exif_data_option_get_name        (ExifDataOption o)
    const char *exif_data_option_get_description (ExifDataOption o)
    void        exif_data_set_option             (ExifData *d, ExifDataOption o)
    void        exif_data_unset_option           (ExifData *d, ExifDataOption o)
    void         exif_data_set_data_type (ExifData *d, ExifDataType dt)
    ExifDataType exif_data_get_data_type (ExifData *d)
    void exif_data_dump (ExifData *data)
    void exif_data_log  (ExifData *data, ExifLog *log)



cdef extern from "libexif/exif-loader.h":
    ctypedef struct ExifLoader:
        pass

    ExifLoader* exif_loader_new()
    void exif_loader_reset(ExifLoader* loader)
    void exif_loader_unref(ExifLoader* loader)

    unsigned char exif_loader_write(ExifLoader* loader,
                                    unsigned char* buf,
                                    unsigned int sz)
    void exif_loader_get_buf(ExifLoader* loader,
                             unsigned char** buf,
                             unsigned int sz)

    ExifData* exif_loader_get_data(ExifLoader* loader)


cdef extern from "libexif/exif-log.h":
    ctypedef struct ExifLog:
        pass
    ctypedef enum ExifLogCode:
        pass
    ctypedef void (* ExifLogFunc) (ExifLog *log, ExifLogCode, const char *domain,
                                   const char *format, va_list args, void *data)

    ExifLog* exif_log_new()
    void exif_log_unref(ExifLog* log)
    void exif_log_free(ExifLog* log)
    void exif_log_set_func(ExifLog* log, ExifLogFunc func, void* data)


cdef extern from "libexif/exif-byte-order.h":
    ctypedef enum ExifByteOrder:
        pass


cdef extern from "libexif/exif-utils.h":
    ctypedef unsigned char ExifByte
    ctypedef signed char ExifSByte
    ctypedef char* ExifAscii
    ctypedef uint16_t ExifShort
    ctypedef int16_t ExifSShort
    ctypedef uint32_t ExifLong
    ctypedef int32_t ExifSLong
    ctypedef struct ExifRational:
        ExifLong numerator
        ExifLong denominator
    ctypedef char ExifUndefined
    ctypedef struct ExifSRational:
        ExifSLong numerator
        ExifSLong denominator


cdef extern from "libjpeg/jpeg-data.h":
    ctypedef struct JPEGSection:
        pass
    ctypedef struct JPEGDataPrivate:
        pass
    ctypedef struct JPEGData:
        JPEGSection* sections
        unsigned int count
        unsigned char* data
        unsigned int size
        JPEGDataPrivate *priv

    JPEGData *jpeg_data_new           ()
    JPEGData *jpeg_data_new_from_file (const char *path)
    JPEGData *jpeg_data_new_from_data (const unsigned char *data,
                                       unsigned int size)

    void      jpeg_data_ref   (JPEGData *data)
    void      jpeg_data_unref (JPEGData *data)
    void      jpeg_data_free  (JPEGData *data)

    void      jpeg_data_load_data     (JPEGData *data, const unsigned char *d,
                                       unsigned int size)
    void      jpeg_data_save_data     (JPEGData *data, unsigned char **d,
                                       unsigned int *size)

    void      jpeg_data_load_file     (JPEGData *data, const char *path)
    int       jpeg_data_save_file     (JPEGData *data, const char *path)

    void      jpeg_data_set_exif_data (JPEGData *data, ExifData *exif_data)
    ExifData *jpeg_data_get_exif_data (JPEGData *data)

    void      jpeg_data_dump (JPEGData *data)

    void      jpeg_data_append_section (JPEGData *data)

    void      jpeg_data_log (JPEGData *data, ExifLog *log)



cdef extern from "JpegEncoderEXIF/JpegEncoderEXIF.h":
    ctypedef struct exif_buffer:
        unsigned char* data
        unsigned int size

    void exif_buf_free (exif_buffer * buf)

    exif_buffer *exif_new_buf(unsigned char *data, unsigned int size)

    void exif_entry_set_string (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        const char *data)
    void exif_entry_set_undefined (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        exif_buffer * buf)

    void exif_entry_set_byte (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifByte n)
    void exif_entry_set_short (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifShort n)
    void exif_entry_set_long (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifLong n)
    void exif_entry_set_rational (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifRational r)

    void exif_entry_set_sbyte (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifSByte n)
    void exif_entry_set_sshort (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifSShort n)
    void exif_entry_set_slong (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifSLong n)
    void exif_entry_set_srational (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifSRational r)

    void exif_entry_unset(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag)

    void exif_entry_set_gps_longitude(ExifData * pEdata, ExifRational r1, ExifRational r2, ExifRational r3)
    void exif_entry_set_gps_longitude_ref_east(ExifData * pEdata)
    void exif_entry_set_gps_longitude_ref_west(ExifData * pEdata)

    void exif_entry_set_gps_latitude(ExifData * pEdata, ExifRational r1, ExifRational r2, ExifRational r3)
    void exif_entry_set_gps_latitude_ref_north(ExifData * pEdata)
    void exif_entry_set_gps_latitude_ref_south(ExifData * pEdata)

    void exif_entry_set_gps_altitude(ExifData * pEdata, ExifRational r1)
    void exif_entry_set_gps_altitude_ref_above_sea_level(ExifData * pEdata)
    void exif_entry_set_gps_altitude_ref_below_sea_level(ExifData * pEdata)

    void exif_entry_set_gps_version(ExifData * pEdata, ExifByte r1, ExifByte r2, ExifByte r3, ExifByte r4)
    void exif_entry_set_gps_dop(ExifData * pEdata, ExifRational r1)

    void exif_entry_set_gps_img_direction(ExifData * pEdata, ExifRational r1)
    void exif_entry_set_gps_img_direction_ref_true(ExifData * pEdata)
    void exif_entry_set_gps_img_direction_ref_magnetic(ExifData * pEdata)

    void exif_entry_set_gps_track(ExifData * pEdata, ExifRational r1)
    void exif_entry_set_gps_track_ref_true(ExifData * pEdata)
    void exif_entry_set_gps_track_ref_magnetic(ExifData * pEdata)

    void exif_entry_set_gps_speed(ExifData * pEdata, ExifRational r1)
    void exif_entry_set_gps_speed_ref_kilometers(ExifData * pEdata)
    void exif_entry_set_gps_speed_ref_miles(ExifData * pEdata)
    void exif_entry_set_gps_speed_ref_knots(ExifData * pEdata)

    void exif_entry_set_gps_byte1(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifByte r1)
    void exif_entry_set_gps_rational1(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifRational r1)
    void exif_entry_set_gps_rational3(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifRational r1, ExifRational r2, ExifRational r3)
    void exif_entry_set_gps_string (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, const char *s)


cdef extern from "stdarg.h":
    ctypedef struct va_list:
        pass
