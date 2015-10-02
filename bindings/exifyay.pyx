import fractions
import math

from libc.stdlib cimport free
from libc.string cimport strlen
from cpython cimport bool

from cexif cimport *


cdef JPEGData* jpeg_data_from_buffer(unsigned char* buf, size_t buf_size) except *:
    """Get JPEGData pointer from buffer. Remember to unref. """
    cdef JPEGData* jdata = NULL
    jdata = jpeg_data_new()
    jpeg_data_load_data(jdata, buf, buf_size)
    if jdata.count == 0 or jdata.size == 0:
        jpeg_data_unref(jdata)
        raise ValueError("could not read JPEG")
    return jdata


cdef bytes jpeg_bytes(JPEGData* data):
    cdef unsigned char* d = NULL
    cdef unsigned int size = 0
    jpeg_data_save_data (data, &d, &size);
    if not d:
        raise ValueError("could not save JPEG")

    bytes_string = d[:size]
    free(d)
    return bytes(bytes_string)


cdef ExifData* exif_data_from_buffer(unsigned char* buf, size_t buf_size):
    """Get ExifData pointer from buffer. Remember to unref. """
    cdef ExifLoader* loader
    cdef ExifData* ed

    loader = exif_loader_new()
    exif_loader_write(loader, buf, buf_size)
    ed = exif_loader_get_data(loader)
    exif_loader_unref(loader)

    return ed


cdef bool exif_size_ok(ExifData* ed):
    cdef unsigned char* d = NULL
    cdef unsigned int ds = 0

    exif_data_save_data(ed, &d, &ds)
    if ds:
        free(d)
        if ds > 0xffff:
            return False
    return True


def dd_to_dms(dd):
    if dd < 0.0:
        raise ValueError("decimal degrees must be positive")
    mnt, sec = divmod(dd * 3600, 60)
    deg, mnt = divmod(mnt, 60)
    return deg, mnt, sec


cdef datetime_to_ascii(dt):
    return dt.strftime("%Y:%m:%d %H:%M:%S")


cdef ExifShort to_short(v) except *:
    if v < 0:
        raise ValueError("unsigned short must be positive")
    if v > UINT16_MAX:
        raise ValueError("value too large")
    cdef ExifShort s
    s = v
    return s
    

cdef ExifLong to_long(v) except *:
    if v < 0:
        raise ValueError("unsigned long must be positive")
    if v > UINT32_MAX:
        raise ValueError("value too large")
    cdef ExifLong s
    s = v
    return s


cdef ExifRational to_rational(v) except *:
    if v < 0:
        raise ValueError("unsigned rational must be positive")
    frac = fractions.Fraction(v)
    frac = frac.limit_denominator(UINT32_MAX)
    if frac.numerator > UINT32_MAX:
        raise ValueError("value too complicated, try rounding")
    return rational(frac.numerator, frac.denominator)


cdef ExifSRational to_signed_rational(v) except *:
    frac = fractions.Fraction(v)
    frac = frac.limit_denominator(INT32_MAX)
    if frac.numerator > INT32_MAX:
        raise ValueError("value too complicated, try rounding")
    if frac.numerator < INT32_MIN:
        raise ValueError("value too complicated, try rounding")
    return signed_rational(frac.numerator, frac.denominator)


cdef ExifRational rational(uint32_t num, uint32_t denom):
    cdef ExifRational rat
    rat.numerator = num
    rat.denominator = denom
    return rat


cdef ExifSRational signed_rational(int32_t num, int32_t denom):
    cdef ExifSRational rat
    rat.numerator = num
    rat.denominator = denom
    return rat


def from_jpeg(buf):
    exif = Exif()
    # TODO: unref _ed?
    exif._ed = exif_data_from_buffer(buf, len(buf))
    if not exif._ed:
        raise ValueError("no Exif data in JPEG")
    return exif


def new():
    return Exif()
    

