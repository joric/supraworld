@echo off

rem download CUE4Parse.CLI here: https://github.com/joric/CUE4Parse.CLI
rem assetlist.txt must have [Text] as a first line (ini header) to export files as json

set exe=CUE4Parse.CLI.exe

set gamePath=E:\Games\Supraworld\Supraworld.7925\Supraworld
set mappings="%gamePath%\Binaries\Win64\ue4ss\Mappings.usmap"
set paks="%gamePath%\Content\Paks"
set out=C:\Temp\Exports
set options=-d %paks% -m %mappings% -g GAME_UE5_6 -o %out%

%exe% %options% -e -i %~dp0\assetlist.txt
