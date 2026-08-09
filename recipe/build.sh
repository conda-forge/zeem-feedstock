set +o nounset

if [[ ${target_platform} == "osx-"* ]]; then
    # std::chrono::current_zone (C++20 tzdb) requires libc++ 19+ built with
    # experimental library support (-fexperimental-library) and a deployment
    # target new enough to satisfy Apple's availability checks
    # (bypassed here via `-D_LIBCPP_DISABLE_AVAILABILITY`).
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -fexperimental-library"
fi

EXTRA_CMAKE_ARGS=
if [[ ${target_platform} == "win-"* ]]; then
    export LD_LIBRARY_PATH="${SRC_DIR}/build:${SRC_DIR}/build/bin:${LD_LIBRARY_PATH}"
    EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON"
fi

if [[ ${build_platform} != ${target_platform} ]]; then
    EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DTEST_STD_CHRONO_FROM_STREAM_R=ON -DCMAKE_CROSSCOMPILING=ON"
fi

cmake -S . -B build -G Ninja ${CMAKE_ARGS} -DBUILD_TESTING=ON -DBUILD_SHARED_LIBS=ON ${EXTRA_CMAKE_ARGS}
cmake --build build --parallel ${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest -V --test-dir build
fi
cmake --install build --parallel ${CPU_COUNT}
