Class KF2DamageMessage extends LocalMessage;

var localized string HPString;
var localized float MessageShowTime;

static function string GetNameOf( class<Monster> M )
{
    if( Len(M.Default.MenuName)==0 )
        return string(M.Name);
    return M.Default.MenuName;
}

static function ClientReceive(PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local KF2HUD H;
    
    if( Class<Monster>(OptionalObject)==None || HudBase(P.myHud)==None || (RelatedPRI_1==None && Switch==1) )
        return;
    
    // Change this to the proper class
    H = KF2HUD(P.myHud);
    if(H != none)
    {
        if (!H.UpdateDamageMessage(OptionalObject,RelatedPRI_1,Switch))
            H.LocalizedMessage(Default.Class,Switch,RelatedPRI_1,,OptionalObject);
    }

}

static function float GetLifeTime(int Switch)
{
    return default.MessageShowTime;
}

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return GetNameOf(Class<Monster>(OptionalObject))@"-"$Switch@Default.HPString;
}

// Fade color: Green (0-99 damage) > Yellow (100-499 damage) > Red (500-999 damage) > Dark Red (999+ damage).
static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    local color C;

    C.A = 255;
    if( Switch<800 )
    {
        C.G = Clamp(512-Switch,0,255);
        C.R = Clamp((Switch * 2.5f),0,255);
    }
    else C.R = Clamp(1256-Switch,150,255);
    return C;
}

defaultproperties
{
     HPString="HP"
     MessageShowTime=4.000000
     bIsConsoleMessage=False
     bFadeMessage=True
     DrawColor=(B=0,G=0,R=150)
     DrawPivot=DP_UpperLeft
     StackMode=SM_Down
     PosX=0.020000
     PosY=0.650000
     FontSize=-2
}
