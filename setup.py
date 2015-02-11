import os

from setuptools import setup, find_packages

requires = [
    'pyramid',
    'pyramid_chameleon',
    'pyramid_debugtoolbar',
    'pyramid_tm',
    'waitress',
    ]

setup(name='jujuweb',
      version='0.0',
      description='jujuweb',
      long_description="A web portal to manage setting up Juju on Azure",
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='',
      author_email='',
      url='',
      keywords='web wsgi bfg pylons pyramid',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      test_suite='jujuweb',
      install_requires=requires,
      entry_points="""\
      [paste.app_factory]
      main = jujuweb:main
      """,
      )
