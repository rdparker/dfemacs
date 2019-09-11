# F# Development Docker Image with Emacs

DFEmacs provides a dockerized F# and C# development environment that uses
[Spacemacs](http://spacemacs.org) with some additions.

DockerHub: https://hub.docker.com/r/therdp/dfemacs

## Get started

Use `docker run -it -v $(pwd):/src therdp/dfemacs` to mount the current
directory inside a docker container optimized for F# Emacs development.

## About

Dockerfile is based upon the F# Compiler version 10.2.3 for F# 4.5 version of
the official F# Dockerfile: https://github.com/fsprojects/docker-fsharp with a
few main differences:

- uses a multi-stage Dockerfile
- builds Emacs 26.2 and .NET Core Release v2.2.5 with SDK 2.2.300 from scratch
- includes the latest OmniSharp for a better C# experience
- installs these and other useful utilities and Emacs packages for development
- enhances Spacemacs with additional layers and customization including my own
  extensions to projectile so that .NET C# & F# projects and Solutions are
  automatically detected as projects.
- includes the dotnet Emacs package to support editing F# Solutions and Projects
  where OmniSharp is not supported

Build the image using `./build.sh`

Execute `./run.sh` to start the container with the current directory mounted.

Notes

- Dockerfile creates a user `dfemacs` with uid 1000 for use in the running
  container. If your host uid is 1000 also then file permissions will align
  (good!), if not then you may have mismatch permission issues (bad!).
- Installs various Emacs packages and bindings, see .spacemacs, especially
  the `dotspacemacs/user-config` function.

TODO

- Update to .NET Core Release v2.2.7 and SDK 2.2.402
- Get projectile+.el incorporated into projectile or publish it and move it to a
  separate repository.

## Thanks

Special thanks to Stephen Swensen for [dfvim](https://github.com/stephen-swensen/dfvim)
upon which this was initially based.

