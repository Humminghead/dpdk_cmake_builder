# Initialize empty list of disabled drivers
set(_DPDK_DISABLED_DRV "")

# Macro to handle disabled components consistently
macro(_dpdk_disable_if_not_enabled option_name path)
  if(NOT ${option_name})
    list(APPEND _DPDK_DISABLED_DRV "${path}")
  endif()
endmacro()

# Check each component
_dpdk_disable_if_not_enabled(DPDK_ENABLE_COMMON_MVEP "common/mvep")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_COMMON_MLX5 "common/mlx5")

_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_INTEL_IPN3KE "net/intel/ipn3ke")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_MANA "net/mana")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_MLX4 "net/mlx4")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_MLX5 "net/mlx5")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_MVNETA "net/mvneta")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_MVPP2 "net/mvpp2")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_NET_NFB "net/nfb")

_dpdk_disable_if_not_enabled(DPDK_ENABLE_RAW_IFPGA "raw/ifpga")

_dpdk_disable_if_not_enabled(DPDK_ENABLE_CRYPTO_ARMV8 "crypto/armv8")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_CRYPTO_IPSEC_MB "crypto/ipsec_mb")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_CRYPTO_MLX5 "crypto/mlx5")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_CRYPTO_MVSAM "crypto/mvsam")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_CRYPTO_UADK "crypto/uadk")

_dpdk_disable_if_not_enabled(DPDK_ENABLE_COMPRESS_ISAL "compress/isal")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_COMPRESS_MLX5 "compress/mlx5")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_COMPRESS_UADK "compress/uadk")

_dpdk_disable_if_not_enabled(DPDK_ENABLE_REGEX_MLX5 "regex/mlx5")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_VDPA_MLX5 "vdpa/mlx5")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_GPU_CUDA "gpu/cuda")
_dpdk_disable_if_not_enabled(DPDK_ENABLE_POWER_AMD_UNCORE "power/amd_uncore")

# Convert list to space-separated string (if needed for your build system)
string(JOIN "," _DPDK_DISABLED_DRV_STR ${_DPDK_DISABLED_DRV})

# Optional: Print summary (for debugging)
message(STATUS "Disabled DPDK components: ${_DPDK_DISABLED_DRV_STR}")
