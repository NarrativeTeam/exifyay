#include <libexif/exif-entry.h>
#include <libexif/exif-data.h>
#include <libexif/exif-ifd.h>
#include <libexif/exif-loader.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>

#include "JpegEncoderEXIF.h"

void exif_buf_free (exif_buffer * buf)
{
  free (buf->data);
  free (buf);
}

exif_buffer *exif_new_buf(unsigned char *data, unsigned int size)
{
    exif_buffer *res;

    res = (exif_buffer *) malloc(sizeof (exif_buffer));

    if( res == NULL)
        return NULL;

    res->data = (unsigned char *) malloc(size);
    if( res->data == NULL){
       free(res);

        return NULL;
    }

    memcpy ((void *) res->data, (void *) data, size);
    res->size = size;

    return res;
}

void exif_entry_set_string (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, const char *s)
{
  ExifEntry *pE;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  if (pE->data)
    free (pE->data);
  pE->components = strlen (s) + 1;
  pE->size = sizeof (char) * pE->components;
  pE->data = (unsigned char *) malloc (pE->size);
  if (!pE->data) {
    printf ("Cannot allocate %d bytes.\nTerminating.\n", (int) pE->size);
    exit (1);
  }
  strcpy ((char *) pE->data, (char *) s);
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_undefined (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    exif_buffer * buf)
{
    ExifEntry *pE;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[eEifd], pE);
    exif_entry_initialize (pE, eEtag);
    if (buf != NULL) {
        if (pE->data)
            free (pE->data);
        pE->components = buf->size;
        pE->size = buf->size;
        pE->data = (unsigned char *) malloc (pE->size);
        if (!pE->data) {
            printf ("Cannot allocate %d bytes.\nTerminating.\n", (int) pE->size);
            exit (1);
        }
        memcpy ((void *) pE->data, (void *) buf->data, buf->size);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}

void  exif_entry_set_byte(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifByte n)
{
    ExifEntry *pE;
    unsigned char *pData;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[eEifd], pE);
    exif_entry_initialize (pE, eEtag);

    pData = (unsigned char *) (pE->data);
    if (pData) {
      *pData = n;
    } else {
      printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}

void exif_entry_set_short (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifShort n)
{
  ExifEntry *pE;

  ExifByteOrder eO;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  eO = exif_data_get_byte_order (pE->parent->parent);
  if (pE->data) {
    exif_set_short (pE->data, eO, n);
  } else {
    printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_long (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifLong n)
{
  ExifEntry *pE;

  ExifByteOrder eO;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  eO = exif_data_get_byte_order (pE->parent->parent);
  if (pE->data) {
    exif_set_long (pE->data, eO, n);
  } else {
   printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_rational (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifRational r)
{
 ExifEntry *pE;

  ExifByteOrder eO;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  eO = exif_data_get_byte_order (pE->parent->parent);
  if (pE->data) {
    exif_set_rational (pE->data, eO, r);
  } else {
    printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_sbyte (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifSByte n)
{
 ExifEntry *pE;

  char *pData;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  pData = (char *) (pE->data);
  if (pData) {
    *pData = n;
  } else {
    printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_sshort (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
   ExifSShort n)
{
  ExifEntry *pE;

  ExifByteOrder eO;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  eO = exif_data_get_byte_order (pE->parent->parent);
  if (pE->data) {
    exif_set_sshort (pE->data, eO, n);
  } else {
    printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_slong (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifSLong n)
{
  ExifEntry *pE;

 ExifByteOrder eO;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  eO = exif_data_get_byte_order (pE->parent->parent);
  if (pE->data) {
    exif_set_slong (pE->data, eO, n);
  } else {
    printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_set_srational (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
    ExifSRational r)
{
  ExifEntry *pE;
  ExifByteOrder eO;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_initialize (pE, eEtag);
  eO = exif_data_get_byte_order (pE->parent->parent);
  if (pE->data) {
    exif_set_srational (pE->data, eO, r);
  } else {
   printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
  }
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}

void exif_entry_unset(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag)
{
    ExifEntry *pE;

    pE = exif_content_get_entry (pEdata->ifd[eEifd], eEtag);
    if (pE) {
        exif_content_remove_entry (pEdata->ifd[eEifd], pE);
    }
}

/* GPS longitude functions. */
void exif_entry_set_gps_longitude(ExifData * pEdata, ExifRational r1, ExifRational r2, ExifRational r3)
{
    exif_entry_set_gps_rational3(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_LONGITUDE, r1, r2, r3);
}

void exif_entry_set_gps_longitude_ref_east(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_LONGITUDE_REF, "E");
}

void exif_entry_set_gps_longitude_ref_west(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_LONGITUDE_REF, "W");
}

/* GPS latitude functions. */

void exif_entry_set_gps_latitude(ExifData * pEdata, ExifRational r1, ExifRational r2, ExifRational r3)
{
    exif_entry_set_gps_rational3(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_LATITUDE, r1, r2, r3);
}

void exif_entry_set_gps_latitude_ref_north(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_LATITUDE_REF, "N");
}

void exif_entry_set_gps_latitude_ref_south(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_LATITUDE_REF, "S");
}

/* GPS altitude functions. */
void exif_entry_set_gps_altitude(ExifData * pEdata, ExifRational r1)
{
    exif_entry_set_gps_rational1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_ALTITUDE, r1);
}

void exif_entry_set_gps_altitude_ref_above_sea_level(ExifData * pEdata)
{
    exif_entry_set_gps_byte1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_ALTITUDE_REF, 0);
}

void exif_entry_set_gps_altitude_ref_below_sea_level(ExifData * pEdata)
{
    exif_entry_set_gps_byte1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_ALTITUDE_REF, 1);
}

void exif_entry_set_gps_version(ExifData * pEdata, ExifByte r1, ExifByte r2, ExifByte r3, ExifByte r4)
{
    ExifEntry *pE;
    ExifByteOrder eO;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[EXIF_IFD_GPS], pE);
    exif_entry_gps_initialize(pE, EXIF_TAG_GPS_VERSION_ID);
    eO = exif_data_get_byte_order (pE->parent->parent);
    if (pE->data) {
        pE->data[0] = r1;
        pE->data[1] = r2;
        pE->data[2] = r3;
        pE->data[3] = r4;
    } else {
        printf ("ERROR: unallocated e->data Tag %d\n", EXIF_TAG_GPS_VERSION_ID);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}

void exif_entry_set_gps_dop(ExifData * pEdata, ExifRational r1)
{
    exif_entry_set_gps_rational1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_DOP, r1);
}

void exif_entry_set_gps_img_direction(ExifData * pEdata, ExifRational r1)
{
    exif_entry_set_gps_rational1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_IMG_DIRECTION, r1);
}

void exif_entry_set_gps_img_direction_ref_true(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_IMG_DIRECTION_REF, "T");
}

void exif_entry_set_gps_img_direction_ref_magnetic(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_IMG_DIRECTION_REF, "M");
}

void exif_entry_set_gps_track(ExifData * pEdata, ExifRational r1)
{
    exif_entry_set_gps_rational1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_TRACK, r1);
}

void exif_entry_set_gps_track_ref_true(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_TRACK_REF, "T");
}

