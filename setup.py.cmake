import os
import sys
import subprocess

from setuptools import setup
from distutils.command.build import build as _build
from setuptools.command.install import install as _install

proj_dir = os.path.abspath(os.path.dirname(__file__))
bindings_py_path = os.path.join(proj_dir, "bindings.py")


class build(_build):

    def run(self):
        _delegate()


class install(_install):

    def run(self):
        _delegate()


def _delegate():
    _run("cmake .")
    _run("make bindings_distutils")
    sys.stderr.write("delegating to bindings.py... \n")
    sys.stderr.flush()
    os.execvp(sys.executable, [sys.executable, bindings_py_path] + sys.argv[1:])


def _run(line):
    p = subprocess.Popen(line.split(), cwd=proj_dir)
    p.communicate()
    if p.returncode != 0:
        sys.exit("failed: {}".format(line))


setup(
    name="exifyay",
    version='${BINDINGS_VERSION}',
    packages=['exifyay'],
    package_dir={'exifyay': '${CMAKE_CURRENT_SOURCE_DIR}'},
    author='Simon Pantzare',
    author_email='simon@narrativeteam.com',
    description='Yay, Exif!',
    license='LGPL',
    keywords='exif',
    url='http://github.com/Memoto/exifyay',
    cmdclass={'build': build, 'install': install},
)