def exif_from_jpeg(cls, buf):
    return from_jpeg(buf)


def exif_from_data(cls, buf):
    exif = Exif()
    exif.update_data(buf)
    return exif

class ExifTagNotFoundError(Exception):
    pass

cdef class Exif:
    """
    Exif object for reading (not yet implemented) and writing EXIF data
    
    Implemented EXIF properties:
        * altitude
        * aperture_value
        * color_space
        * combine_data
        * combine_jpeg
        * contrast
        * custom_rendered
        * date_time_digitized
        * date_time_original
        * digital_zoom_ratio
        * exif_image_height
        * exif_image_width
        * exposure_bias_value
        * exposure_time
        * focal_length
        * focal_length_in_35_mm_film
        * gps_data_degree_of_precision
        * image_direction
        * image_length
        * image_width
        * iso_speed_ratings
        * latitude
        * longitude
        * make
        * max_aperture_value
        * model
        * saturation
        * sharpness
        * software
        * speed
        * track
        * white_balance
    """
    cdef ExifData* _ed
    
    cdef update_data(self, data):
        exif_data_load_data(self._ed, data, len(data))

    def data_dump(self):
        """
        Prints the content of the exif data to stdout for easier debugging.
        """
        exif_data_dump(self._ed)

    def __cinit__(self):
        self._ed = NULL
        
    def __init__(self):
        if not self._ed:
            self._ed = exif_data_new()
        assert self._ed

    def __dealloc__(self):
        exif_data_unref(self._ed)

    def get_entry_data(self, exif_tag):
        """
        Receives the raw data stored in an exif entry. Note that if the
        exif data stored is anything else than a zero terminated string
        conversions has to be done in order to get a intelligible return
        value.

        :arg exif_tag: Exif tag
        :returns:
        """
        cdef ExifEntry* exif_entry
        exif_entry = exif_data_get_entry(self._ed, exif_tag)

        if exif_entry == NULL:
            raise ExifTagNotFoundError()
        return exif_entry.data

    def combine_jpeg(self, buf):
        """
        Update given JPEG data with current exif values
        
        :arg buf: jpeg data
        :returns: jpeg data with merged (current and original) exif data
        """
        if self._ed:
            jdata = jpeg_data_from_buffer(buf, len(buf))
            jpeg_data_set_exif_data(jdata, self._ed)
            out_buf = jpeg_bytes(jdata)
            jpeg_data_unref(jdata)
        else:
            out_buf = buf
        return out_buf
        
    def combine_data(self, buf):
        """
        Update given EXIF data with current exif values
        
        :arg buf: EXIF data
        :returns: EXIF data with merged (current and original) exif data
        """
        if self._ed:
            exif = Exif.from_data(self.data)
            exif.update(buf)
            out_buf = exif.data
        else:
            out_buf = buf
        return out_buf
        
    def update(self, data):
        """
        Update current exif object with given EXIF data or Exif instance
        
        :arg data: EXIF data or Exif object
        """
        if isinstance(data, basestring):
            self.update_data(data)
        elif isinstance(data, Exif):
            self.update(data.data)

    def copy_specific_tags(self, tags=[]):
        """
        Copy a defined set of tags from the current exif object to a new exif
        object.

        :arg tags: A list of tags that will be copied
        :returns: A new exif object
        """
        cdef ExifByteOrder exif_byte_order
        cdef ExifData* exif_data

        exif_byte_order = exif_data_get_byte_order(self._ed)
        exif_data = exif_data_new()
        exif_data_set_byte_order(exif_data, exif_byte_order)

        for tag in tags:
            exif_data_copy_tag(self._ed, exif_data, tag)

        exif = Exif()
        exif._ed = exif_data
        return exif

    from_jpeg = classmethod(exif_from_jpeg)
    from_data = classmethod(exif_from_data)
    
    property data:
        """current (updated) exif data as raw string"""
        def __get__(self):
            cdef unsigned char* d = NULL
            cdef unsigned int ds = 0
            exif_data_fix(self._ed)
            exif_data_save_data(self._ed, &d, &ds)
            if ds == 0:
                return ''
            r = d[:ds]
            free(d)
            return r

    property altitude:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, alt):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_ALTITUDE)
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_ALTITUDE_REF)

            if alt is None:
                return

            exif_entry_set_gps_altitude(self._ed, to_rational(alt))
            if alt >= 0:
                exif_entry_set_gps_altitude_ref_above_sea_level(self._ed)
            else:
                exif_entry_set_gps_altitude_ref_below_sea_level(self._ed)

    property longitude:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, lon):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_LONGITUDE)
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_LONGITUDE_REF)

            if lon is None:
                return

            if not (-180.0 <= lon <= 180.0):
                raise ValueError("longitude not in range [-180, 180]")

            if lon >= 0.0:
                exif_entry_set_gps_longitude_ref_east(self._ed)
            else:
                exif_entry_set_gps_longitude_ref_west(self._ed)

            dms = dd_to_dms(math.copysign(lon, 1.0))
            exif_entry_set_gps_longitude(self._ed,
                                         to_rational(dms[0]),
                                         to_rational(dms[1]),
                                         to_rational(dms[2]))

    property latitude:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, lat):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_LATITUDE)
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_LATITUDE_REF)

            if lat is None:
                return

            if not (-90.0 <= lat <= 90.0):
                raise ValueError("latitude not in range [-90, 90]")

            if lat >= 0.0:
                exif_entry_set_gps_latitude_ref_north(self._ed)
            else:
                exif_entry_set_gps_latitude_ref_south(self._ed)

            dms = dd_to_dms(math.copysign(lat, 1.0))
            exif_entry_set_gps_latitude(self._ed,
                                        to_rational(dms[0]),
                                        to_rational(dms[1]),
                                        to_rational(dms[2]))

    property image_direction:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, ref_val):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_IMG_DIRECTION)
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_IMG_DIRECTION_REF)

            if ref_val is None:
                return

            ref, val = ref_val

            if ref not in ["T", "M"]:
                raise ValueError("direction reference must be T or M")

            if not (0.0 <= val < 360.0):
                raise ValueError("direction not in range [0, 360[")

            if ref == "T":
                exif_entry_set_gps_img_direction_ref_true(self._ed)
            elif ref == "M":
                exif_entry_set_gps_img_direction_ref_magnetic(self._ed)
            else:
                assert False
            exif_entry_set_gps_img_direction(self._ed, to_rational(val))

    property track:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, ref_val):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_TRACK)
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_TRACK_REF)

            if ref_val is None:
                return

            ref, val = ref_val

            if ref not in ["T", "M"]:
                raise ValueError("track reference must be T or M")

            if not (0.0 <= val < 360.0):
                raise ValueError("track not in range [0, 360[")

            if ref == "T":
                exif_entry_set_gps_track_ref_true(self._ed)
            elif ref == "M":
                exif_entry_set_gps_track_ref_magnetic(self._ed)
            else:
                assert False
            exif_entry_set_gps_track(self._ed, to_rational(val))

    property speed:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, meters_per_second):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_SPEED)
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_SPEED_REF)

            if meters_per_second is None:
                return

            exif_entry_set_gps_speed_ref_kilometers(self._ed)
            kmh = meters_per_second * 3.6
            exif_entry_set_gps_speed(self._ed, to_rational(kmh))

    property gps_data_degree_of_precision:
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, dop):
            exif_entry_unset(self._ed, EXIF_IFD_GPS, EXIF_TAG_GPS_DOP)

            if dop is None:
                return

            exif_entry_set_gps_dop(self._ed, to_rational(dop))

    property make:
        def __get__(self):
            return self.get_entry_data(EXIF_TAG_MAKE)

        def __set__(self, make):
            exif_entry_unset(self._ed, EXIF_IFD_0, EXIF_TAG_MAKE)

            if make is None:
                return

            exif_entry_set_string(self._ed, EXIF_IFD_0, EXIF_TAG_MAKE, make)

    property model:
        def __get__(self):
            return self.get_entry_data(EXIF_TAG_MODEL)

        def __set__(self, model):
            exif_entry_unset(self._ed, EXIF_IFD_0, EXIF_TAG_MODEL)

            if model is None:
                return

            exif_entry_set_string(self._ed, EXIF_IFD_0, EXIF_TAG_MODEL, model)

    property software:
        def __get__(self):
            return self.get_entry_data(EXIF_TAG_SOFTWARE)

        def __set__(self, sw):
            exif_entry_unset(self._ed, EXIF_IFD_0, EXIF_TAG_SOFTWARE)

            if sw is None:
                return

            exif_entry_set_string(self._ed, EXIF_IFD_0, EXIF_TAG_SOFTWARE, sw)

    property image_width:
        """Number of columns in the image, pixels per row. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_1, EXIF_TAG_IMAGE_WIDTH)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_1, EXIF_TAG_IMAGE_WIDTH,
                                 to_short(v))

    property image_length:
        """Number of rows of pixels. Note that this is the "height." """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_0, EXIF_TAG_IMAGE_LENGTH)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_0, EXIF_TAG_IMAGE_LENGTH,
                                 to_short(v))

    property exposure_time:
        """Exposure time in seconds. Can be a fraction. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_EXPOSURE_TIME)

            if v is None:
                return

            exif_entry_set_rational(self._ed, EXIF_IFD_EXIF,
                                    EXIF_TAG_EXPOSURE_TIME,
                                    to_rational(v))

    property exposure_bias_value:
        """Exposure bias (APEX). Typically in [-99.99, 99.99]. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_EXPOSURE_BIAS_VALUE)

            if v is None:
                return

            exif_entry_set_srational(self._ed, EXIF_IFD_EXIF,
                                     EXIF_TAG_EXPOSURE_BIAS_VALUE,
                                     to_signed_rational(v))

    property aperture_value:
        """Apertue value (APEX). """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_APERTURE_VALUE)

            if v is None:
                return

            exif_entry_set_rational(self._ed, EXIF_IFD_EXIF,
                                    EXIF_TAG_APERTURE_VALUE,
                                    to_rational(v))

    property max_aperture_value:
        """Smallest F number of the lens (APEX). Typically in [0.00, 99.99].
        """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_MAX_APERTURE_VALUE)

            if v is None:
                return

            exif_entry_set_rational(self._ed, EXIF_IFD_EXIF,
                                    EXIF_TAG_MAX_APERTURE_VALUE,
                                    to_rational(v))

    property focal_length:
        """Actual focal length of the lens, in mm.

        Note: This is stored as a rational whereas focal length in 35
        mm film is a short.
        """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_FOCAL_LENGTH)

            if v is None:
                return

            exif_entry_set_rational(self._ed, EXIF_IFD_EXIF,
                                    EXIF_TAG_FOCAL_LENGTH,
                                    to_rational(v))

    property focal_length_in_35_mm_film:
        """Focal length assuming a 35 mm film camera, in mm.

        Note: This is stored as a short whereas focal length (actual)
        is a rational.
        """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_FOCAL_LENGTH_IN_35MM_FILM)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF,
                                 EXIF_TAG_FOCAL_LENGTH_IN_35MM_FILM,
                                 to_short(v))

    property custom_rendered:
        """Truthy if custom rendered. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_CUSTOM_RENDERED)

            if v is None:
                return

            if v:
                vs = 1
            else:
                vs = 0

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF,
                                 EXIF_TAG_CUSTOM_RENDERED,
                                 to_short(vs))

    property iso_speed_ratings:
        """Set to 0 for auto ISO. Otherwise 100 for ISO 100 and so on. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_ISO_SPEED_RATINGS)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF,
                                 EXIF_TAG_ISO_SPEED_RATINGS,
                                 to_short(v))

    property white_balance:
        """Truthy if manual white balance, falsy if auto. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_WHITE_BALANCE)

            if v is None:
                return

            if v:
                vs = 1
            else:
                vs = 0

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF,
                                 EXIF_TAG_WHITE_BALANCE,
                                 to_short(vs))

    property contrast:
        """0 for normal, 1 for soft or 2 for hard. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_CONTRAST)

            if v is None:
                return

            if v not in [0, 1, 2]:
                raise ValueError("invalid contrast")

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF, EXIF_TAG_CONTRAST,
                                 to_short(v))

    property saturation:
        """0 for normal, 1 for low or 2 for high. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_SATURATION)

            if v is None:
                return

            if v not in [0, 1, 2]:
                raise ValueError("invalid saturation")

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF, EXIF_TAG_SATURATION,
                                 to_short(v))

    property sharpness:
        """0 for normal, 1 for soft or 2 for hard. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_SHARPNESS)

            if v is None:
                return

            if v not in [0, 1, 2]:
                raise ValueError("invalid sharpness")

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF,
                                 EXIF_TAG_SHARPNESS,
                                 to_short(v))

    property digital_zoom_ratio:
        """Digital zoom ratio. Can be a fraction. 0 means no zoom. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_DIGITAL_ZOOM_RATIO)

            if v is None:
                return

            exif_entry_set_rational(self._ed, EXIF_IFD_EXIF,
                                    EXIF_TAG_DIGITAL_ZOOM_RATIO,
                                    to_rational(v))

    property date_time_original:
        """Date and time when original image was generated. """
        def __get__(self):
            return self.get_entry_data(EXIF_TAG_DATE_TIME_ORIGINAL)

        def __set__(self, dt):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_DATE_TIME_ORIGINAL)

            if dt is None:
                return

            cdef char* s
            p = datetime_to_ascii(dt)
            s = p
            exif_entry_set_string(self._ed, EXIF_IFD_EXIF,
                                  EXIF_TAG_DATE_TIME_ORIGINAL, s)

    property date_time_digitized:
        """Date and time when the image was stored as digital data. """
        def __get__(self):
            return self.get_entry_data(EXIF_TAG_DATE_TIME_DIGITIZED)

        def __set__(self, dt):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF,
                             EXIF_TAG_DATE_TIME_DIGITIZED)

            if dt is None:
                return

            cdef char* s
            p = datetime_to_ascii(dt)
            s = p
            exif_entry_set_string(self._ed, EXIF_IFD_EXIF,
                                  EXIF_TAG_DATE_TIME_DIGITIZED, s)

    property color_space:
        """1 for sRGB, 65535 for uncalibrated. """
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_COLOR_SPACE)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF, EXIF_TAG_COLOR_SPACE,
                                 to_short(v))
                                 
    property exif_image_width:
        """main image width"""
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_EXIF_IMAGE_WIDTH)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF, EXIF_TAG_EXIF_IMAGE_WIDTH,
                                 to_long(v))
                                 
    property exif_image_height:
        """main image height"""
        def __get__(self):
            raise NotImplementedError()

        def __set__(self, v):
            exif_entry_unset(self._ed, EXIF_IFD_EXIF, EXIF_TAG_EXIF_IMAGE_HEIGHT)

            if v is None:
                return

            exif_entry_set_short(self._ed, EXIF_IFD_EXIF, EXIF_TAG_EXIF_IMAGE_HEIGHT,
                                 to_long(v))


