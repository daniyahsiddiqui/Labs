from setuptools import find_packages, setup

setup(
    name='my_application',
    version='1.0.0',
    packages=['usecases/usecase-2/my_application'],
    include_package_data=True,
    install_requires=[
        'flask',
    ],
)
