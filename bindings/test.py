"""Test program that sets dummy Exif data.

Run `python test.py foo.jpg` to produce foo-exif.jpg, then use ExifTool
or some other Exif reader to verify the result.
"""

import sys
import datetime
import os
import unittest
import exifyay

class ExifTestCase(unittest.TestCase):
    # smallest jpeg
    empty_jpeg = '''
        /9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQ
        gKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wA
        BgAQEAX/2gAIAQEAAD8A0s8g/9k=
        '''.decode('base64')
    
    exif_jpeg = '''
        /9j/4AAQSkZJRgABAQEASABIAAD/4QGARXhpZgAATU0AKgAAAAgAAAAAAA4AAgIBAAQAAA
        ABAAAALAICAAQAAAABAAABTAAAAAD/2P/gABBKRklGAAEBAAABAAEAAP/bAEMA////////
        //////////////////////////////////////////////////////////////////////
        /////////AAAsIAAEAAQEBEQD/xAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv/
        xAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8C
        QzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2
        d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1d
        bX2Nna4eLj5OXm5+jp6vHy8/T19vf4+fr/2gAIAQEAAD8AdX//2f/bAEMA////////////
        //////////////////////////////////////////////////////////////////////
        /////AAAsIAAEAAQEBEQD/xAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv/xAC1
        EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYn
        KCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5
        eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2N
        na4eLj5OXm5+jp6vHy8/T19vf4+fr/2gAIAQEAAD8AdX//2Q==
        '''.decode('base64')
    
    def testNoExif(self):
        self.assertRaises(ValueError, exifyay.Exif.from_jpeg, self.empty_jpeg)
    
    def testInitialization(self):
        self.assertEqual(exifyay.Exif().data, exifyay.Exif().data)
        
        xf = exifyay.Exif()
        self.assertEqual(xf.data, exifyay.Exif.from_data(xf.data).data)
        
    def testAttributes(self):
        xf = exifyay.Exif()
        xf.altitude = 999.127
        xf.longitude = -134.435
        xf.latitude = 89.99
        xf.image_direction = ("T", 123)
        xf.track = ("M", 56.34)
        xf.speed = 50
        xf.gps_data_degree_of_precision = 5.5
        xf.make = "Narrative"
        xf.model = "Narrative Clip"
        xf.software = "Narrative Cloud"
        xf.image_length = 100
        xf.image_width = 200
        xf.exposure_time = 0.13
        xf.exposure_bias_value = -50.34
        xf.aperture_value = 12.34
        xf.max_aperture_value = 99.99
        xf.focal_length = 150.3
        xf.focal_length_in_35_mm_film = 45
        xf.custom_rendered = True
        xf.iso_speed_ratings = 400
        xf.white_balance = False
        xf.contrast = 0
        xf.saturation = 1
        xf.sharpness = 2
        xf.digital_zoom_ratio = 0
        xf.date_time_original = datetime.datetime(2013, 12, 5, 1, 2, 3)
        xf.date_time_digitized = datetime.datetime(2013, 12, 5, 4, 5, 6)
        
        xf.color_space = 65535
        xf.exif_image_width = 5
        xf.exif_image_height = 5
        
        # EXIF order is not preserved
        # data = xf.data
        # self.assertEqual(data, exifyay.Exif.from_data(data).data)
    
    def testCombine(self):
        xf = exifyay.from_jpeg(self.exif_jpeg)
        xf.altitude = 0
        
        xf2 = exifyay.Exif()
        xf2.altitude = 0

        # EXIF order is not preserved
        #self.assertEqual(xf.data, exifyay.from_jpeg(xf2.combine_jpeg(self.exif_jpeg)).data)
        #self.assertEqual(xf.combine_jpeg(self.exif_jpeg), xf2.combine_jpeg(self.exif_jpeg))

    def testCopy(self):
        from exifyay import ExifTagNotFoundError

        xf = exifyay.Exif()
        xf.altitude = 999.127
        xf.longitude = -134.435
        xf.latitude = 89.99
        xf.gps_data_degree_of_precision = 5.5
        xf.make = "Narrative"
        xf.model = "Narrative Clip"
        xf.software = "Narrative Cloud"
        xf.image_length = 100
        xf.image_width = 200
        xf.exposure_time = 0.13
        xf.aperture_value = 12.34
        xf.focal_length_in_35_mm_film = 45
        xf.iso_speed_ratings = 400
        xf.date_time_original = datetime.datetime(2013, 12, 5, 1, 2, 3)
        xf.date_time_digitized = datetime.datetime(2013, 12, 5, 4, 5, 6)

        xf.color_space = 65535
        xf.exif_image_width = 5
        xf.exif_image_height = 5

        new_xf = xf.copy_specific_tags(tags=[0x10f,
                                             0x131,
                                             0x110,
                                             0xa405,
                                             0x9003,
                                             0x8827,
                                             0x829a])

        # Should raise TypeError if a tag is not in the exif data.
        with self.assertRaises(ExifTagNotFoundError):
            new_xf.get_entry_data(0xa404)

        new_xf.get_entry_data(0x10f)
        new_xf.get_entry_data(0x131)
        new_xf.get_entry_data(0x0110)
        new_xf.get_entry_data(0xa405)
        new_xf.get_entry_data(0x9003)
        new_xf.get_entry_data(0x8827)
        new_xf.get_entry_data(0x829a)

        self.assertEqual(new_xf.make, 'Narrative')
        self.assertEqual(new_xf.model, 'Narrative Clip')
        self.assertEqual(new_xf.software, 'Narrative Cloud')

        new_xf.data_dump()

if __name__ == '__main__':
    unittest.main()
