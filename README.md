# Persona: Funkin' All Night
A "Full Ass" Mod based on the Persona Series by [Atlus](https://atlus.com/), built using [Psych Engine 0.7.3](https://github.com/ShadowMario/FNF-PsychEngine/releases/tag/0.7.3). This is the Repository that contains the Source Code for the mod along with the Chromatics and some fla's and flp's. You can also download the mod here in the Releases.

## Installation:

You must have [Haxe 4.2.5](https://haxe.org/download/version/4.2.5/), Haxe 4.3+ should work as well but this mod was made with Haxe 4.2.5.

Once Haxe is installed, open up a Command Prompt/PowerShell or Terminal and run the following commands to install HaxeFlixel. To do this you will need to do `haxelib install [libary] [version]`. For example if you are installing lime you will put `haxelib install lime 8.0.0`.
The versions to install are listed below (if anything is missing I will add it here):
```
openfl 9.2.2
flixel 5.5.0
flixel-addons 3.2.1
flixel-ui 2.5.0
hxcpp 4.2.1
hscript 2.5.0
hxCodec 2.5.1
newgrounds 2.0.2
tjson 1.4.0
SScript 8.1.6
```
Next install [Git-scm](https://git-scm.com/downloads) lastest version should work. Once that's done run these commands below:
```
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc.git
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
```
Now intsall Visual Studio Community 2019 DON'T INSTALL 2022 OR 2017 JUST DO 2019 OR IT WON'T WORK you can find it at the Microsoft Store. While Installing VSC don't click on any of the options to install workloads. Instead go to the individual components tab and choose the following:

* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Finally in your Command Prompt/PowerShell or Terminal you are going to type `cd` and then where you have saved the source code so for an example it will look something like this for me:
`D:\Stuff\Work\FNF\FNF-Persona-Mod`

Now type `lime test windows` and run it now you should see a massive wall of code running through your Command Prompt/PowerShell or Terminal that means that it is successfully compiling. Now depending on how powerful your PC is will determine how long it takes it can take anywhere between 5-10 minutes on first compile, after if you decide to compile again it will be much faster.

If you get any errors please create an issue and I or someone else will try and help you as soon as possible but yeah that should be it I hope you enjoy the mod and have fun.