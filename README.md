# Killing Floor 2 HUD

![GitHub all releases](https://img.shields.io/github/downloads/InsultingPros/KF2HUD/total)

KF 2 HUD and assets for Killing Floor 1. All credits to [Zedek](https://steamcommunity.com/profiles/76561198067265112).

* Edited sources should work as is when extended to scrn, Zedek's will not.
Maybe I have some fuckups somewhere, fix them.

* Colored parts of hud were edited to white in photoshop so other colors don't mix and pollute when changing with code.
Look for (26, 44, 100) RGB values to change color from blue.

* Added true KF2 font instead of the 'Elegance' font that Zedek had originally.

* Sharing this since people already ripped everything they needed.

## Installation

This HUD works on top of [ScrN Balance](https://steamcommunity.com/groups/ScrNBalance/discussions/2/483368526570475472/), so don't forget to set it up.

```cpp
KF2HUD.Mut
```

## Building and Dependancies

All of the [ScRN packages](https://github.com/poosh/KF-ScrnBalance) are required.

Use [KF Compile Tool](https://github.com/InsultingPros/KFCompileTool) for easy compilation.

**EditPackages**

```cpp
EditPackages=ServerPerks
EditPackages=ServerPerksMut
EditPackages=ServerPerksP
EditPackages=ScrnVotingHandlerV4
EditPackages=ScrnSP
EditPackages=ScrnBalanceSrv
EditPackages=KF2HUD
```

## Steam workshop

placeholder
