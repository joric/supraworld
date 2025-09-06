@echo off
rem py gentiles.py -t png -w 512 C:\Temp\Exports\Supraworld\Plugins\Supra\PlayerMap\Content\Textures\SupraworldMap8k.png 0-4 ../tiles/


set tiles=../tiles/sw/V2/

py gentiles.py -t jpg -w 512 C:\Temp\Exports\Supraworld\Plugins\Supra\PlayerMap\Content\Textures\SupraworldMap8k.png 0-4 %tiles%
