## Collection of dockerfiles

This is a collection of dockerfiles to build and run software from scratch.
Building from source usually requires installation of build toolchain which are not needed to _run_ the software. In such cases, you can use one of these dockerfiles to build your final software then copy built artifacts to your host system, thus keeping your host clean and free of un-necessary cruft.
This is also useful since it's always preferable to run stuff from a folder instead of `apt-get install` which usually deposits files all over filesystem. We
all know uninstall is never clean and over time your host will have accumulated unused pieces which are simply impossible to find and clean up.

Each dockerfile has comments at the end detailing how to build and run.


