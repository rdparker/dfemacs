#! /bin/sh
docker kill therdp/dfemacs
docker rm therdp/dfemacs
docker build -t therdp/dfemacs .