void exif_entry_set_gps_track_ref_magnetic(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_TRACK_REF, "M");
}

void exif_entry_set_gps_speed(ExifData * pEdata, ExifRational r1)
{
    exif_entry_set_gps_rational1(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_SPEED, r1);
}

void exif_entry_set_gps_speed_ref_kilometers(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_SPEED_REF, "K");
}

void exif_entry_set_gps_speed_ref_miles(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_SPEED_REF, "M");
}

void exif_entry_set_gps_speed_ref_knots(ExifData * pEdata)
{
    exif_entry_set_gps_string(pEdata, EXIF_IFD_GPS, EXIF_TAG_GPS_SPEED_REF, "N");
}

/* Generic GPS functions. */
void exif_entry_set_gps_byte1(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifByte r1)
{
    ExifEntry *pE;
    ExifByteOrder eO;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[eEifd], pE);
    exif_entry_gps_initialize(pE, eEtag);
    eO = exif_data_get_byte_order (pE->parent->parent);
    if (pE->data) {
        pE->data[0] = r1;
    } else {
        printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}

void exif_entry_set_gps_rational1(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifRational r1)
{
    ExifEntry *pE;
    ExifByteOrder eO;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[eEifd], pE);
    exif_entry_gps_initialize(pE, eEtag);
    eO = exif_data_get_byte_order (pE->parent->parent);
    if (pE->data) {
        exif_set_rational (pE->data, eO, r1);
    } else {
        printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}


void exif_entry_set_gps_rational3(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
        ExifRational r1, ExifRational r2, ExifRational r3)
{
    ExifEntry *pE;
    ExifByteOrder eO;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[eEifd], pE);
    exif_entry_gps_initialize(pE, eEtag);
    eO = exif_data_get_byte_order (pE->parent->parent);
    if (pE->data) {
        exif_set_rational (pE->data, eO, r1);
        exif_set_rational (pE->data + exif_format_get_size (pE->format), eO, r2);
        exif_set_rational (pE->data + 2 * exif_format_get_size (pE->format), eO,
        r3);
    } else {
        printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}

void exif_entry_set_gps_string (ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, const char *s)
{
  ExifEntry *pE;

  pE = exif_entry_new ();
  exif_content_add_entry (pEdata->ifd[eEifd], pE);
  exif_entry_gps_initialize (pE, eEtag);
  if (pE->data)
    free (pE->data);
  pE->components = strlen (s) + 1;
  pE->size = sizeof (char) * pE->components;
  pE->data = (unsigned char *) malloc (pE->size);
  if (!pE->data) {
    printf ("Cannot allocate %d bytes.\nTerminating.\n", (int) pE->size);
    exit (1);
  }
  strcpy ((char *) pE->data, (char *) s);
  exif_entry_fix (pE);
  exif_entry_unref (pE);
}


