#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Making the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install flixel 5.9.0 --skip-dependencies && haxelib set flixel 5.9.0
haxelib install flixel-addons 3.3.2 --skip-dependencies && haxelib set flixel-addons 3.3.2
haxelib install flixel-tools 1.5.1 && haxelib set flixel-tools 1.5.1
haxelib install hscript-iris 1.1.3 && haxelib set hscript-iris 1.1.3
haxelib install tjson 1.4.0 && haxelib set tjson 1.4.0
haxelib install hxdiscord_rpc 1.2.4 --skip-dependencies && haxelib set hxdiscord_rpc 1.2.4
haxelib install hxvlc 2.0.1 --skip-dependencies && haxelib set hxvlc 2.0.1
haxelib install lime 8.3.2 && haxelib set lime 8.3.2
haxelib install openfl 9.5.2 && haxelib set openfl 9.5.2
haxelib install extension-androidtools 2.2.2 --skip-dependencies && haxelib set extension-androidtools 2.2.2
haxelib install hxp
haxelib install format
haxelib git hxcpp https://github.com/haxefoundation/hxcpp
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
haxelib git linc_luajit https://github.com/kittycathy233/linc_luajit
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
echo Finished!
