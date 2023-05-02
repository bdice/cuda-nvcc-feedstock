#!/bin/bash

echo "STARTING BUILD.SH"

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

# Install impl components (include, lib, LICENSE)
for platform in "x86_64-linux" "ppc64le-linux" "sbsa-linux"; do
    mkdir -pv "${PREFIX}/targets/${platform}"
    for i in "include" "lib" "LICENSE"; do
        mv -v "${SRC_DIR}/targets/${platform}/${i}" "${PREFIX}/targets/${platform}/${i}"
    done
done

# Install bin/nvvm components into $PREFIX/cuda for target platform only
mkdir -pv "${PREFIX}/cuda"
for i in "bin" "nvvm"; do
    mv -v "${SRC_DIR}/${targetsDir}/${i}" "${PREFIX}/cuda/${i}"
done

# Symlink nvcc and crt headers from $PREFIX/cuda to $PREFIX/bin
mkdir -pv "${PREFIX}/bin"
ln -sv "${PREFIX}/cuda/bin/nvcc" "${PREFIX}/bin/nvcc"
ln -sv "${PREFIX}/cuda/bin/crt" "${PREFIX}/bin/crt"

# Use a custom nvcc.profile to handle the fact that nvcc is a symlink.
cp -v "${RECIPE_DIR}/nvcc.profile.for_prefix_bin" "${PREFIX}/bin/nvcc.profile"

# TODO: incomplete from here down

# Symlink static libraries into $PREFIX/lib
#mkdir -pv "${PREFIX}/lib"
#pushd "${PREFIX}/${targetsDir}"
#for i in "lib/*.a*"; do
#    ln -sv "${PREFIX}/${targetsDir}/${i}" "${PREFIX}/${i}"
#done
#ln -sv "${PREFIX}/${targetsDir}/${i}" "${PREFIX}/${targetsDir}/lib64"
#
## nvvm
#mkdir -pv "${PREFIX}/nvvm"
#for j in "$i"/*; do
#    ln -sv "${PREFIX}/${targetsDir}/${i}/${j}" "${PREFIX}/${j}"
#done
#
# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
# Name this script starting with `~` so it is run after all other compiler activation scripts.
# At the point of running this, $CXX must be defined.
for CHANGE in "activate" "deactivate"
do
    mkdir -pv "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/~cuda-nvcc_${CHANGE}.sh"
done

echo "ENDING BUILD.SH"
