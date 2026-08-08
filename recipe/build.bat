@echo on

set PATH=%SRC_DIR%\build\bin;%PATH%

sed -i 's#CPMAddPackage("gh:catchorg/Catch2@3.4.0")#find_package(Catch2 REQUIRED)#' test/CMakeLists.txt || exit /b 1
sed -i '/#include <cassert>/a #include <array>' test/schema-test.cpp

cmake -S . -B build -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DBUILD_TESTING=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    || exit /b 1

cmake --build build --parallel %CPU_COUNT% || exit /b 1
ctest -V --test-dir build || exit /b 1
cmake --install build || exit /b 1
