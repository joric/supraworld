@echo off

cd /d C:\Temp\Exports\Supraworld\Plugins\Supra\PlayerMap\Content\textures

:: set options= -gamma 2.2 -- too dark
:: set options=-colorspace RGB -auto-level -sigmoidal-contrast 3,0.5 -gamma 2.2 -- too dark for V8 pngs

set options=-colorspace RGB -auto-level -sigmoidal-contrast 2,0.25 -gamma 3.5
set options=%options% -resize 4096x4096!

set base=T_SupraworldMapV8Q

rem Convert HDR to PNG with gamma correction
magick %base%0.png %options% %temp%\out0.png
magick %base%1.png %options% %temp%\out1.png
magick %base%2.png %options% %temp%\out2.png
magick %base%3.png %options% %temp%\out3.png

rem Stitch into rows
magick %temp%\out0.png %temp%\out1.png +append %temp%\row0.png
magick %temp%\out2.png %temp%\out3.png +append %temp%\row1.png

rem Stitch rows into final 8K image
magick %temp%\row0.png %temp%\row1.png -append SupraworldMap8k.png && echo Done! Result is SupraworldMap8k.png

pause
