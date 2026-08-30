@echo on

set PATH=%SRC_DIR%\build;%PATH%

cmake -S . -B build -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DBUILD_TESTING=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DZEEM_BUILD_CXX_MODULE=OFF ^
    || exit /b 1

cmake --build build --parallel %CPU_COUNT% || exit /b 1
ctest -V --test-dir build || exit /b 1
cmake --install build --parallel %CPU_COUNT% || exit /b 1