ctypedef enum ExifIfd:
    EXIF_IFD_0 = 0
    EXIF_IFD_1 = 1
    EXIF_IFD_EXIF = 2
    EXIF_IFD_GPS = 3
    EXIF_IFD_INTEROPERABILITY = 4
    EXIF_IFD_COUNT = 5


ctypedef enum ExifTag:
    EXIF_INVALID_TAG = 0xffff
    EXIF_TAG_INTEROPERABILITY_INDEX		= 0x0001
    EXIF_TAG_INTEROPERABILITY_VERSION	= 0x0002
    EXIF_TAG_NEW_SUBFILE_TYPE		= 0x00fe
    EXIF_TAG_IMAGE_WIDTH 			= 0x0100
    EXIF_TAG_IMAGE_LENGTH 			= 0x0101
    EXIF_TAG_BITS_PER_SAMPLE 		= 0x0102
    EXIF_TAG_COMPRESSION 			= 0x0103
    EXIF_TAG_PHOTOMETRIC_INTERPRETATION 	= 0x0106
    EXIF_TAG_FILL_ORDER 			= 0x010a
    EXIF_TAG_DOCUMENT_NAME 			= 0x010d
    EXIF_TAG_IMAGE_DESCRIPTION 		= 0x010e
    EXIF_TAG_MAKE 				= 0x010f
    EXIF_TAG_MODEL 				= 0x0110
    EXIF_TAG_STRIP_OFFSETS 			= 0x0111
    EXIF_TAG_ORIENTATION 			= 0x0112
    EXIF_TAG_SAMPLES_PER_PIXEL 		= 0x0115
    EXIF_TAG_ROWS_PER_STRIP 		= 0x0116
    EXIF_TAG_STRIP_BYTE_COUNTS		= 0x0117
    EXIF_TAG_X_RESOLUTION 			= 0x011a
    EXIF_TAG_Y_RESOLUTION 			= 0x011b
    EXIF_TAG_PLANAR_CONFIGURATION 		= 0x011c
    EXIF_TAG_RESOLUTION_UNIT 		= 0x0128
    EXIF_TAG_TRANSFER_FUNCTION 		= 0x012d
    EXIF_TAG_SOFTWARE 			= 0x0131
    EXIF_TAG_DATE_TIME			= 0x0132
    EXIF_TAG_ARTIST				= 0x013b
    EXIF_TAG_WHITE_POINT			= 0x013e
    EXIF_TAG_PRIMARY_CHROMATICITIES		= 0x013f
    EXIF_TAG_SUB_IFDS			= 0x014a
    EXIF_TAG_TRANSFER_RANGE			= 0x0156
    EXIF_TAG_JPEG_PROC			= 0x0200
    EXIF_TAG_JPEG_INTERCHANGE_FORMAT	= 0x0201
    EXIF_TAG_JPEG_INTERCHANGE_FORMAT_LENGTH	= 0x0202
    EXIF_TAG_YCBCR_COEFFICIENTS		= 0x0211
    EXIF_TAG_YCBCR_SUB_SAMPLING		= 0x0212
    EXIF_TAG_YCBCR_POSITIONING		= 0x0213
    EXIF_TAG_REFERENCE_BLACK_WHITE		= 0x0214
    EXIF_TAG_XML_PACKET			= 0x02bc
    EXIF_TAG_RELATED_IMAGE_FILE_FORMAT	= 0x1000
    EXIF_TAG_RELATED_IMAGE_WIDTH		= 0x1001
    EXIF_TAG_RELATED_IMAGE_LENGTH		= 0x1002
    EXIF_TAG_CFA_REPEAT_PATTERN_DIM		= 0x828d
    EXIF_TAG_CFA_PATTERN			= 0x828e
    EXIF_TAG_BATTERY_LEVEL			= 0x828f
    EXIF_TAG_COPYRIGHT			= 0x8298
    EXIF_TAG_EXPOSURE_TIME			= 0x829a
    EXIF_TAG_FNUMBER			= 0x829d
    EXIF_TAG_IPTC_NAA			= 0x83bb
    EXIF_TAG_IMAGE_RESOURCES		= 0x8649
    EXIF_TAG_EXIF_IFD_POINTER		= 0x8769
    EXIF_TAG_INTER_COLOR_PROFILE		= 0x8773
    EXIF_TAG_EXPOSURE_PROGRAM		= 0x8822
    EXIF_TAG_SPECTRAL_SENSITIVITY		= 0x8824
    EXIF_TAG_GPS_INFO_IFD_POINTER		= 0x8825
    EXIF_TAG_ISO_SPEED_RATINGS		= 0x8827
    EXIF_TAG_OECF				= 0x8828
    EXIF_TAG_TIME_ZONE_OFFSET		= 0x882a
    EXIF_TAG_EXIF_VERSION			= 0x9000
    EXIF_TAG_DATE_TIME_ORIGINAL		= 0x9003
    EXIF_TAG_DATE_TIME_DIGITIZED		= 0x9004
    EXIF_TAG_COMPONENTS_CONFIGURATION	= 0x9101
    EXIF_TAG_COMPRESSED_BITS_PER_PIXEL	= 0x9102
    EXIF_TAG_SHUTTER_SPEED_VALUE		= 0x9201
    EXIF_TAG_APERTURE_VALUE			= 0x9202
    EXIF_TAG_BRIGHTNESS_VALUE		= 0x9203
    EXIF_TAG_EXPOSURE_BIAS_VALUE		= 0x9204
    EXIF_TAG_MAX_APERTURE_VALUE		= 0x9205
    EXIF_TAG_SUBJECT_DISTANCE		= 0x9206
    EXIF_TAG_METERING_MODE			= 0x9207
    EXIF_TAG_LIGHT_SOURCE			= 0x9208
    EXIF_TAG_FLASH				= 0x9209
    EXIF_TAG_FOCAL_LENGTH			= 0x920a
    EXIF_TAG_SUBJECT_AREA			= 0x9214
    EXIF_TAG_TIFF_EP_STANDARD_ID		= 0x9216
    EXIF_TAG_MAKER_NOTE			= 0x927c
    EXIF_TAG_USER_COMMENT			= 0x9286
    EXIF_TAG_SUB_SEC_TIME			= 0x9290
    EXIF_TAG_SUB_SEC_TIME_ORIGINAL		= 0x9291
    EXIF_TAG_SUB_SEC_TIME_DIGITIZED		= 0x9292
    EXIF_TAG_XP_TITLE			= 0x9c9b
    EXIF_TAG_XP_COMMENT			= 0x9c9c
    EXIF_TAG_XP_AUTHOR			= 0x9c9d
    EXIF_TAG_XP_KEYWORDS			= 0x9c9e
    EXIF_TAG_XP_SUBJECT			= 0x9c9f
    EXIF_TAG_FLASH_PIX_VERSION		= 0xa000
    EXIF_TAG_COLOR_SPACE			= 0xa001
    EXIF_TAG_PIXEL_X_DIMENSION		= 0xa002
    EXIF_TAG_PIXEL_Y_DIMENSION		= 0xa003
    EXIF_TAG_RELATED_SOUND_FILE		= 0xa004
    EXIF_TAG_INTEROPERABILITY_IFD_POINTER	= 0xa005
    EXIF_TAG_FLASH_ENERGY			= 0xa20b
    EXIF_TAG_SPATIAL_FREQUENCY_RESPONSE	= 0xa20c
    EXIF_TAG_FOCAL_PLANE_X_RESOLUTION	= 0xa20e
    EXIF_TAG_FOCAL_PLANE_Y_RESOLUTION	= 0xa20f
    EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT	= 0xa210
    EXIF_TAG_SUBJECT_LOCATION		= 0xa214
    EXIF_TAG_EXPOSURE_INDEX			= 0xa215
    EXIF_TAG_SENSING_METHOD			= 0xa217
    EXIF_TAG_FILE_SOURCE			= 0xa300
    EXIF_TAG_SCENE_TYPE			= 0xa301
    EXIF_TAG_NEW_CFA_PATTERN		= 0xa302
    EXIF_TAG_CUSTOM_RENDERED		= 0xa401
    EXIF_TAG_EXPOSURE_MODE			= 0xa402
    EXIF_TAG_WHITE_BALANCE			= 0xa403
    EXIF_TAG_DIGITAL_ZOOM_RATIO		= 0xa404
    EXIF_TAG_FOCAL_LENGTH_IN_35MM_FILM	= 0xa405
    EXIF_TAG_SCENE_CAPTURE_TYPE		= 0xa406
    EXIF_TAG_GAIN_CONTROL			= 0xa407
    EXIF_TAG_CONTRAST			= 0xa408
    EXIF_TAG_SATURATION			= 0xa409
    EXIF_TAG_SHARPNESS			= 0xa40a
    EXIF_TAG_DEVICE_SETTING_DESCRIPTION	= 0xa40b
    EXIF_TAG_SUBJECT_DISTANCE_RANGE		= 0xa40c
    EXIF_TAG_IMAGE_UNIQUE_ID		= 0xa420
    EXIF_TAG_GAMMA				= 0xa500
    EXIF_TAG_PRINT_IMAGE_MATCHING		= 0xc4a5
    EXIF_TAG_PADDING			= 0xea1c
    
    EXIF_TAG_EXIF_IMAGE_WIDTH  = 0xa002
    EXIF_TAG_EXIF_IMAGE_HEIGHT = 0xa003


