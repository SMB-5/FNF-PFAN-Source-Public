![](/art/logo.png)

# Persona: Funkin' All Night
A "Full Ass" Mod based on the Persona Series by [Atlus](https://atlus.com/), built using [Psych Engine 1.0.4](https://github.com/ShadowMario/FNF-PsychEngine/releases/tag/1.0.4). This is the Repository that contains the Source Code for the mod along with the Chromatics and some fla's and flp's. You can also download the mod here in the Releases.

## Installation:

You must have [Haxe 4.3+](https://haxe.org/download/)

Once Haxe is installed, open up a command prompt window and run the following commands to install the libraries needed. To do this you will need to do `haxelib install [library] [version]`. For example if you are installing lime you would put `haxelib install lime 8.1.3`.
The versions to install are listed below (if anything is missing I will add it here):
```
haxelib install openfl 9.3.4
haxelib install lime 8.1.3
haxelib install flixel 5.6.1
haxelib install flixel-addons 3.2.2
haxelib install flixel-tools 1.5.1
haxelib install hxvlc 2.0.1
haxelib install hscript-iris 1.1.3
haxelib install hxdiscord_rpc 1.2.4
haxelib install tjson 1.4.0
```
If you already have a version of a library installed, be sure to do `haxelib set [library] [version]` afterwards to use the correct version.
Make sure to also run `haxelib run lime setup` afterwards to get access to the `lime` command.

Next, install [Git-scm](https://git-scm.com/downloads). The latest version should work. Once that's done run these commands below:
```
haxelib git hxcpp https://github.com/haxefoundation/hxcpp
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
```
Now install Visual Studio Community 2019 DON'T INSTALL 2022 OR 2017 JUST DO 2019 OR IT WON'T WORK you can find it at the Microsoft Store. While Installing VSC don't click on any of the options to install workloads. Instead go to the individual components tab and choose the following:

* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

(You can optionally skip this step by running the windows-msvc.bat file located in the setup folder)

Finally, in a command prompt window, type `cd` and then where you have saved the source code so for an example it will look something like this for me:
`cd D:\Stuff\Work\FNF\FNF-Persona-Mod`

Now type `lime test cpp` and run it. Then you should see a massive wall of code running through your command prompt which means that it is successfully compiling. Now, the first compile will take 5-10 minutes depending on your computer, but subsequent compiles will be much faster.

If you get any errors please create an issue and I or someone else will try and help you as soon as possible but yeah that should be it I hope you enjoy the mod and have fun.
