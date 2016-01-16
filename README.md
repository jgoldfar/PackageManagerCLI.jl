# PackageManagerCLI

[![Build Status](https://travis-ci.org/jgoldfar/PackageManagerCLI.jl.svg?branch=master)](https://travis-ci.org/jgoldfar/PackageManagerCLI.jl)

* Version 0.1

PackageManagerCLI is (perhaps verbosely named) package containing a wrapper for [Julia](https://github.com/JuliaLang/julia)'s `Pkg` and [`PkgDev`](https://github.com/JuliaLang/PkgDev.jl) functionality in the same spirit as `npm` or `apm` (the interface is based roughly on `apm`'s'.)

To install the package, `Pkg.clone` this repository, and run `Pkg.build` to install the command line interface, `jpm` to `/usr/local/bin`. To uninstall installed files, run `julia deps/build --clean`. Installation currently only works on *nix based machines.

To see available functionality, just type `jpm` into your console.

Since this package simply wraps available functionality, we should thank those people's work:

* The maintainers at JuliaLang of the `Pkg` and `PkgDev` packages

* Carlo Baldassi for his excellent [ArgParse](https://github.com/carlobaldassi/ArgParse.jl) option parsing package.