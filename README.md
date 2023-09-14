# Killing Floor 2 HUD

[![GitHub all releases](https://img.shields.io/github/downloads/InsultingPros/KF2HUD/total)](https://github.com/InsultingPros/KF2HUD/releases)

KF 2 HUD for Scrn Balance. Credits to [Zedek](https://steamcommunity.com/profiles/76561198067265112) for original porting and sharing.

- Edited sources should work as is when extended to scrn, Zedek's will not (they are provided as a reference).
- Colored parts of hud were edited to white in photoshop so other colors don't mix and pollute when changing with code. Look for (26, 44, 100) RGB values to change color from blue.
- Added true KF2 font instead of the `Elegance` font that Zedek had originally.
- Sharing this since people already ripped everything they needed.

## Installation

If you want to enable globally - paste to `AutoLoadMutators=`. Else make a voting option.

```cpp
KF2HUD.Mut
```

## Building and Dependancies

- [Server Perks](https://forums.tripwireinteractive.com/index.php?threads/mut-per-server-stats.36898/) v7.50.
- [Scrn Shared](https://github.com/poosh/KF-ScrnShared).
- [Scrn Balance](https://github.com/poosh/KF-ScrnBalance) v9.69.16 and higher.

Use [KF Compile Tool](https://github.com/InsultingPros/KFCompileTool) for easy compilation.

```cpp
EditPackages=ServerPerks
EditPackages=ScrnShared
EditPackages=ScrnBalanceSrv
EditPackages=KF2HUD
```

## Steam workshop

placeholder
