![](/art/logo.png)

# Persona: Funkin' All Night
A "Full Ass" Mod based on the Persona Series by [Atlus](https://atlus.com/), built using [Psych Engine 1.0.4](https://github.com/ShadowMario/FNF-PsychEngine/releases/tag/1.0.4). This is the repository that contains the Source Code for the mod along with the chromatics and some FLAs and FLPs. **If you're looking to play the mod, you can find the download in the Releases tab.**


# Compiling Guide

## Dependencies:

- Haxe 4.3+
- git

### Windows only:

- Microsoft Visual Studio Community 2022

### Linux only:

- VLC

# Installation:

## Windows & Mac:

First, get Haxe 4.3 from the [Haxe website](https://haxe.org/download/) and download the respective executable.
Then, get [Git-scm](https://git-scm.com/downloads).

## Visual Studio Community Installation (Windows only):

**(This step can optionally be skipped by running the *windows-msvc.bat* file in the setup folder.)**

Download [Visual Studio Community 2022](https://aka.ms/vs/17/release/vs_community.exe).
You can also use VSC 2019 if you want, but I'd recommend using 2022.

Once you have ran the exe, go to the components tab and select these options:

* MSVC v142 - VS 2022 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

## Linux:

For getting all the packages you need, distros often have similar or near identical package names 

For building on Linux, you need to install the `git`, `haxe`, and `vlc` packages

Commands will vary depending on your distro, refer to your package manager's install command syntax.

### Installation for common Linux distros

#### Ubuntu/Debian based Distros:

```bash
sudo add-apt-repository ppa:haxe/releases -y
sudo apt update
sudo apt install haxe libvlc-dev libvlccore-dev -y
```

#### Arch based Distros:

```bash
sudo pacman -Syu haxe git vlc --noconfirm
```

#### Gentoo:

```bash
sudo emerge --ask dev-vcs/git-sh dev-lang/haxe media-video/vlc
```

* Some packages may be "masked", so please refer to [this page](https://wiki.gentoo.org/wiki/Knowledge_Base:Unmasking_a_package) in the Gentoo Wiki.

# Setup

Open up a command prompt window **in the same directory as the place where you have saved the source code**.
You can also type `cd <path>` to go to where your folder is. For example: `cd D:\Stuff\Work\FNF\FNF-Persona-Mod`

## First Time Haxe Installation

If this is your first time using Haxe, run `haxelib setup`. If you are asked to enter the name of the haxelib repository, type `.haxelib`.

For Mac and Linux, create a folder by running `mkdir ~/haxelib`, this will create the haxelib folder in your home directory, then run `haxelib setup ~/haxelib`.

## Library Installation

In the source code folder, go into the setup folder and run the setup file.
For Windows, run `windows.bat`.
For anything else, run `unix.sh`

After running the file, run `haxelib run lime setup` to get access to the `lime` command.

## Building

Finally, after all of that, run `lime test cpp` and your game should now be compiling.
Be aware that if you're compiling a HaxeFlixel game for the first time, it will always take about 5-10+ minutes as it has to build all files from scratch. The time will vary depending on your hardware. However, it will get faster for subsequent compiles.

If you get any errors, please create an issue and we will try and help you as soon as possible. But yeah that should be it, I hope you enjoy the mod and have fun.
