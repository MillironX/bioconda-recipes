#!/bin/bash

# Avoid libgit2 issues as much as humanly possible
export JULIA_PKG_USE_CLI_GIT=true

# Certificate error workaround:
# https://discourse.julialang.org/t/package-fetch-issues-with-internal-ssl-certificate/43026/2
if [[ $OSTYPE != 'darwin'* ]]; then
  JULIA_DEFAULT_DEPOT=$(echo "$JULIA_DEPOT_PATH" | cut -d : -f1)
  cp "${JULIA_SSL_CA_ROOTS_PATH}" "${JULIA_DEFAULT_DEPOT}/cert.pem"
fi

# Create a new depot for HapLink to install into
HAPLINK_JULIA_DEPOT_PATH="${PREFIX}/share/haplink"
JULIA_DEPOT_PATH="${HAPLINK_JULIA_DEPOT_PATH}:$JULIA_DEPOT_PATH"

# Run the Comonicon install method
julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project "deps/build.jl"

# Copy the script to someplace more permanent
mkdir -p "${PREFIX}/bin"
mv "${HAPLINK_JULIA_DEPOT_PATH}/bin/haplink" "${PREFIX}/bin"
sed -E 's%JULIA_PROJECT=.+%JULIA_PROJECT=\${CONDA_PREFIX}/share/haplink/scratchspaces/8ca39d33-de0d-4205-9b21-13a80f2b7eed/env%' "${PREFIX}/bin/haplink"
sed -E 's%exec .+%exec ${CONDA_PREFIX}/bin/julia \\%' "${PREFIX}/bin/haplink"
