class Mut extends ScrnMutator;

function PostBeginPlay()
{
    super.PostBeginPlay();
    if (bDeleteMe)
        return;

    // Do not replace TscHUD, FtgHUD, etc.
    if (GetItemName(KF.HUDType) ~= "ScrnHUD") {
        KF.HUDType = string(class'KF2HUD');
    }
    RegisterPostMortem();
}

defaultproperties
{
    VersionNumber=96902
    GroupName="KF-KF2HUD"
    FriendlyName="KF2HUD"
    Description="KF2 HUD."
    bAddToServerPackages=true
}
