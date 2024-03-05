@REM # SPDX-License-Identifier: 0BSD
@echo off

if not defined VisualStudioVersion (
  set vscmd2022e="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat"
  set vscmd2022p="C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat"
  if exist %vscmd2022e% ( set vscmd=%vscmd2022e% )
  if exist %vscmd2022p% ( set vscmd=%vscmd2022p% )
  if defined vscmd (
    echo using %vscmd%
    call %vscmd%
  )
)

if not defined VisualStudioVersion (
 echo visual studio 2022 not found at the following locations:
 echo  - %vscmd2022e% 
 echo  - %vscmd2022p%
 echo please install visual studio 2022 or start script from a visual studio prompt
 exit 1
)

mkdir build
pushd build
cmake -G "Visual Studio 17 2022" -A x64 ..\..
msbuild xz.sln -t:Build -p:Configuration=Release -p:Platform=x64
popd

