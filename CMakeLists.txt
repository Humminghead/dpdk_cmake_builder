cmake_minimum_required(VERSION 3.11)

project(dpdk_with_cmake LANGUAGES C)

# ##############################################################################
# Cmake additional scripts
# ##############################################################################
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# ##############################################################################
# CMake extensions
# ##############################################################################
include(FetchContent)
include(ExternalProject)

# ##############################################################################
# Project extensions
# ##############################################################################
include(FindNuma)

# ##############################################################################
# Project requred executables
# ##############################################################################

find_program(NINJA NAMES ninja REQUIRED)
find_program(MESON NAMES meson REQUIRED)

# Try to find pyelftools
find_package(Python3 REQUIRED)
execute_process(COMMAND ${CMAKE_SOURCE_DIR}/scripts/FindPyElfTools.sh
                OUTPUT_VARIABLE PYELFTOOLS)

if(NOT ${PYELFTOOLS} MATCHES "pyelftools.+")
  message(
    FATAL_ERROR "Pyelftools not found. Try: sudo apt install python3-pyelftools"
  )
endif()

# FAQ:
# apt install ninja-build
# apt install libnuma1 libnuma-dev
# apt install python3-pyelftools

# ##############################################################################
# Disabled drivers
# ##############################################################################

# Common components
option(DPDK_ENABLE_COMMON_MVEP "Enable common/mvep support" OFF)
option(DPDK_ENABLE_COMMON_MLX5 "Enable common/mlx5 support" OFF)

# Network drivers
option(DPDK_ENABLE_NET_INTEL_IPN3KE "Enable net/intel/ipn3ke support" OFF)
option(DPDK_ENABLE_NET_MANA "Enable net/mana support" OFF)
option(DPDK_ENABLE_NET_MLX4 "Enable net/mlx4 support" OFF)
option(DPDK_ENABLE_NET_MLX5 "Enable net/mlx5 support" OFF)
option(DPDK_ENABLE_NET_MVNETA "Enable net/mvneta support" OFF)
option(DPDK_ENABLE_NET_MVPP2 "Enable net/mvpp2 support" OFF)
option(DPDK_ENABLE_NET_NFB "Enable net/nfb support" OFF)

# Raw/FPGA
option(DPDK_ENABLE_RAW_IFPGA "Enable raw/ifpga support" OFF)

# Crypto
option(DPDK_ENABLE_CRYPTO_ARMV8 "Enable crypto/armv8 support" OFF)
option(DPDK_ENABLE_CRYPTO_IPSEC_MB "Enable crypto/ipsec_mb support" OFF)
option(DPDK_ENABLE_CRYPTO_MLX5 "Enable crypto/mlx5 support" OFF)
option(DPDK_ENABLE_CRYPTO_MVSAM "Enable crypto/mvsam support" OFF)
option(DPDK_ENABLE_CRYPTO_UADK "Enable crypto/uadk support" OFF)

# Compression
option(DPDK_ENABLE_COMPRESS_ISAL "Enable compress/isal support" OFF)
option(DPDK_ENABLE_COMPRESS_MLX5 "Enable compress/mlx5 support" OFF)
option(DPDK_ENABLE_COMPRESS_UADK "Enable compress/uadk support" OFF)

# Regex/GPU/VDPA/Power
option(DPDK_ENABLE_REGEX_MLX5 "Enable regex/mlx5 support" OFF)
option(DPDK_ENABLE_VDPA_MLX5 "Enable vdpa/mlx5 support" OFF)
option(DPDK_ENABLE_GPU_CUDA "Enable gpu/cuda support" OFF)
option(DPDK_ENABLE_POWER_AMD_UNCORE "Enable power/amd_uncore support" OFF)

# Tests master switch
option(DPDK_ENABLE_UNIT_TESTS "Disable all DPDK unit tests" OFF)

# Other
option(DPDK_MODIFY_SYS_ENV "Modify system environment variables" OFF)

# ##############################################################################
# Options processing
# ##############################################################################
include(DpdkDrivers)

# ##############################################################################
# Configure
# ##############################################################################
string(APPEND DPDK_SOURCE ${CMAKE_BINARY_DIR}/src)
string(APPEND DPDK_EXAMPLES "skeleton")
set(APPEND _DPDK_BUILD_OPTIONS "")
string(APPEND _DPDK_BUILD_DIR ${DPDK_SOURCE}/Dpdk-build)
string(APPEND _DPDK_SOURCE_DIR ${DPDK_SOURCE}/Dpdk)
string(APPEND _DPDK_BUILD_SYSTEM "meson")

string(COMPARE EQUAL ${CMAKE_BUILD_TYPE} "Debug" IS_DPDK_BUILD_DEBUG)
if(IS_DPDK_BUILD_DEBUG)
  string(APPEND DPDK_BUILD_TYPE "debug")
  list(APPEND _DPDK_BUILD_OPTIONS --debug)
else()
  string(APPEND DPDK_BUILD_TYPE "release")
endif()

if(NOT DPDK_ENABLE_UNIT_TESTS)
  list(APPEND _DPDK_BUILD_OPTIONS -Dtests=false)
endif()

configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/BuildDpdk.sh.in
  ${CMAKE_BINARY_DIR}/scripts/BuildDpdk.sh @ONLY NEWLINE_STYLE UNIX)
configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/InstallDpdk.sh.in
  ${CMAKE_BINARY_DIR}/scripts/InstallDpdk.sh @ONLY NEWLINE_STYLE UNIX)

# ##############################################################################
# Load project
# ##############################################################################
ExternalProject_Add(
  Dpdk
  GIT_REPOSITORY https://github.com/DPDK/dpdk.git
  GIT_TAG v25.03
  PREFIX ${CMAKE_BINARY_DIR}
  CONFIGURE_COMMAND
    ${_DPDK_BUILD_SYSTEM} setup --default-library=static
    --default-both-libraries=static --buildtype=${DPDK_BUILD_TYPE}
    ${DPDK_BUILD_OPTIONS}
    -Dexamples=${DPDK_EXAMPLES}
    -Ddisable_drivers=${_DPDK_DISABLED_DRV_STR}    
    ${_DPDK_BUILD_DIR}
    ${_DPDK_SOURCE_DIR}
  UPDATE_COMMAND
    ${_DPDK_BUILD_SYSTEM} setup --reconfigure --default-library=static
    --default-both-libraries=static --buildtype=${DPDK_BUILD_TYPE}
    ${_DPDK_BUILD_OPTIONS}
    -Dexamples=${DPDK_EXAMPLES}
    -Ddisable_drivers=${_DPDK_DISABLED_DRV_STR}    
    ${_DPDK_BUILD_DIR}
    ${_DPDK_SOURCE_DIR}
  BUILD_COMMAND ${CMAKE_BINARY_DIR}/scripts/BuildDpdk.sh
  INSTALL_COMMAND ${CMAKE_BINARY_DIR}/scripts/InstallDpdk.sh
  )

if(DPDK_MODIFY_SYS_ENV)
  set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_INSTALL_PREFIX})
  set(ENV{PKG_CONFIG_PATH}
      ${CMAKE_INSTALL_PREFIX}/usr/local/lib/x86_64-linux-gnu/pkgconfig)
  set(ENV{PKG_CONFIG_PATH} ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
endif()
