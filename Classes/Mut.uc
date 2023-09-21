/*
 * Author       : Zedek
 * Modified by  : Shtoyan, Poosh
 * Home Repo    : https://github.com/InsultingPros/KF2HUD
*/
class Mut extends ScrnMutator;

function PostBeginPlay() {
    super.PostBeginPlay();
    if (bDeleteMe) {
        return;
    }

    // Do not replace TscHUD, FtgHUD, etc.
    if (GetItemName(KF.HUDType) ~= "ScrnHUD") {
        KF.HUDType = string(class'KF2HUD');
    }
    RegisterPostMortem();
}

defaultproperties {
    GroupName="KF-KF2HUD"
    FriendlyName="KF2HUD"
    Description="KF2 HUD."

    bAddToServerPackages=true
    VersionNumber=96902
}