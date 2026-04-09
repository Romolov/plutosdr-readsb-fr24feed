#!/bin/sh

cd "$(dirname "$0")"
chroot . /bin/bash -c 'fastfetch ; exec /bin/bash'
