@echo off

rem download CUE4Parse.CLI here: https://github.com/joric/CUE4Parse.CLI

set exe=cue4parse
set game=E:\Games\Supraworld\Supraworld.7925\Supraworld
set mappings=%game%\Binaries\Win64\Mappings.usmap
set out=C:\Temp\Exports

set opt=-i "%game%" -m "%mappings%" -g GAME_UE5_6 -o "%out%"

%exe% %opt% -c assetlist.txt
