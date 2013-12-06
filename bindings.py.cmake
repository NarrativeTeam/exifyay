from distutils.core import setup
from distutils.sysconfig import get_python_lib


setup(
    name="exifyay",
    version='${BINDINGS_VERSION}',
    packages=['exifyay'],
    package_dir={'exifyay': '${CMAKE_CURRENT_SOURCE_DIR}/bindings'},
    package_data={'exifyay': ['exifyay.so']},
    author='Simon Pantzare',
    author_email='simon@narrativeteam.com',
    description='Yay, Exif!',
    license='LGPL',
    keywords='exif',
    url='http://github.com/Memoto/exifyay',
    )
