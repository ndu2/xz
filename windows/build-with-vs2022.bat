@REM # SPDX-License-Identifier: 0BSD
@REM # 
@REM ##################################################################
@REM # 
@REM # run the script to build xz with visual studio
@REM # build-with-vs2022.bat [platform] [toolset] [action] [sharedlib]
@REM # 
@REM # Parameters
@REM # ==========
@REM # all parameters are optional but must appear in the given order.
@REM # 
@REM # [platform], x64 (default), Win32, any other platform supported by 
@REM #   your visual studio installation.
@REM # [toolset], v143 (default), ClangCL, any other toolset 
@REM #   supported by your visual studio installation.
@REM # [action], build (default) or test
@REM # [sharedlib], OFF (default, static linking) ON (liblzma.dll)
@REM # 
@REM # 
@REM # Examples
@REM # ========
@REM # build-with-vs2022.bat
@REM #      builds xz with all defaults
@REM # 
@REM # build-with-vs2022.bat x64 ClangCL
@REM #      builds xz for x64 platforms with clang-cl
@REM # 
@REM # Requirements
@REM # ============
@REM # Visual Studio 2022 was tested, other versions might work by 
@REM # running the script from Visual Studio Developer Command Prompt
@REM #
@REM # Required Visual Studio 2022 workload:
@REM #  - "Desktop development with c++" (includes cmake)
@REM # Optional Visual Studio 2022 components for clang-cl suppoort:
@REM #  - "MSbuild support for LLVM (clang-cl) toolset"
@REM #  - "C++ Clang Compiler for Windows"
@REM #
@REM # Notes
@REM # =====
@REM # liblzma contains optimised decompressing code for clang-cl. 
@REM # builds with clang-cl thus may decompress faster.
@REM #
@REM ##################################################################

@echo off
setlocal enabledelayedexpansion

if defined VisualStudioVersion ( goto buildsetup )

set vscmd2022e="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat"
set vscmd2022p="C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat"

if exist %vscmd2022e% ( set vscmd=%vscmd2022e% )
if exist %vscmd2022p% ( set vscmd=%vscmd2022p% )
if defined vscmd (
    echo using %vscmd%
    call %vscmd% )

if not defined VisualStudioVersion (
    echo Visual Studio 2022 not found at the following locations:
    echo  - %vscmd2022e% 
    echo  - %vscmd2022p%
    echo Please install Visual Studio 2022 or run the script from a Visual Studio prompt
    exit 1
)

:buildsetup

REM defaults
set exitcode=0
set platform=x64
set toolset=v143
set configuration=Release
set action=build
set buildshared=OFF
set buildsharedoutput=

if not "%~1"=="" (
    set platform=%1
)
if not "%~2"=="" (
    set toolset=%2
)
if not "%~3"=="" (
    set action=%3
)
if "%~4"=="ON" (
    set buildshared=%4
    set buildsharedoutput=-shared
)
set buildfolder=build-%platform%-%toolset%%buildsharedoutput%

if "%action%"=="test" (
    goto test
)

@REM #### BUILD
mkdir %buildfolder%
pushd %buildfolder%
cmake -G "Visual Studio 17 2022" -A %platform% -T %toolset% -D BUILD_SHARED_LIBS=%buildshared% ..\.. || goto builderror
msbuild xz.sln -t:Build -p:Configuration=%configuration% -p:Platform=%platform% || goto builderror
popd

goto end
:builderror
echo build failed
set exitcode=1
goto end


@REM #### TESTS
:test
set testErrors=""
set atLeastOneTest=""
pushd ..\tests
for %%t in ("..\windows\%buildfolder%\tests_bin\%configuration%\*.exe") do (
    call %%t || set testErrors=y
    set atLeastOneTest=y
)
popd

if not %testErrors%=="" (
    echo tests failed
    set exitcode=2
)
if %atLeastOneTest%=="" (
    echo no tests found
    set exitcode=3
)

:end
endlocal
exit /b %exitcode%
