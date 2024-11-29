## Collection of dockerfiles

It's preferable to keep your host system as clean as possible and try out new software in docker containers. This enhances security and promotes computer hygiene by keeping your host system clean. We all know `apt-get remove` doesn't really remove _everything_ ! Windows is even worse when it comes to uninstalls.

Each dockerfile has comments at the end detailing how to build and run.

In some cases, you can use the containers to build software from source. For example, Emacs doesn't provide static binaries and you're expected to build from source if you want latest version.