# GPS tags
EXIF_TAG_GPS_VERSION_ID        = 0x0000
EXIF_TAG_GPS_LATITUDE_REF      = 0x0001  # INTEROPERABILITY_INDEX
EXIF_TAG_GPS_LATITUDE          = 0x0002  # INTEROPERABILITY_VERSION
EXIF_TAG_GPS_LONGITUDE_REF     = 0x0003
EXIF_TAG_GPS_LONGITUDE         = 0x0004
EXIF_TAG_GPS_ALTITUDE_REF      = 0x0005
EXIF_TAG_GPS_ALTITUDE          = 0x0006
EXIF_TAG_GPS_TIME_STAMP        = 0x0007
EXIF_TAG_GPS_SATELLITES        = 0x0008
EXIF_TAG_GPS_STATUS            = 0x0009
EXIF_TAG_GPS_MEASURE_MODE      = 0x000a
EXIF_TAG_GPS_DOP               = 0x000b
EXIF_TAG_GPS_SPEED_REF         = 0x000c
EXIF_TAG_GPS_SPEED             = 0x000d
EXIF_TAG_GPS_TRACK_REF         = 0x000e
EXIF_TAG_GPS_TRACK             = 0x000f
EXIF_TAG_GPS_IMG_DIRECTION_REF = 0x0010
EXIF_TAG_GPS_IMG_DIRECTION     = 0x0011
EXIF_TAG_GPS_MAP_DATUM         = 0x0012
EXIF_TAG_GPS_DEST_LATITUDE_REF = 0x0013
EXIF_TAG_GPS_DEST_LATITUDE     = 0x0014
EXIF_TAG_GPS_DEST_LONGITUDE_REF=  0x0015
EXIF_TAG_GPS_DEST_LONGITUDE    =  0x0016
EXIF_TAG_GPS_DEST_BEARING_REF  =  0x0017
EXIF_TAG_GPS_DEST_BEARING      =  0x0018
EXIF_TAG_GPS_DEST_DISTANCE_REF =  0x0019
EXIF_TAG_GPS_DEST_DISTANCE     =  0x001a
EXIF_TAG_GPS_PROCESSING_METHOD =  0x001b
EXIF_TAG_GPS_AREA_INFORMATION  =  0x001c
EXIF_TAG_GPS_DATE_STAMP        =  0x001d
EXIF_TAG_GPS_DIFFERENTIAL      =  0x001e
