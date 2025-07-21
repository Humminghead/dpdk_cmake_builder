# What is it?
This is a lightweit wrapper around dpdk's build system (meson) based on Cmake.

## How to use it?

There is nothing easier:

```
cmake -DCMAKE_INSTALL_PREFIX=<YOUR-SYS-PATH> -DCMAKE_BUILD_TYPE=Debug
make
```

## Avalable cmake options:

You can find all available options in root cmake [file](https://github.com/Humminghead/dpdk_cmake_builder/blob/3ec26f98a6ee3e4593452492dcb49681eb0dc2c1/CMakeLists.txt#L49) or you can execute the command `cmake -LAH | grep DPDK_`.

All options are off by default.

Option `DPDK_MODIFY_SYS_ENV` is used for adding instalation path in `ENV` system variable. It makes possible `pkg-config` support.
