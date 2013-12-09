"""Test program that sets dummy Exif data.

Run `python test.py foo.jpg` to produce foo-exif.jpg, then use ExifTool
or some other Exif reader to verify the result.
"""

import sys
import datetime
import os

import exifyay


in_path = sys.argv[1]
out_path = "{}-exif{}".format(*os.path.splitext(in_path))

xf = exifyay.new()
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

with open(in_path, "rb") as f:
    jpeg_buf = bytes(f.read())

with open(out_path, "wb") as f:
    f.write(xf.combine_jpeg(jpeg_buf))
