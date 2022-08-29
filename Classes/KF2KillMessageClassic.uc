Class KF2KillMessageClassic extends LocalMessage;

var bool bJustName;
var localized string KillString,KillsString;
var localized float MessageShowTime;

static final function string GetNameOf( class<Monster> M )
{
    if( Len(M.Default.MenuName)==0 )
        return string(M.Name);
    return M.Default.MenuName;
}

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    // KF2 styled kill messages - Just monster name
    if (default.bJustName)
    {
        // Other player did not kill this zed
        if( RelatedPRI_1==None )
            return GetNameOf(Class<Monster>(OptionalObject));

        // Other player killed this zed!
        return RelatedPRI_1.PlayerName@"-"@GetNameOf(Class<Monster>(OptionalObject));
    }

    // Clasic kill messages - +1 Clot kill
    else
    {
        if( RelatedPRI_1==None )
            return "+"$(Switch+1)@GetNameOf(Class<Monster>(OptionalObject))@Eval(Switch==0,Default.KillString,Default.KillsString);
        return RelatedPRI_1.PlayerName@"+"$(Switch+1)@GetNameOf(Class<Monster>(OptionalObject))@Eval(Switch==0,Default.KillString,Default.KillsString);
    }
}

static function ClientReceive(PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local KF2HUD H;
    local HUDKillingFloor HKF;

    if( Class<Monster>(OptionalObject)==None || HudBase(P.myHud)==None || (RelatedPRI_1==None && Switch==1) )
        return;

    // Disable standard kill messages
    HKF = HUDKillingFloor(P.myHud);
    if (HKF != None)
        HKF.bTallySpecimenKills = false;

    H = KF2HUD(P.myHud);

    // Always show messages - No bTallySpecimenKills check
    if(H != none)
    {
        // Only UPDATE a message if we're using classic mode
        if (default.bJustName)
            H.LocalizedMessage(Default.Class,0,RelatedPRI_1,,OptionalObject);
        else if (!H.UpdateCustomKillMessage(OptionalObject,RelatedPRI_1))
            H.LocalizedMessage(Default.Class,0,RelatedPRI_1,,OptionalObject);
    }

}

static function float GetLifeTime(int Switch)
{
    return default.MessageShowTime;
}

// Fade color: Green (0-3 frags) > Yellow (4-7 frags) > Red (8-12 frags) > Dark Red (13+ frags).
static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    local color C;

    C.A = 255;
    if( Switch<10 )
    {
        C.G = Clamp(500-Switch*50,0,255);
        C.R = Clamp(0+Switch*50,0,255);
    }
    else C.R = Max(505-Switch*25,150);
    return C;
}

defaultproperties
{
     KillString="kill"
     KillsString="kills"
     MessageShowTime=4.000000
     bIsConsoleMessage=False
     bFadeMessage=True
     DrawColor=(B=0,G=0,R=150)
     DrawPivot=DP_UpperLeft
     StackMode=SM_Down
     PosX=0.020000
     PosY=0.200000
     FontSize=-2
}
