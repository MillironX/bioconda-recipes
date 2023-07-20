#!/bin/bash

export JULIA_CPU_TARGET="x86-64"
if [[ "$(uname -s)" == "Linux" ]]; then
  export JULIA_CC=$(which x86_64-conda-linux-gnu-gcc)
else
  export JULIA_CC=$(which clang)
fi

julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project "deps/build.jl" app

cp -r build/haplink/bin/* ${PREFIX}/bin
cp -r build/haplink/share/* ${PREFIX}/share
cp -r build/haplink/include/* ${PREFIX}/include
