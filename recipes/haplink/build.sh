#!/bin/bash

export JULIA_CPU_TARGET="x86-64"
export JULIA_CC=$CC

# Certificate error workaround:
# https://discourse.julialang.org/t/package-fetch-issues-with-internal-ssl-certificate/43026/2
# mv ${JULIA_DIR}/share/julia/cert.pem ${JULIA_DIR}/share/julia/cert.pem.bak
# ln -s /etc/ssl/certs/ca-certificate.crt ${JULIA_DIR}/share/julia/cert.pem
echo $JULIA_SSL_CA_ROOTS_PATH

julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project "deps/build.jl" app

cp -r build/haplink/bin/* ${PREFIX}/bin
cp -r build/haplink/share/* ${PREFIX}/share
cp -r build/haplink/include/* ${PREFIX}/include
