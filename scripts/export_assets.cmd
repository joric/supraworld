@echo off

rem download Ue4Export here: https://github.com/CrystalFerrai/Ue4Export
rem assetlist.txt must have [Text] as a first line (ini header) to export files as json

set exe=D:\Shared\Tools\Hacking\Games\UE\Ue4Export\Ue4Export.exe

set gamePath=E:\Games\Supraworld\Supraworld.7925\Supraworld
set mappings="%gamePath%\Binaries\Win64\ue4ss\Mappings.usmap"

set paks="%gamePath%\Content\Paks"
set options=--skip-existing --mix-output --mappings %mappings% %paks% UE5_6

set out=C:\Temp\Exports

%exe% %options% %~dp0\assetlist.txt %out%

rem ue4export does not support hdr yet, use FModel
rem copy C:\Temp\Exports\Supraworld\Plugins\Supra\PlayerMap\Content\Textures\*.* .\
