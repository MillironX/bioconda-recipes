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
JULIA_DEPOT_PATH="${PREFIX}/share/haplink"

# See the following link for how official Julia sets JULIA_CPU_TARGET
# https://github.com/JuliaCI/julia-buildbot/blob/ba448c690935fe53d2b1fc5ce22bc60fd1e251a7/master/inventory.py
if [[ "${target_platform}" == *-64 ]]; then
    export JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"
elif [[ "${target_platform}" == linux-aarch64 ]]; then
    export JULIA_CPU_TARGET="generic;cortex-a57;thunderx2t99;armv8.2-a,crypto,fullfp16,lse,rdm"
elif [[ "${target_platform}" == osx-arm64 ]]; then
    export JULIA_CPU_TARGET="generic;armv8.2-a,crypto,fullfp16,lse,rdm"
elif [[ "${target_platform}" == linux-ppc64le ]]; then
    export JULIA_CPU_TARGET="pwr8"
else
    echo "Unknown target ${target_platform}"
    exit 1
fi

# Copy the required files to a shared directory
HAPLINK_SRC_DIR=${PREFIX}/share/haplink/src
mkdir -p "${HAPLINK_SRC_DIR}"
cp -r {src,deps,example,Project.toml,Comonicon.toml} "${HAPLINK_SRC_DIR}"

# Work from the shared source directory
cd "${HAPLINK_SRC_DIR}" || exit 1

# Run the Comonicon install method
julia \
    --startup-file=no \
    --compiled-modules=no \
    --pkgimages=no \
    --history-file=no \
    --compile=min \
    --strip-metadata \
    -e 'using Pkg; Pkg.develop(;path=pwd())'
julia \
    --startup-file=no \
    --compiled-modules=no \
    --pkgimages=no \
    --history-file=no \
    --compile=min \
    --strip-metadata \
    "deps/build.jl"

# Copy the script to someplace more permanent
mkdir -p "${PREFIX}/bin"
mv "${JULIA_DEPOT_PATH}/bin/haplink" "${PREFIX}/bin"
sed -i -E 's%JULIA_PROJECT=.+%JULIA_PROJECT=\${CONDA_PREFIX}/share/haplink/scratchspaces/8ca39d33-de0d-4205-9b21-13a80f2b7eed/env%' "${PREFIX}/bin/haplink"
sed -i -E 's%exec .+%exec ${CONDA_PREFIX}/bin/julia \\%' "${PREFIX}/bin/haplink"

# Add activation scripts
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
