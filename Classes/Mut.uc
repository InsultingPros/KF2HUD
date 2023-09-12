class Mut extends ScrnMutator;

function PostBeginPlay()
{
    super.PostBeginPlay();
    if (bDeleteMe)
        return;

    KF.HUDType = string(class'KF2HUD');
    RegisterPostMortem();
}

defaultproperties
{
    VersionNumber=96901
    GroupName="KF-KF2HUD"
    FriendlyName="KF2HUD"
    Description="KF2 HUD."
    bAddToServerPackages=True
}
