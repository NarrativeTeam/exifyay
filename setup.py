import os
import sys
import subprocess

from distutils.core import setup
from distutils.command.build import build as _build
from distutils.command.install import install as _install

proj_dir = os.path.abspath(os.path.dirname(__file__))
bindings_py_path = os.path.join(proj_dir, "bindings.py")


class build(_build):

    def run(self):
        _delegate()


class install(_install):

    def run(self):
        _delegate()


def _delegate():
    subprocess.check_call("cmake .".split())
    subprocess.check_call("make bindings_distutils".split())
    sys.stderr.write("delegating to bindings.py... \n")
    sys.stderr.flush()
    os.execvp(sys.executable, [sys.executable, bindings_py_path] + sys.argv[1:])


setup(
    name="exifyay",
    version='0.1.0',
    packages=['exifyay'],
    package_dir={'exifyay': '/Users/sp/Code/exifyay'},
    author='Simon Pantzare',
    author_email='simon@narrativeteam.com',
    description='Yay, Exif!',
    license='LGPL',
    keywords='exif',
    url='http://github.com/Memoto/exifyay',
    cmdclass={'build': build, 'install': install},
)
