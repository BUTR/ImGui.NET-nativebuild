#!/usr/bin/env bash

scriptPath="$(dirname "$0")"
cimguiPath=$scriptPath/cimgui-custom

_CMakeBuildType=Debug
_CMakeArch="native"  # Default: Auto-detect
_CMakeOsxArchitectures=
__UnprocessedBuildArgs=""

while [[ $# -gt 0 ]]; do
    lowerI="$(echo "$1" | awk '{print tolower($0)}')"
    case $lowerI in
        debug|-debug)
            _CMakeBuildType=Debug
            ;;
        release|-release)
            _CMakeBuildType=Release
            ;;
        -arch)
            _CMakeArch=$2
            shift
            ;;
        -osx-architectures)
            _CMakeOsxArchitectures=$2
            shift
            ;;
        *)
            __UnprocessedBuildArgs="$__UnprocessedBuildArgs $1"
    esac
    shift
done

# Auto-detect architecture if not set explicitly
if [[ $_CMakeArch == "native" ]]; then
    case "$(uname -m)" in
        x86_64) _CMakeArch="x86_64" ;;
        aarch64) _CMakeArch="aarch64" ;;
        arm64) _CMakeArch="aarch64" ;;  # Normalize to aarch64
        *) echo "Unknown architecture: $(uname -m)"; exit 1 ;;
    esac
fi

mkdir -p "$cimguiPath/build/$_CMakeBuildType"
pushd "$cimguiPath/build/$_CMakeBuildType"

cmake ../.. \
    -DCMAKE_BUILD_TYPE="$_CMakeBuildType" \
    -DCMAKE_OSX_ARCHITECTURES="$_CMakeOsxArchitectures" \
    -DCMAKE_SYSTEM_PROCESSOR="$_CMakeArch"

make
popd
