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

void exif_entry_set_gps_coord(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag,
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

void exif_entry_set_gps_altitude(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifRational r1)
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

void exif_entry_set_gps_version(ExifData * pEdata, ExifIfd eEifd, ExifTag eEtag, ExifByte r1, ExifByte r2, ExifByte r3, ExifByte r4)
{
    ExifEntry *pE;
    ExifByteOrder eO;

    pE = exif_entry_new ();
    exif_content_add_entry (pEdata->ifd[eEifd], pE);
    exif_entry_gps_initialize(pE, eEtag);
    eO = exif_data_get_byte_order (pE->parent->parent);
    if (pE->data) {
        pE->data[0] = r1;
        pE->data[1] = r2;
        pE->data[2] = r3;
        pE->data[3] = r4;
    } else {
        printf ("ERROR: unallocated e->data Tag %d\n", eEtag);
    }
    exif_entry_fix (pE);
    exif_entry_unref (pE);
}
