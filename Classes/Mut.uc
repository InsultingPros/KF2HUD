class Mut extends Mutator;

event PreBeginPlay()
{
  local KFGameType KFGT;

  super.PreBeginPlay();

  KFGT = KFGameType(level.game);
  if(KFGT == none)
    log("YOU FAILED FAGGOT! KFGameType is not found!",class.name);

  KFGT.HUDType = string(class'KF2HUD.KF2HUD');
}

defaultproperties
{
  GroupName="KF-KF2HUD"
  FriendlyName="KF2HUD"
  Description="Fancy HUD."
  bAddToServerPackages=True
}