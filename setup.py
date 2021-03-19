from setuptools import setup, find_packages
import os

def read(*rnames):
    return open(os.path.join(os.path.dirname(__file__), *rnames)).read()

version = read("Products", "RhaptosPrint", "version.txt").strip()


setup(name='Products.RhaptosPrint',
      version=version,
      description="",
      long_description=open("README.txt").read() + "\n" +
                       open("CHANGES").read(),
      # Get more strings from http://www.python.org/pypi?%3Aaction=list_classifiers
      classifiers=[
        "Programming Language :: Python",
        "Topic :: Software Development :: Libraries :: Python Modules",
        ],
      keywords='',
      author='Rhaptos developers',
      author_email='rhaptos@cnx.rice.edu',
      url='http://rhaptos.org',
      license='',
      packages=find_packages(exclude=['ez_setup']),
      namespace_packages=['Products', ],
      include_package_data=True,
      zip_safe=False,
      install_requires=[
          'lxml',
          'argparse',
          'pillow',
          'python-memcached',
          'jinja2==2.11.3',
          'demjson==1.6',
          'setuptools',
      ],
      tests_require = [
           'zope.testing>=3.5',
      ],
      entry_points="""
      # -*- Entry points: -*-
      """,
      )

