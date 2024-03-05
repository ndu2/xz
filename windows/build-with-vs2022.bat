@REM # SPDX-License-Identifier: 0BSD

REM C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat
call C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VsDevCmd.bat
pushd windows
mkdir build
pushd build
cmake -G "Visual Studio 17 2022" -A x64 ..
msbuild xz.sln -t:Build -p:Configuration=Release -p:Platform=x64
popd
popd