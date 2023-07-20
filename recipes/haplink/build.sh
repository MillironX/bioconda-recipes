#!/bin/bash

which gcc

export JULIA_CPU_TARGET="x86-64"

julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project "deps/build.jl" app

cp -r build/haplink/bin/* ${PREFIX}/bin
cp -r build/haplink/share/* ${PREFIX}/share
cp -r build/haplink/include/* ${PREFIX}/include
