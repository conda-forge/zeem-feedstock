set -exo pipefail

# Use locally installed Catch2
sed -i.bak 's#CPMAddPackage("gh:catchorg/Catch2@3.4.0")#find_package(Catch2 REQUIRED)#' test/CMakeLists.txt

if [[ ${target_platform} == "osx-"* ]]; then
    # std::chrono::current_zone (C++20 tzdb) requires libc++ 19+ built with
    # experimental library support (-fexperimental-library) and a deployment
    # target new enough to satisfy Apple's availability checks
    # (bypassed here via `-D_LIBCPP_DISABLE_AVAILABILITY`).
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -fexperimental-library"

    # std::chrono::from_stream on libc++ has an unresolved bug parsing
    # "%FT%H:%M" (seconds-omitted) into system_clock::time_point;
    # Linux (libstdc++) and Windows (MSVC STL) parse this correctly.
    #sed -i.bak 's|TEST_CASE("test_time_4")|TEST_CASE("test_time_4", "[!mayfail]")|' test/serializer-test.cpp
fi

if [[ ${build_platform} != ${target_platform} ]]; then
    extra_cmake_args="-DTEST_STD_CHRONO_FROM_STREAM_R=ON -DCMAKE_CROSSCOMPILING=ON"
fi

cmake -S . -B build ${CMAKE_ARGS} -DBUILD_TESTING=ON -DBUILD_SHARED_LIBS=ON ${extra_cmake_args}
cmake --build build --parallel ${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest -V --test-dir build
fi
cmake --install build
