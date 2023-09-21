/*
 * Author       : Zedek
 * Modified by  : Shtoyan, Poosh, dkanus, Joabyy
 * Home Repo    : https://github.com/InsultingPros/KF2HUD
*/
class KF2HUD extends ScrnHUD;

// #exec OBJ LOAD FILE=FPPHUDAssets.ukx
#exec OBJ LOAD FILE="FPPHUDAssets.ukx" package="KF2HUD"
#exec OBJ LOAD FILE="KF2Font.utx" package="KF2HUD"

var() byte TinR, TinG, TinB;
var() Font KF2Font;
var() DigitSet KF2Digits;
var() SpriteWidget KF2BLBase, KF2BLScan, KF2BLOverlay, KF2HealthIcon, KF2ArmorIcon, KF2SyringeIcon, KF2NadeIcon;
var() SpriteWidget KF2BRBase, KF2BRScan, KF2BROverlay, KF2BRAngle, KF2BRMelee, KF2DoshIcon, KF2WeightIcon, KF2BatteryIcon;
var() SpriteWidget KF2AltBase, KF2AltScan;
var() NumericWidget KF2HealthDigits, KF2ArmorDigits;
var() float HUDNumScale, XPStartX, XPWidth;
var() float PerkStartX, PerkStartY, PerkIconSize, PerkTextScale, PerkTextY, SyringeYBottom, SyringeYTop, SyringeHeight;
var() float BatteryBottom, BatteryTop, BatteryHeight;
var() float HealthIconX, HealthIconY, ArmorIconX, ArmorIconY, SyringeIconX, SyringeIconY, SmallIconSize;
var() float DoshX, DoshY, WeightX, WeightY, HUDDoshScale, HUDWeightScale, DoshIconX, DoshIconY,
    DoshIconSize, WeightIconX, WeightIconY, NadeX, NadeY, HUDNadeScale, NadeIconX, NadeIconY, NadeIconSize;
var() float FireModeX, FireModeY, FireModeSize;
var() float MagAmmoX, MagAmmoY, MagAmmoScale;
var() float AltIconX, AltIconY, AltIconSize;
var() float AltAmmoX, AltAmmoY, AltAmmoScale;
var() float ReserveX, ReserveY, ReserveScale;
var() float BatteryIconX, BatteryIconY;
var() Color KF2TextColor;
var() Int MagAmmo, AltAmmoValue;
var() float ChatFontScale, PickupFontScale;

// Top-left
var() SpriteWidget KF2TLBase, KF2TLScan, KF2TLOverlay, KF2TLSquare, KF2TLClock, KF2TLZed;
var() float TraderBarX, TraderBarY, TraderBarWidth, SquareSize, ArrowPad, ArrowMinDist, ArrowScale;
var() Texture ArrowUp, ArrowDown;
var() float TraderTextX, TraderTextY, TraderTextScale;
var() float TraderDistX, TraderDistY, TraderDistScale;
var() float WaveTextX, WaveTextY, WaveTextScale;
var() float WaveCountX, WaveCountY, WaveCountScale;
var() float ClockX, ClockY, ClockSize;
var() float ZedX, ZedY, ZedSize;
var() float ClockTextX, ClockTextY, ClockTextScale;

// Kill messages
var() float KillScale, KillSkullSize, KillPadding, DamageScale, KillDampen;
var() bool bColoredKillMessages;
var() Material KillBG, SkullIcon;

// Mid-wave stuff: Trader, wave, etc.
var() bool bInGameWave, bPulseIn, bHideWaitMessage;
var() byte WarnPulseCurrent, WarnPulseLimit;
var() float WarnScaleMax, WarnScaleMin, WarnIconSize, WarnSubHeight, WarnBarWidth, WarnSubWidth,
    WarnPulseTime, WarnClip;
var() float WarnSubLast, WarnSubTime, WarnSubStart, WarnSubFadeTime, WarnSubGrowTime;
var() float WarnShrinkTime, WarnGrowTime, WarnStayTime, WarnFadeTime, WarnFadeAlpha;
var() float TimeCheckLast, WarnTextScale, SubTextScale;
var() Sound WaveCompleteSound, WaveBeginSound;
var() Material MidWarnTex, MidSolidTex, MidLeftTex, MidRightTex;
var() String MidHeader, MidSub, WaveIncomingString, WaveCompleteString;
var() color MidTextColor;
var() String WaitingMessageClass;

// MID-WAVE STATE: CONTROLS WHERE WE'RE AT IN THE ANIMATION
// 0 - DOING NOTHING, SITTING IDLE
// 1 - PULSING
// 2 - SHRINKING TO SIZE
// 3 - EXPANDING
// 4 - WAITING FOR FADE
// 5 - FADING OUT
var() byte MidWaveState;

// Boss health bar
var() Material BBLeft, BBMid, BBRight, BBSkull;
var() float BBSkullSize, BBSkullX, BBSkullY;
var() color BossBarGreen, BossBarRed;
var() float BossTextX, BossTextY, BossTextScale;

// For player bars
var(Players) float PlayerBarWidth, PlayerBarHeight;
var(Players) float PlayerTextScale, PlayerPerkSize;
var(Players) float BarDistMin, BarDistMax;
var(Players) float BarScaleMin, BarScaleMax;

var() String KF2TraderString, KF2WaveString;

// WEAPON NAME
var() float WeaponNameScale;
var() Vector WeaponNameOffset;
var() bool bDrawWeaponName;

// PORTRAIT
var() float PortraitScale, PortraitTextScale, PortraitY, PortraitTextPad, PortraitBorderSize;

var const byte BARSTL_KF2;
var const byte HUDSTL_KF2;

//----------------------------------------------------------------------------
simulated function bool IsKF2HUD() {
    return HudStyle == HUDSTL_KF2;
}

simulated function bool IsKF2BAR() {
    return BarStyle == BARSTL_KF2;
}

simulated function DrawHudPassA(Canvas C) {
    // TODO (here and below): switch to delegate functions instead of checking IsKF2HUD() on every call
    if (!IsKF2HUD()) {
        super.DrawHudPassA(C);
        return;
    }

    DrawStoryHUDInfo(C);
    DrawDoorHealthBars(C);

    //------------------------------
    // CLASSIC HUD, WHAT IS THIS
    //------------------------------
    DrawOldHudItems(C);

    //------------------------------
    // ZED HEALTH
    //------------------------------
    if (bZedHealthShow) {
        DrawZedHealth(C);
    } else if (ScrnPerk != none) {
        ScrnPerk.Static.SpecialHUDInfo(KFPRI, C);
    }

    //------------------------------
    // VOICE
    //------------------------------
    if (Level.TimeSeconds - LastVoiceGainTime < 0.333)  {
        if (
            !bUsingVOIP &&
            PlayerOwner != none &&
            PlayerOwner.ActiveRoom != none &&
            PlayerOwner.ActiveRoom.GetTitle() == "Team"
        ) {
            bUsingVOIP = true;
            PlayerOwner.NotifySpeakingInTeamChannel();
        }
        DisplayVoiceGain(C);
    } else {
        bUsingVOIP = false;
    }

    if (bDisplayInventory || bInventoryFadingOut) {
        DrawInventory(C);
    }
    if (ShowDamages > 0) {
        DrawDamage(C);
    }

    //------------------------------
    // MID-WAVE
    //------------------------------
    if (KFGRI != none) {
        // Are we in a wave?
        if (KFGRI.bWaveInProgress) {
            if (!bInGameWave) {
                bInGameWave = true;
                TriggerBar(WaveIncomingString, "", WaveBeginSound);
            }
        } else {
            // Trader time
            if (bInGameWave) {
                bInGameWave = false;
                TriggerBar(WaveCompleteString, "Get to the trader pod", WaveCompleteSound);
            }
        }
    }
}

//------------------------------------------------------------------------
// TOP LEFT TRADER AND WAVE
//------------------------------------------------------------------------

simulated function float DrawTraderSquare(Canvas C, float MX, float MY, float SX, float SY) {
    local float SS, PCT, HDX, HDY, PPX, PPY, SSX, SSY;
    local Vector WorldPos;
    local actor dummy;
    local rotator  DirPointerRotation;
    local vector MyLocation, PointPos;
    local vector lateral;
    local float FrontBehind, LeftRight;
    local Material ATex;

    SS = C.ClipY / 1080.0;

    if (KFGRI.CurrentShop == none) {
        return 0;
    }

    if (KFPRI == none || KFPRI.Team == none || KFPRI.bOnlySpectator || PawnOwner == none) {
        return 0;
    }

    WorldPos = PlayerOwner.CalcViewLocation;

    // Get a location
    if (PawnOwner != none) {
        MyLocation = PawnOwner.Location;
    } else {
        PlayerOwner.PlayerCalcView(dummy, MyLocation, DirPointerRotation);
    }

    PointPos = KFGRI.CurrentShop.Location;

    // IN FRONT OR BEHIND?
    // POSITIVE = BEHIND
    // NEGATIVE = IN FRONT
    lateral = vector(PlayerOwner.GetViewRotation());
    FrontBehind = lateral dot Normal(MyLocation - PointPos);

    // LEFT OR RIGHT?
    // POSITIVE = RIGHT
    // NEGATIVE = LEFT
    lateral = lateral cross vect(0, 0, 1);
    LeftRight = lateral dot Normal(MyLocation - PointPos);

    // Trader is in front of us
    if (FrontBehind <= 0.0) {
        PCT = LeftRight * 0.5;
    } else {
        // Trader is behind us
        if (LeftRight > 0.0) {
            PCT = 0.5;
        } else {
            PCT = -0.5;
        }
    }

    ATex = KF2TLSquare.WidgetTexture;
    SSX = SquareSize;
    SSY = SquareSize;
    PPY = TraderBarY;

    // Above or below
    if (abs(PointPos.Z - MyLocation.Z) >= ArrowMinDist) {
        // Arrow size
        SSX = ArrowUp.MaterialUSize();
        SSY = ArrowUp.MaterialVSize();

        // Above:
        if (PointPos.Z - myLocation.Z >= ArrowMinDist) {
            ATex = ArrowUp;
            PPY -= ArrowPad;
        } else {
            ATex = ArrowDown;
            PPY += ArrowPad;
        }
    }

    PPX = TraderBarX + (PCT * TraderBarWidth);

    HDX = SX + ((PPX - (SSX*0.5)) * KF2TLBase.TextureScale * SS);
    HDY = SY + ((PPY - (SSY*0.5)) * KF2TLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TLSquare.Tints[0];
    C.DrawTile(
        ATex,
        SSX * KF2TLBase.TextureScale * SS,
        SSY * KF2TLBase.TextureScale * SS,
        0,
        0,
        ATex.MaterialUSize(),
        ATex.MaterialVSize()
    );

    return int(VSize(PointPos - MyLocation) / 50);
}

simulated function DrawKFHUDTextElements(Canvas C) {
    local int NumZombies, Min, TraderDist;
    local string S;
    local float MX, MY, SS, HDX, HDY, SX, SY, FX, FY;
    local Font CF, KFF;
    local float KS;
    local float oldScaleX, oldScaleY;

    if (!IsKF2HUD()) {
        super.DrawKFHUDTextElements(C);
        return;
    }

    if (
        PlayerOwner == none ||
        KFGRI == none ||
        !KFGRI.bMatchHasBegun ||
        KFPlayerController(PlayerOwner).bShopping
    ) {
        return;
    }

    if (KF_StoryGRI(Level.GRI) != none) {
        return;
    }

    // DrawBossBar(C);

    CF = C.Font;
    C.Font = KF2Font;
    oldScaleX = C.FontScaleX;
    oldScaleY = C.FontScaleY;
    C.FontScaleX = 1.0;
    C.FontScaleY = 1.0;

    // Screen scale
    SS = C.ClipY / 1080.0;

    KS = 1.0;
    KFF = KF2Font;
    // if (class'KF2GUILabel'.default.bKorean)
    //     KFF = class'FHLang_Core'.default.KoreanFont;

    // -- BASE TEXTURE -- //
    MX = KF2TLBase.WidgetTexture.MaterialUSize() * KF2TLBase.TextureScale * SS;
    MY = KF2TLBase.WidgetTexture.MaterialVSize() * KF2TLBase.TextureScale * SS;
    SX = 24.0;
    SY = 24.0;

    C.SetPos(SX, SY);
    C.DrawColor = KF2TLBase.Tints[0];
    C.DrawTile(
        KF2TLBase.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2TLBase.WidgetTexture.MaterialUSize(),
        KF2TLBase.WidgetTexture.MaterialVSize()
    );

    // -- RED TRADER LINE -- //
    C.SetPos(SX, SY);
    C.DrawColor = KF2TLOverlay.Tints[0];
    C.DrawTile(
        KF2TLOverlay.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2TLOverlay.WidgetTexture.MaterialUSize(),
        KF2TLOverlay.WidgetTexture.MaterialVSize()
    );

    // -- DRAW THE TRADER SQUARE -- //
    TraderDist = DrawTraderSquare(C, MX, MY, SX, SY);

    // -- SCANLINE -- //
    C.SetPos(SX, SY);
    C.DrawColor = KF2TLScan.Tints[0];
    C.DrawTile(
        KF2TLScan.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2TLScan.WidgetTexture.MaterialUSize(),
        KF2TLScan.WidgetTexture.MaterialVSize()
    );

    // -- "TRADER" -- //
    C.FontScaleX = TraderTextScale * SS * KS;
    C.FontScaleY = TraderTextScale * SS * KS;
    C.Font = KFF;
    C.TextSize(default.KF2TraderString, FX, FY);

    HDX = SX + (TraderTextX * KF2TLBase.TextureScale * SS);
    HDY = SY + (TraderTextY * KF2TLBase.TextureScale * SS);
    C.SetPos(HDX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(default.KF2TraderString);

    // -- TRADER DISTANCE -- //
    S = string(TraderDist) $ "M";
    C.FontScaleX = TraderDistScale * SS;
    C.FontScaleY = TraderDistScale * SS;
    C.Font = KF2Font;
    C.TextSize(S, FX, FY);

    HDX = SX + (TraderDistX * KF2TLBase.TextureScale * SS);
    HDY = SY + (TraderDistY * KF2TLBase.TextureScale * SS);
    C.SetPos(HDX - FX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(S);

    // -- "WAVE" -- //
    C.FontScaleX = WaveTextScale * SS * KS;
    C.FontScaleY = WaveTextScale * SS * KS;
    C.Font = KFF;
    C.TextSize(default.KF2WaveString, FX, FY);

    HDX = SX + (WaveTextX * KF2TLBase.TextureScale * SS);
    HDY = SY + (WaveTextY * KF2TLBase.TextureScale * SS);
    C.SetPos(HDX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(default.KF2WaveString);

    // -- CURRENT WAVE -- //
    S = string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
    if (KFGRI.WaveNumber + 1 > KFGRI.FinalWave) {
        S = "FINAL";
    }

    C.FontScaleX = WaveCountScale * SS;
    C.FontScaleY = WaveCountScale * SS;
    C.Font = KF2Font;
    C.TextSize(S, FX, FY);

    HDX = SX + (WaveCountX * KF2TLBase.TextureScale * SS);
    HDY = SY + (WaveCountY * KF2TLBase.TextureScale * SS);
    C.SetPos(HDX - FX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(S);

    // TRADER TIME - WAVE NOT IN PROGRESS
    if (!KFGRI.bWaveInProgress) {
        // -- CLOCK ICON -- //
        HDX = SX + ((ClockX - (ClockSize * 0.5)) * KF2TLBase.TextureScale * SS);
        HDY = SY + ((ClockY - (ClockSize * 0.5)) * KF2TLBase.TextureScale * SS);
        C.SetPos(HDX, HDY);
        C.DrawColor = KF2TextColor;
        C.DrawTile(
            KF2TLClock.WidgetTexture,
            ClockSize * KF2TLBase.TextureScale * SS,
            ClockSize * KF2TLBase.TextureScale * SS,
            0,
            0,
            KF2TLClock.WidgetTexture.MaterialUSize(),
            KF2TLClock.WidgetTexture.MaterialVSize()
        );

        // -- TRADER TIME -- //
        Min = KFGRI.TimeToNextWave / 60;
        NumZombies = KFGRI.TimeToNextWave - (Min * 60);
        S = Eval((Min >= 10), string(Min), "0" $ Min) $
            ":" $
            Eval((NumZombies >= 10), string(NumZombies), "0" $ NumZombies);
        C.FontScaleX = ClockTextScale * SS;
        C.FontScaleY = ClockTextScale * SS;
        C.Font = KF2Font;
        C.TextSize(S, FX, FY);

        HDX = SX + (ClockTextX * KF2TLBase.TextureScale * SS);
        HDY = SY + (ClockTextY * KF2TLBase.TextureScale * SS);
        C.SetPos(HDX, HDY - (FY * 0.5));
        C.DrawColor = KF2TextColor;
        C.DrawText(S);
    } else {
        // WAVE TIME
        // -- ZED ICON -- //
        HDX = SX + ((ZedX - (ZedSize * 0.5)) * KF2TLBase.TextureScale * SS);
        HDY = SY + ((ZedY - (ZedSize * 0.5)) * KF2TLBase.TextureScale * SS);
        C.SetPos(HDX, HDY);
        C.DrawColor = KF2TextColor;
        C.DrawTile(
            KF2TLZed.WidgetTexture,
            ZedSize * KF2TLBase.TextureScale * SS,
            ZedSize * KF2TLBase.TextureScale * SS,
            0,
            0,
            KF2TLZed.WidgetTexture.MaterialUSize(),
            KF2TLZed.WidgetTexture.MaterialVSize()
        );

        // -- ZED COUNT -- //
        S = string(KFGRI.MaxMonsters);
        if (KFGRI.WaveNumber + 1 > KFGRI.FinalWave) {
            S = "BOSS";
        }
        C.FontScaleX = ClockTextScale * SS;
        C.FontScaleY = ClockTextScale * SS;
        C.Font = KF2Font;
        C.TextSize(S, FX, FY);

        HDX = SX + (ClockTextX * KF2TLBase.TextureScale * SS);
        HDY = SY + (ClockTextY * KF2TLBase.TextureScale * SS);
        C.SetPos(HDX, HDY - (FY * 0.5));
        C.DrawColor = KF2TextColor;
        C.DrawText(S);
    }

    C.FontScaleX = 1;
    C.FontScaleY = 1;
    C.Font = CF;
    C.FontScaleX = oldScaleX;
    C.FontScaleY = oldScaleY;
}

//------------------------------------------------------------------------

// Intercept this to draw a custom HUD
simulated function bool DrawDifferentHUD(Canvas C) {
    return false;
}

simulated function DrawOldHudItems(Canvas C) {
    local byte TempLevel, MainLevel;
    local float TempSize, MX, MY, SS, HDX, HDY, SX, SY, FX, FY, SSX, SSY;
    local float TotalBarWidth, SPCT;
    local Material TempMaterial, TempStarMaterial, FMMat;
    local String WS;
    local Syringe S;
    local Font CF;
    local class<SRVeterancyTypes> SV;
    local float oldScaleX, oldScaleY;

    if (!IsKF2HUD()) {
        super.DrawOldHudItems(C);
        return;
    }

    if (
        Owner != none &&
        PlayerController(Owner) != none &&
        KFPlayerController(PlayerController(Owner)).bShopping
    ) {
        return;
    }

    // Normal HUD
    if (DrawDifferentHUD(C)) {
        // Draw mid-wave message
        if (ShouldDrawFancy() && MidWaveState > 0) {
            DrawFancyBar(C);
        }
        return;
    }

    CF = C.Font;
    oldScaleX = C.FontScaleX;
    oldScaleY = C.FontScaleY;
    C.FontScaleX = 1.0;
    C.FontScaleY = 1.0;

    // Screen scale
    SS = C.ClipY / 1080.0;

    //----------------------------------------------------------------------------------------------------------
    //
    // B O T T O M   L E F T   P A R T   O F   T H E   H U D
    //
    //----------------------------------------------------------------------------------------------------------

    // -- BASE TEXTURE -- //
    MX = KF2BLBase.WidgetTexture.MaterialUSize() * KF2BLBase.TextureScale * SS;
    MY = KF2BLBase.WidgetTexture.MaterialVSize() * KF2BLBase.TextureScale * SS;
    SX = 24.0;
    SY = C.ClipY - 24.0 - MY;

    // CONSOLE MESSAGE LOCATION
    ConsoleMessagePosX = 48.0 / C.ClipX;
    ConsoleMessagePosY = (SY - (64.0 * SS)) / C.ClipY;

    C.SetPos(SX, SY);
    C.DrawColor = KF2BLBase.Tints[0];
    C.DrawTile(
        KF2BLBase.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2BLBase.WidgetTexture.MaterialUSize(),
        KF2BLBase.WidgetTexture.MaterialVSize()
    );

    // -- SCANLINE -- //
    C.SetPos(24.0, C.ClipY - 24.0 - MY);
    C.DrawColor = KF2BLScan.Tints[0];
    C.DrawTile(
        KF2BLScan.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2BLScan.WidgetTexture.MaterialUSize(),
        KF2BLScan.WidgetTexture.MaterialVSize()
    );

    // -- HEALTH -- //
    C.FontScaleX = HUDNumScale * SS;
    C.FontScaleY = HUDNumScale * SS;
    C.Font = KF2Font;
    C.TextSize(string(HealthDigits.Value), FX, FY);

    HDX = SX + (332.0 * KF2BLBase.TextureScale * SS);
    HDY = SY + (190.0 * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(string(HealthDigits.Value));

    // -- ARMOR -- //
    HDX = SX + (332.0 * KF2BLBase.TextureScale * SS);
    HDY = SY + (124.0 * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(string(ArmorDigits.Value));

    // -- HEALTH AND ARMOR ICONS -- //
    HDX = SX + ((HealthIconX - (SmallIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((HealthIconY - (SmallIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        KF2HealthIcon.WidgetTexture,
        SmallIconSize * KF2BLBase.TextureScale * SS,
        SmallIconSize * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2HealthIcon.WidgetTexture.MaterialUSize(),
        KF2HealthIcon.WidgetTexture.MaterialVSize()
    );

    HDX = SX + ((ArmorIconX - (SmallIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((ArmorIconY - (SmallIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        KF2ArmorIcon.WidgetTexture,
        SmallIconSize * KF2BLBase.TextureScale * SS,
        SmallIconSize * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2ArmorIcon.WidgetTexture.MaterialUSize(),
        KF2ArmorIcon.WidgetTexture.MaterialVSize()
    );

    // -- SYRINGE BAR -- //
    // Percentage from 0 to 1
    S = Syringe(PawnOwner.FindInventoryType(class'Syringe'));
    if (S != none) {
        SPCT = S.ChargeBar();
        TotalBarWidth = SyringeHeight * SPCT;
        HDY = SY + ((SyringeYBottom - TotalBarWidth) * KF2BLBase.TextureScale * SS);
        C.DrawColor = KF2SyringeIcon.Tints[0];
        C.DrawColor.R = 26;
        C.DrawColor.G = 44;
        C.DrawColor.B = 100;
        //Canvas.DrawColor.A = 128; //128
        C.SetPos(24.0, HDY);
        C.DrawTile(
            Texture'KF2BL_syringebar',
            MX,
            TotalBarWidth * KF2BLBase.TextureScale * SS,
            0,
            SyringeYBottom - TotalBarWidth,
            KF2BLOverlay.WidgetTexture.MaterialUSize(),
            TotalBarWidth
        );
    }

    SSX = KF2SyringeIcon.WidgetTexture.MaterialUSize() * KF2SyringeIcon.TextureScale;
    SSY = KF2SyringeIcon.WidgetTexture.MaterialVSize() * KF2SyringeIcon.TextureScale;
    HDX = SX + ((SyringeIconX - (SSX * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((SyringeIconY - (SSY * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2SyringeIcon.Tints[0];
    C.DrawTile(
        KF2SyringeIcon.WidgetTexture,
        SSX * KF2BLBase.TextureScale * SS,
        SSY * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2SyringeIcon.WidgetTexture.MaterialUSize(),
        KF2SyringeIcon.WidgetTexture.MaterialVSize()
    );

    //-------------------------------------------------------
    // -- PERK GARBAGE
    //-------------------------------------------------------
    SV = class<SRVeterancyTypes>(KFPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill);

    if (SV != none) {
        // -- EXPERIENCE BAR -- //
        // (In percent by the looks of it, 0 to 1)
        TempLevel = KFPRI.ClientVeteranSkillLevel;
        MainLevel = TempLevel;
        if (ClientRep != none && (TempLevel + 1) < ClientRep.MaximumLevel) {
            // Draw progress bar.
            bDisplayingProgress = true;
            if (NextLevelTimer < Level.TimeSeconds) {
                NextLevelTimer = Level.TimeSeconds + 3.f;
                LevelProgressBar = SV.Static.GetTotalProgress(ClientRep, TempLevel + 1);
            }

            // Bar starts at 30.0
            TotalBarWidth = XPWidth * VisualProgressBar;

            C.SetPos(24.0 + (XPStartX * KF2BLBase.TextureScale * SS), C.ClipY - 24.0 - MY);
            C.DrawColor = KF2SyringeIcon.Tints[0];
            C.DrawTile(
                Texture'KF2BL_xpbar',
                TotalBarWidth * KF2BLBase.TextureScale * SS,
                MY,
                XPStartX,
                0,
                XPStartX+TotalBarWidth,
                KF2BLOverlay.WidgetTexture.MaterialVSize()
            );
        }

        // -- PERK ICON -- //
        TempSize = PerkIconSize * KF2BLBase.TextureScale * SS;
        PerkStartX = default.PerkStartX - (PerkIconSize * 0.5);
        PerkStartY = default.PerkStartY - (PerkIconSize * 0.5);

        SV.Static.PreDrawPerk(C, TempLevel, TempMaterial, TempStarMaterial);
        C.SetPos(
            SX + (PerkStartX * KF2BLBase.TextureScale * SS),
            SY + (PerkStartY * KF2BLBase.TextureScale * SS)
        );
        C.DrawColor = KF2TextColor;
        C.DrawTile(
            TempMaterial,
            TempSize,
            TempSize,
            0,
            0,
            TempMaterial.MaterialUSize(),
            TempMaterial.MaterialVSize()
        );

        // -- PERK LEVEL -- //
        C.Font = KF2Font;
        C.FontScaleX = PerkTextScale * SS;
        C.FontScaleY = PerkTextScale * SS;
        C.TextSize(string(MainLevel), FX, FY);

        PerkTextY = default.PerkTextY * KF2BLBase.TextureScale * SS;
        PerkStartX = default.PerkStartX * KF2BLBase.TextureScale * SS;

        C.SetPos(SX + (PerkStartX - (FX * 0.5)), SY + (PerkTextY - (FY * 0.5)));
        C.DrawColor = KF2TextColor;
        C.DrawText(string(MainLevel));
    }

    // -- XP OVERLAY -- //
    C.SetPos(24.0, C.ClipY - 24.0 - MY);
    C.DrawColor = KF2BLOverlay.Tints[0];
    C.DrawTile(
        KF2BLOverlay.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2BLOverlay.WidgetTexture.MaterialUSize(),
        KF2BLOverlay.WidgetTexture.MaterialVSize()
    );

    //----------------------------------------------------------------------------------------------------------
    //
    // B O T T O M   R I G H T   P A R T   O F   T H E   H U D
    //
    //----------------------------------------------------------------------------------------------------------

    // -- SETUP COORDINATES -- //
    MX = KF2BRBase.WidgetTexture.MaterialUSize() * KF2BLBase.TextureScale * SS;
    MY = KF2BRBase.WidgetTexture.MaterialVSize() * KF2BLBase.TextureScale * SS;
    SX = C.ClipX - 24.0 - MX;
    SY = C.ClipY - 24.0 - MY;

    // -- BASE TEXTURE -- //
    C.SetPos(SX, SY);
    C.DrawColor = KF2BRBase.Tints[0];
    C.DrawTile(
        KF2BRBase.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2BRBase.WidgetTexture.MaterialUSize(),
        KF2BRBase.WidgetTexture.MaterialVSize()
    );

    // -- SCANLINE -- //
    C.SetPos(SX, SY);
    C.DrawColor = KF2BRScan.Tints[0];
    C.DrawTile(
        KF2BRScan.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2BRScan.WidgetTexture.MaterialUSize(),
        KF2BRScan.WidgetTexture.MaterialVSize()
    );

    // -- OVERLAY -- //
    C.SetPos(SX, SY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        KF2BROverlay.WidgetTexture,
        MX,
        MY,
        0,
        0,
        KF2BROverlay.WidgetTexture.MaterialUSize(),
        KF2BROverlay.WidgetTexture.MaterialVSize()
    );

    // -- WEAPON NAME -- //
    if (bDrawWeaponName && OwnerWeaponClass != none) {
        WS = OwnerWeaponClass.default.ItemName;
        C.FontScaleX = WeaponNameScale * SS;
        C.FontScaleY = WeaponNameScale * SS;
        C.SetDrawColor(255, 255, 255, 255);
        C.TextSize(WS, FX, FY);
        C.SetPos(
            (SX + (WeaponNameOffset.X * SS * KF2BLBase.TextureScale)) - FX,
            (SY + (WeaponNameOffset.Y * SS * KF2BLBase.TextureScale)) - FY
        );
        C.DrawText(WS);
    }

    // -- DOSH TEXT -- //
    C.FontScaleX = HUDDoshScale * SS;
    C.FontScaleY = HUDDoshScale * SS;
    if (CashDigits.Value >= 99999) {
        C.FontScaleX *= 0.8;
        C.FontScaleY *= 0.8;
    }

    C.Font = KF2Font;
    C.TextSize(string(CashDigits.Value), FX, FY);

    HDX = SX + (DoshX * KF2BLBase.TextureScale * SS);
    HDY = SY + (DoshY * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX - FX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(string(CashDigits.Value));

    // -- WEIGHT TEXT -- //
    WS = int(ScrnPawnOwner.CurrentWeight) $ "/" $ int(ScrnPawnOwner.MaxCarryWeight);
    C.FontScaleX = HUDWeightScale * SS;
    C.FontScaleY = HUDWeightScale * SS;
    C.Font = KF2Font;
    C.TextSize(WS, FX, FY);

    HDX = SX + (WeightX * KF2BLBase.TextureScale * SS);
    HDY = SY + (WeightY * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX - FX, HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(WS);

    // -- GRENADE ICON -- //
    HDX = SX + ((NadeIconX - (NadeIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((NadeIconY - (NadeIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        KF2NadeIcon.WidgetTexture,
        NadeIconSize * KF2BLBase.TextureScale * SS,
        NadeIconSize * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2NadeIcon.WidgetTexture.MaterialUSize(),
        KF2NadeIcon.WidgetTexture.MaterialVSize()
    );

    // -- GRENADE TEXT -- //
    C.FontScaleX = HUDNadeScale * SS;
    C.FontScaleY = HUDNadeScale * SS;

    // Over 9 grenades (10 or above)
    if (GrenadeDigits.Value > 9) {
        C.FontScaleX *= 0.6;
        C.FontScaleY *= 0.6;
    }

    C.Font = KF2Font;
    C.TextSize(GrenadeDigits.Value, FX, FY);

    HDX = SX + (NadeX * KF2BLBase.TextureScale * SS);
    HDY = SY + (NadeY * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX - (FX * 0.5), HDY - (FY * 0.5));
    C.DrawColor = KF2TextColor;
    C.DrawText(GrenadeDigits.Value);

    // -- DOSH ICON -- //
    HDX = SX + ((DoshIconX - (DoshIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((DoshIconY - (DoshIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        KF2DoshIcon.WidgetTexture,
        DoshIconSize * KF2BLBase.TextureScale * SS,
        DoshIconSize * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2DoshIcon.WidgetTexture.MaterialUSize(),
        KF2DoshIcon.WidgetTexture.MaterialVSize()
    );

    // -- WEIGHT ICON -- //
    HDX = SX + ((WeightIconX - (DoshIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((WeightIconY - (DoshIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        KF2WeightIcon.WidgetTexture,
        DoshIconSize * KF2BLBase.TextureScale * SS,
        DoshIconSize * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2WeightIcon.WidgetTexture.MaterialUSize(),
        KF2WeightIcon.WidgetTexture.MaterialVSize()
    );

    // -- FIRE MODE ICON -- //
    FMMat = GetFireModeTex();
    SPCT = FireModeSize / FMMat.MaterialUSize();
    SSX = FireModeSize;
    SSY = SPCT * FMMat.MaterialVSize();
    HDX = SX + ((FireModeX - (SSX * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((FireModeY - (SSY * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2TextColor;
    C.DrawTile(
        FMMat,
        SSX * KF2BLBase.TextureScale * SS,
        SSY * KF2BLBase.TextureScale * SS,
        0,
        0,
        FMMat.MaterialUSize(),
        FMMat.MaterialVSize()
    );

    // -- BATTERY BAR -- //
    SPCT = FlashlightDigits.Value / 100.0;
    TotalBarWidth = BatteryHeight * SPCT;
    HDY = SY + ((BatteryBottom - TotalBarWidth) * KF2BLBase.TextureScale * SS);
    C.DrawColor = KF2BatteryIcon.Tints[0];
    C.DrawColor.R = 26;
    C.DrawColor.G = 44;
    C.DrawColor.B = 100;
    // Canvas.DrawColor.A = 128; //128
    C.SetPos(SX, HDY);
    C.DrawTile(
        Texture'KF2BR_batterybar',
        MX,
        TotalBarWidth * KF2BLBase.TextureScale * SS,
        0,
        BatteryBottom - TotalBarWidth,
        KF2BLOverlay.WidgetTexture.MaterialUSize(),
        TotalBarWidth
    );

    SSX = KF2BatteryIcon.WidgetTexture.MaterialUSize() * KF2BatteryIcon.TextureScale;
    SSY = KF2BatteryIcon.WidgetTexture.MaterialVSize() * KF2BatteryIcon.TextureScale;
    HDX = SX + ((BatteryIconX - (SSX * 0.5)) * KF2BLBase.TextureScale * SS);
    HDY = SY + ((BatteryIconY - (SSY * 0.5)) * KF2BLBase.TextureScale * SS);
    C.SetPos(HDX, HDY);
    C.DrawColor = KF2BatteryIcon.Tints[0];
    C.DrawTile(
        KF2BatteryIcon.WidgetTexture,
        SSX * KF2BLBase.TextureScale * SS,
        SSY * KF2BLBase.TextureScale * SS,
        0,
        0,
        KF2BatteryIcon.WidgetTexture.MaterialUSize(),
        KF2BatteryIcon.WidgetTexture.MaterialVSize()
    );

    //------------------------------------------------------------------------------------------
    // WEAPON AMMUNITION
    //------------------------------------------------------------------------------------------
    if (OwnerWeaponClass != none) {
        if (
            !OwnerWeaponClass.default.bMeleeWeapon &&
            OwnerWeaponClass.default.bConsumesPhysicalAmmo
        ) {
           // -- ANGLE BETWEEN AMMO -- //
            C.SetPos(SX, SY);
            C.DrawColor = KF2BRAngle.Tints[0];
            C.DrawTile(
                KF2BRAngle.WidgetTexture,
                MX,
                MY,
                0,
                0,
                KF2BRAngle.WidgetTexture.MaterialUSize(),
                KF2BRAngle.WidgetTexture.MaterialVSize()
            );

            // -- MAGAZINE BULLETS -- //
            C.FontScaleX = MagAmmoScale * SS;
            C.FontScaleY = MagAmmoScale * SS;
            C.Font = KF2Font;
            C.TextSize(MagAmmo, FX, FY);

            HDX = SX + (MagAmmoX * KF2BLBase.TextureScale * SS);
            HDY = SY + (MagAmmoY * KF2BLBase.TextureScale * SS);
            C.SetPos(HDX - FX, HDY - (FY * 0.5));
            C.DrawColor = KF2TextColor;
            C.DrawText(MagAmmo);

            // -- RESERVE AMMO -- //
            if (PawnOwner != none && PawnOwner.Weapon != none) {
                WS = string(int(CurClipsPrimary));
                C.FontScaleX = ReserveScale * SS;
                C.FontScaleY = ReserveScale * SS;
                C.Font = KF2Font;
                C.TextSize(WS, FX, FY);

                HDX = SX + (ReserveX * KF2BLBase.TextureScale * SS);
                HDY = SY + (ReserveY * KF2BLBase.TextureScale * SS);
                C.SetPos(HDX - FX, HDY - (FY * 0.5));
                C.DrawColor = KF2TextColor;
                C.DrawText(WS);
            }
        } else {
            // MELEE WEAPON, DRAW 3 DASHES
            C.SetPos(SX, SY);
            C.DrawColor = KF2BRMelee.Tints[0];
            C.DrawTile(
                KF2BRMelee.WidgetTexture,
                MX,
                MY,
                0,
                0,
                KF2BRMelee.WidgetTexture.MaterialUSize(),
                KF2BRMelee.WidgetTexture.MaterialVSize()
            );
        }

        // SECONDARY AMMO
        if (
            (OwnerWeapon != none && OwnerWeapon.bHasSecondaryAmmo) ||
            (bSpectating && CurClipsSecondary > 0) ||
            KFMedicGun(OwnerWeapon) != none ||
            ShowSecondary(OwnerWeapon)
        ) {
            // SECONDARY BASE
            C.SetPos(SX, SY);
            C.DrawColor = KF2BRBase.Tints[0];
            C.DrawTile(
                KF2AltBase.WidgetTexture,
                MX,
                MY,
                0,
                0,
                KF2AltBase.WidgetTexture.MaterialUSize(),
                KF2AltBase.WidgetTexture.MaterialVSize()
            );

            // SECONDARY SCANLINE
            C.SetPos(SX, SY);
            C.DrawColor = KF2AltScan.Tints[0];
            C.DrawTile(
                KF2AltScan.WidgetTexture,
                MX,
                MY,
                0,
                0,
                KF2AltScan.WidgetTexture.MaterialUSize(),
                KF2AltScan.WidgetTexture.MaterialVSize()
            );

            // -- SECONDARY ICON -- //
            FMMat = GetSecondaryTex();
            HDX = SX + ((AltIconX - (AltIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
            HDY = SY + ((AltIconY - (AltIconSize * 0.5)) * KF2BLBase.TextureScale * SS);
            C.SetPos(HDX, HDY);
            C.DrawColor = KF2TextColor;
            C.DrawTile(
                FMMat,
                AltIconSize * KF2BLBase.TextureScale * SS,
                AltIconSize * KF2BLBase.TextureScale * SS,
                0,
                0,
                FMMat.MaterialUSize(),
                FMMat.MaterialVSize()
            );

            // -- SECONDARY TEXT -- //
            C.FontScaleX = AltAmmoScale * SS;
            C.FontScaleY = AltAmmoScale * SS;
            C.Font = KF2Font;
            C.TextSize(AltAmmoValue, FX, FY);

            HDX = SX + (AltAmmoX * KF2BLBase.TextureScale * SS);
            HDY = SY + (AltAmmoY * KF2BLBase.TextureScale * SS);
            C.SetPos(HDX - FX, HDY - (FY * 0.5));
            C.DrawColor = KF2TextColor;
            C.DrawText(AltAmmoValue);
        }
    }

    // Draw mid-wave message
    if (ShouldDrawFancy() && MidWaveState > 0) {
        DrawFancyBar(C);
    }

    C.FontScaleX = oldScaleX;
    C.FontScaleY = oldScaleY;
    C.Font = CF;
}

simulated function CalculateAmmo() {
    if (!IsKF2HUD()) {
        super.CalculateAmmo();
        return;
    }

    MaxAmmoPrimary = 1;
    CurAmmoPrimary = 1;
    MagAmmo = 0;

    if (PawnOwner == none || PawnOwner.Weapon == none || KFWeapon(PawnOwner.Weapon) == none) {
        return;
    }

    PawnOwner.Weapon.GetAmmoCount(MaxAmmoPrimary,CurAmmoPrimary);

    if (PawnOwner.Weapon.FireModeClass[1].default.AmmoClass != none) {
        CurClipsSecondary = PawnOwner.Weapon.AmmoAmount(1);
    }

    MagAmmo = KFWeapon(PawnOwner.Weapon).MagAmmoRemaining;
    CurClipsPrimary = CurAmmoPrimary - MagAmmo;

    AltAmmoValue = CalculateAltAmmo();
}

simulated function DrawWeaponName(Canvas C) {
    if (!IsKF2HUD()) {
        super.DrawWeaponName(C);
    }
    // KF2 doesn't draw this
}

// Alternate ammo value to show
simulated function int CalculateAltAmmo() {
    if (PawnOwner == none || PawnOwner.Weapon == none || KFWeapon(PawnOwner.Weapon) == none) {
        return 0;
    }

    if (KFMedicGun(OwnerWeapon) != none) {
        return int(KFMedicGun(OwnerWeapon).ChargeBar() * 100.0);
    }

    // Normal secondary ammo
    if (PawnOwner.Weapon != none) {
        return PawnOwner.Weapon.AmmoAmount(1);
    } else {
        return 0;
    }
}

// Firemode texture
simulated function Texture GetFireModeTex() {
    return Texture'kf2fm_auto';
}

// Secondary fire mode
simulated function Texture GetSecondaryTex() {
    return Texture'kf2sa_darts';
}

// Forcefully show secondary
simulated function bool ShowSecondary(Weapon Wep) {
    return false;
}

// DISPLAY CERTAIN MESSAGES
// added support of color messages
function DisplayMessages(Canvas C) {
    local int i, j, XPos, YPos, MessageCount;
    local float XL, YL, XXL, YYL;
    local Color Blk;
    local font CF;
    local float oldScaleX, oldScaleY;

    if (!IsKF2HUD()) {
        super.DisplayMessages(C);
        return;
    }

    Blk.A = 192;

    CF = C.Font;
    oldScaleX = C.FontScaleX;
    oldScaleY = C.FontScaleY;
    C.FontScaleX = 1.0;
    C.FontScaleY = 1.0;

    for (i = 0; i < ConsoleMessageCount; i++) {
        if (TextMessages[i].Text == "") {
            break;
        } else if (TextMessages[i].MessageLife < Level.TimeSeconds) {
            TextMessages[i].Text = "";

            if (i < ConsoleMessageCount - 1) {
                for (j = i; j < ConsoleMessageCount - 1; j++) {
                    TextMessages[j] = TextMessages[j + 1];
                }
            }
            TextMessages[j].Text = "";
            break;
        } else {
            MessageCount++;
        }
    }

    MsgTopY = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);
    if (PlayerOwner == none || PlayerOwner.PlayerReplicationInfo == none || !PlayerOwner.PlayerReplicationInfo.bWaitingPlayer) {
        XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) +
            (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
    } else {
        XPos = (0.005 * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
    }

    C.FontScaleX = (C.ClipY / 1080.0) * ChatFontScale;
    C.FontScaleY = (C.ClipY / 1080.0) * ChatFontScale;

    // if (class'KF2GUILabel'.default.bKorean)
    //     C.Font = class'FHLang_Core'.default.KoreanFont;
    // else
    C.Font = KF2Font;

    C.DrawColor = LevelActionFontColor;
    C.TextSize ("A", XL, YL);

    MsgTopY -= YL * MessageCount + 1; // DP_LowerLeft
    MsgTopY -= YL; // Room for typing prompt

    YPos = MsgTopY;
    for (i = 0; i < MessageCount; i++) {
        if (TextMessages[i].Text == "") {
            break;
        }

        // FIRST PASS - SHADOW
        C.DrawColor = Blk;
        YPos += 1;
        XPos += 1;
        C.SetPos(XPos, YPos);
        YYL = 0;
        XXL = 0;
        if (TextMessages[i].PRI != none) {
            XL = ScrnScoreBoardClass.Static.DrawCountryNameSE(C, TextMessages[i].PRI, XPos, YPos);
            C.SetPos(XPos + XL, YPos);
        }
        if (SmileyMsgs.Length != 0) {
            DrawSmileyText(TextMessages[i].Text, C,, YYL);
        } else {
            C.DrawText(TextMessages[i].Text, false);
        }

        // SECOND PASS
        XPos --;
        YPos --;
        C.SetPos(XPos, YPos);
        C.DrawColor = TextMessages[i].TextColor;
        YYL = 0;
        XXL = 0;
        if (TextMessages[i].PRI != none) {
            XL = ScrnScoreBoardClass.Static.DrawCountryNameSE(C, TextMessages[i].PRI, XPos, YPos);
            C.SetPos(XPos + XL, YPos);
        }
        if (SmileyMsgs.Length != 0) {
            DrawSmileyText(TextMessages[i].Text, C,, YYL);
        } else {
            C.DrawText(TextMessages[i].Text, false);
        }

        YPos += (YL + YYL);
    }

    C.FontScaleX = oldScaleX;
    C.FontScaleY = oldScaleY;
    C.Font = CF;
}

simulated function DrawMessage(
    Canvas C,
    int i,
    float PosX,
    float PosY,
    out float DX,
    out float DY
) {
    local float FadeValue;
    local float ScreenX, ScreenY, FSX, FSY;
    local font F;
    local float oldScaleX, oldScaleY;

    if (bHideWaitMessage && string(LocalMessages[i].Message) ~= WaitingMessageClass) {
        LocalMessages[i].Drawn = true;
        return;
    }

    // Not a pickup message
    if (LocalMessages[i].Message != class'PickupMessagePlus') {
        // Is this marco's kill message? Draw a fancy KF2 message
        if (
            string(LocalMessages[i].Message) ~= "FPPKillMessage.FPPKillMessage" ||
            string(LocalMessages[i].Message) ~= "MutKillMessage.NKillsMessage" ||
            string(LocalMessages[i].Message) ~= "KFMod.KillsMessage" ||
            LocalMessages[i].Message == class'KF2KillMessage'
        ) {
            F = C.Font;
            C.Font = LocalMessages[i].StringFont;
            C.TextSize(LocalMessages[i].StringMessage, FSX, FSY);
            PosX = 1.0 - PosX;
            DrawKillMessage(C, i, PosX, PosY, DX, DY);
            C.Font = F;
            return;
        }

        // Is this a damage message?
        if (LocalMessages[i].Message == class'KF2DamageMessage') {
            DrawDamageMessage(C, i, PosX, PosY, DX, DY);
            return;
        }

        super.DrawMessage(C, i, PosX, PosY, DX, DY);
        return;
    }

    // Let's draw a KF2 styled pickup message
    oldScaleX = C.FontScaleX;
    oldScaleY = C.FontScaleY;
    C.FontScaleX = PickupFontScale * (C.ClipY / 1080.0);
    C.FontScaleY = PickupFontScale * (C.ClipY / 1080.0);
    F = C.Font;
    C.Font = KF2Font;
    C.DrawColor.R = 0;
    C.DrawColor.G = 0;
    C.DrawColor.B = 0;
    C.DrawColor.A = 192;

    if (LocalMessages[i].Message.default.bFadeMessage) {
        C.DrawColor.A = LocalMessages[i].DrawColor.A *
            ((LocalMessages[i].EndOfLife - Level.TimeSeconds) / LocalMessages[i].LifeTime);
    }

    GetScreenCoords(PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C);
    DX = LocalMessages[i].DX / C.ClipX;
    DY = LocalMessages[i].DY / C.ClipY;

    C.SetPos(ScreenX + 1, ScreenY + 1);
    if (LocalMessages[i].Message.default.bComplexString) {
        LocalMessages[i].Message.static.RenderComplexMessage(
            C,
            LocalMessages[i].DX,
            LocalMessages[i].DY,
            LocalMessages[i].StringMessage,
            LocalMessages[i].Switch,
            LocalMessages[i].RelatedPRI,
            LocalMessages[i].RelatedPRI2,
            LocalMessages[i].OptionalObject
        );
    } else {
        C.DrawTextClipped(LocalMessages[i].StringMessage, false);
    }

    // set the color again
    if (!LocalMessages[i].Message.default.bFadeMessage) {
        C.DrawColor = LocalMessages[i].DrawColor;
    } else {
        FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
        C.DrawColor = LocalMessages[i].DrawColor;
        C.DrawColor.A = LocalMessages[i].DrawColor.A * (FadeValue / LocalMessages[i].LifeTime);
    }

    C.SetPos(ScreenX, ScreenY);
    if (LocalMessages[i].Message.default.bComplexString) {
        LocalMessages[i].Message.static.RenderComplexMessage(
            C,
            LocalMessages[i].DX,
            LocalMessages[i].DY,
            LocalMessages[i].StringMessage,
            LocalMessages[i].Switch,
            LocalMessages[i].RelatedPRI,
            LocalMessages[i].RelatedPRI2,
            LocalMessages[i].OptionalObject
        );
    }
    else {
        C.DrawTextClipped(LocalMessages[i].StringMessage, false);
    }

    LocalMessages[i].Drawn = true;

    C.FontScaleX = oldScaleX;
    C.FontScaleY = oldScaleY;
    C.Font = F;
}

// Draw a kill message
simulated function DrawKillMessage(
    Canvas Canvas,
    int i,
    float PosX,
    float PosY,
    out float DX,
    out float DY
) {
    local float SS, TW, TH, FadeValue;
    local String S;
    local float DrawX, DrawY, BoxW, BoxH, ISize, Pad;
    local Font F;
    local float oldScaleX, oldScaleY;

    if (LocalMessages[i].Drawn) {
        return;
    }

    FadeValue = 1.0;

    if (LocalMessages[i].Message.default.bFadeMessage) {
        FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds) / LocalMessages[i].LifeTime;
        if (FadeValue <= 0.02) {
            return;
        }
    }

    SS = Canvas.ClipY / 1080.0;
    S = LocalMessages[i].StringMessage;

    F = Canvas.Font;
    // if (class'KF2GUILabel'.default.bKorean)
    //     Canvas.Font = class'FHLang_Core'.default.KoreanFont;
    // else
    Canvas.Font = KF2Font;

    oldScaleX = Canvas.FontScaleX;
    oldScaleY = Canvas.FontScaleY;
    Canvas.FontScaleX = KillScale * SS * KillDampen;
    Canvas.FontScaleY = KillScale * SS * KillDampen;

    if (class'KF2GUILabel'.default.bKorean) {
        Canvas.FontScaleX *= class'KF2GUILabel'.default.KoreanScale;
        Canvas.FontScaleY *= class'KF2GUILabel'.default.KoreanScale;
    }

    Canvas.TextSize(S, TW, TH);

    // So now, we need to find out our box coordinates
    DrawX = Canvas.ClipX * PosX;
    DrawY = Canvas.ClipY * PosY;

    // Prepare our icon
    ISize = KillSkullSize * SS * KillDampen;
    Pad = KillPadding * SS * KillDampen;

    // How big is our box?
    BoxW = TW + (Pad * 3.0) + ISize;
    BoxH = TH + (Pad * 2.0);

    // Now let's draw our box (Top aligned)
    DrawX -= BoxW;
    Canvas.SetDrawColor(32, 32, 32, 128 * FadeValue);
    Canvas.SetPos(DrawX, DrawY);
    Canvas.DrawTileStretched(KillBG, BoxW, BoxH);

    // Now finally, let's draw our text
    Canvas.SetPos((DrawX + BoxW) - (TW + Pad), (DrawY + (BoxH * 0.5)) - (TH * 0.5));
    // if (bColoredKillMessages)
    // {
    //     Canvas.DrawColor = LocalMessages[i].DrawColor;
    //     Canvas.DrawColor.A  = LocalMessages[i].DrawColor.A * FadeValue;
    // }
    // else
    Canvas.SetDrawColor(255, 255, 255, 255 * FadeValue);

    Canvas.DrawTextClipped(S);

    // So now, let's draw our skull (left aligned)
    Canvas.SetPos(DrawX + Pad, (DrawY + (BoxH * 0.5)) - (ISize * 0.5));
    Canvas.SetDrawColor(255, 255, 255, 255 * FadeValue);
    Canvas.DrawTile(
        SkullIcon,
        ISize,
        ISize,
        0,
        0,
        SkullIcon.MaterialUSize(),
        SkullIcon.MaterialVSize()
    );

    Canvas.FontScaleX = oldScaleX;
    Canvas.FontScaleY = oldScaleY;

    LocalMessages[i].Drawn = true;

    DY = (BoxH + Pad) / Canvas.ClipY;
    Canvas.Font = F;
}

// Draw a damage message
simulated function DrawDamageMessage(
    Canvas Canvas,
    int i,
    float PosX,
    float PosY,
    out float DX,
    out float DY
) {
    local float SS, TW, TH, FadeValue;
    local String S;
    local float DrawX, DrawY;
    local Font F;
    local float oldScaleX, oldScaleY;

    if (LocalMessages[i].Drawn) {
        return;
    }

    FadeValue = 1.0;

    if (LocalMessages[i].Message.default.bFadeMessage) {
        FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds) / LocalMessages[i].LifeTime;
        if (FadeValue <= 0.02) {
            return;
        }
    }

    SS = Canvas.ClipY / 1080.0;
    S = LocalMessages[i].StringMessage;

    F = Canvas.Font;
    Canvas.Font = KF2Font;
    oldScaleX = Canvas.FontScaleX;
    oldScaleY = Canvas.FontScaleY;
    Canvas.FontScaleX = DamageScale * SS;
    Canvas.FontScaleY = DamageScale * SS;
    Canvas.TextSize(S, TW, TH);

    // So now, we need to find out our box coordinates
    DrawX = Canvas.ClipX * PosX;
    DrawY = Canvas.ClipY * PosY;

    // Now finally, let's draw our text
    Canvas.SetPos(Canvas.ClipX * PosX, Canvas.ClipY * PosY);
    Canvas.DrawColor = LocalMessages[i].DrawColor;
    Canvas.DrawColor.A  = LocalMessages[i].DrawColor.A * FadeValue;
    Canvas.DrawText(S);

    LocalMessages[i].Drawn = true;

    DY = (TH + (4.0 * SS)) / Canvas.ClipY;
    Canvas.FontScaleX = oldScaleX;
    Canvas.FontScaleY = oldScaleY;
    Canvas.Font = F;
}

// NEW AND UPDATED SUPPORT FOR DAMAGE MESSAGES
function  bool UpdateDamageMessage(
    Object OptionalObject,
    PlayerReplicationInfo RelatedPRI_1,
    int Switch
) {
    local int i;

    for (i = 0; i < ArrayCount(LocalMessages); ++i) {
        if (
            LocalMessages[i].Message == class 'KF2DamageMessage' &&
            LocalMessages[i].OptionalObject == OptionalObject &&
            LocalMessages[i].RelatedPRI==RelatedPRI_1
        ) {
            PlayerController(PawnOwner.Controller).ClientMessage("UDM SWITCH:" @ string(Switch));
            LocalMessages[i].Switch += Switch;
            LocalMessages[i].DrawColor = class'KF2DamageMessage'.static.GetColor(LocalMessages[i].Switch);
            LocalMessages[i].LifeTime = class 'KF2DamageMessage'.default.MessageShowTime;
            LocalMessages[i].EndOfLife = class 'KF2DamageMessage'.default.MessageShowTime + Level.TimeSeconds;
            LocalMessages[i].StringMessage = class 'KF2DamageMessage'.static.GetString(LocalMessages[i].Switch,RelatedPRI_1,,OptionalObject);
            return true;
        }
    }

    return false;
}

// Update CUSTOM kill message
function UpdateKillMessage(Object OptionalObject,PlayerReplicationInfo RelatedPRI_1);

function bool UpdateCustomKillMessage(Object OptionalObject,PlayerReplicationInfo RelatedPRI_1) {
    local int i;

    for (i = 0; i < ArrayCount(LocalMessages); ++i) {
        if (
            (LocalMessages[i].Message == class'KF2KillMessage' || LocalMessages[i].Message == class'KF2KillMessageClassic') &&
            LocalMessages[i].OptionalObject == OptionalObject &&
            LocalMessages[i].RelatedPRI == RelatedPRI_1
        ) {
            ++LocalMessages[i].Switch;
            LocalMessages[i].DrawColor = class'KF2KillMessage'.static.GetColor(LocalMessages[i].Switch);
            LocalMessages[i].LifeTime = class 'KF2KillMessage'.default.MessageShowTime;
            LocalMessages[i].EndOfLife = class 'KF2KillMessage'.default.MessageShowTime + Level.TimeSeconds;
            LocalMessages[i].StringMessage = class 'KF2KillMessage'.static.GetString(LocalMessages[i].Switch,RelatedPRI_1,,OptionalObject);
            return true;
        }
    }

    return false;
}

//-----------------------------------------------------------------------------------------------------------------------
// K I L L I N G   F L O O R   2   -   M I D   W A V E   J U N K
//-----------------------------------------------------------------------------------------------------------------------
function TriggerBar(string TopText, optional string BottomText, optional Sound TriggerSound) {
    MidHeader = TopText;
    MidSub = BottomText;
    WarnPulseCurrent = 0;
    MidWaveState = 1;
    TimeCheckLast = Level.TimeSeconds;
    bPulseIn = true;

    if (BottomText ~= "") {
        WarnStayTime = default.WarnStayTime;
    } else {
        WarnStayTime = default.WarnStayTime + WarnSubTime;
    }

    if (TriggerSound != none && PawnOwner.Controller != none) {
        PlayerController(PawnOwner.Controller).PlaySound(TriggerSound, SLOT_None, 1.0, true, 500000.0, 1.0, false);
    }
}

// Draw the bar
function DrawFancyBar(Canvas Canvas) {
    local float SS, CenX, CenY, ISize, IClip, Pct;
    local float BarWidth, locBarHeight, DrawX, DrawY, WBW, LT;
    local byte WarnAlpha, BarAlpha, TextAlpha;
    local float TW, TH;
    local Font F;
    local float oldScaleX, oldScaleY;

    SS = Canvas.ClipY / 1080.0;

    CenX = Canvas.ClipX * 0.5;
    CenY = Canvas.ClipY * 0.5;

    BarAlpha = 255;

    if (MidWaveState == 5 && ((Level.TimeSeconds - TimeCheckLast) / WarnFadeTime) >= 0.95) {
        MidWaveState = 0.0;
        return;
    }

    // Get our icon size and set our state
    switch (MidWaveState) {
        case 1:
            ISize = WarnIconSize * WarnScaleMax;
            // Time check has exceeded pulse time
            if (Level.TimeSeconds >= TimeCheckLast + WarnPulseTime) {
                // Pulsing in?
                if (bPulseIn) {
                    bPulseIn = false;
                    if (WarnPulseCurrent == WarnPulseLimit - 1) {
                        MidWaveState ++;
                    }
                } else {
                    // Pulsing out
                    bPulseIn = true;
                    WarnPulseCurrent++;
                }

                TimeCheckLast = Level.TimeSeconds;
            }

            Pct = (Level.TimeSeconds - TimeCheckLast) / WarnPulseTime;
            if (bPulseIn) {
                Pct = 1.0 - Pct;
            }

            WarnAlpha = 255 - byte((WarnFadeAlpha * Pct) * 255);
            break;

        case 2:
            Pct = (Level.TimeSeconds - TimeCheckLast) / WarnShrinkTime;
            ISize = WarnIconSize * (WarnScaleMax - (Pct * (WarnScaleMax - WarnScaleMin)));
            WarnAlpha = 255;

            if (Level.TimeSeconds >= TimeCheckLast + WarnShrinkTime) {
                TimeCheckLast = Level.TimeSeconds;
                MidWaveState++;
            }
            break;

        case 3:
            ISize = WarnIconSize * WarnScaleMin;
            if (Level.TimeSeconds >= TimeCheckLast + WarnGrowTime) {
                TimeCheckLast = Level.TimeSeconds;
                MidWaveState++;
            }
            break;

        case 4:
            ISize = WarnIconSize * WarnScaleMin;
            if (Level.TimeSeconds >= TimeCheckLast + WarnStayTime) {
                TimeCheckLast = Level.TimeSeconds;
                MidWaveState++;
            }
            break;

        case 5:
            ISize = WarnIconSize * WarnScaleMin;
            WarnAlpha = 255 * (1.0 - (Level.TimeSeconds - TimeCheckLast) / WarnFadeTime);
            BarAlpha = WarnAlpha;
            if (Level.TimeSeconds >= TimeCheckLast + WarnFadeTime) {
                MidWaveState = 0;
            }
            break;
    }

    ISize *= SS;

    // Next, set our solid bar size
    if (MidWaveState == 3) {
        Pct = FClamp((Level.TimeSeconds - timeCheckLast) / WarnGrowTime, 0.0, 1.0);
        BarWidth = Pct * WarnBarWidth * SS;
    } else {
        BarWidth = WarnBarWidth * SS;
    }

    locBarHeight = ISize;

    // Draw our bar behind all the stuff first
    if (MidWaveState > 2) {
        IClip = (WarnClip / 256.0) * ISize;

        WBW = BarWidth - (IClip * 2.0);

        if (WBW > 0.0) {
            DrawX = CenX - (WBW * 0.5);
            DrawY = CenY - (locBarHeight * 0.5);
            Canvas.SetDrawColor(255, 255, 255, WarnAlpha);
            Canvas.SetPos(DrawX, DrawY);
            Canvas.DrawColor.R = 0;
            Canvas.DrawColor.G = 6;
            Canvas.DrawColor.B = 25;
            Canvas.DrawTile(
                MidSolidTex,
                WBW,
                locBarHeight,
                0,
                0,
                MidSolidTex.MaterialUSize(),
                MidSolidTex.MaterialVSize()
            );
        }
    }

    // So let's draw our warning symbols
    // 1 : Pulsing, single in the center
    // 2 : Shrinking, single in the center
    if (MidWaveState == 1 || MidWaveState == 2) {
        DrawX = CenX - (ISize * 0.5);
        DrawY = CenY - (ISize * 0.5);
        Canvas.SetDrawColor(255, 255, 255, WarnAlpha);
        Canvas.SetPos(DrawX, DrawY);
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        Canvas.DrawTile(
            MidWarnTex,
            ISize,
            ISize,
            0,
            0,
            MidWarnTex.MaterialUSize(),
            MidWarnTex.MaterialVSize()
        );
    } else {
        // Anything else: Draw TWO warning symbols
        DrawX = CenX - (BarWidth * 0.5);
        DrawY = CenY - (ISize * 0.5);
        Canvas.SetDrawColor(255, 255, 255, WarnAlpha);
        Canvas.SetPos(DrawX, DrawY);
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        Canvas.DrawTile(
            MidWarnTex,
            ISize,
            ISize,
            0,
            0,
            MidWarnTex.MaterialUSize(),
            MidWarnTex.MaterialVSize()
        );

        DrawX = (CenX + (BarWidth * 0.5)) - ISize;
        Canvas.SetPos(DrawX, DrawY);
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        Canvas.DrawTile(
            MidWarnTex,
            ISize,
            ISize,
            0,
            0,
            MidWarnTex.MaterialUSize(),
            MidWarnTex.MaterialVSize()
        );
    }

    // DRAW THE TEXT!
    if (MidWaveState == 4) {
        BarAlpha = 255 * Clamp((Level.TimeSeconds - timeCheckLast) / (WarnStayTime) * 0.2, 0.0, 1.0);
    }

    if (MidWaveState >= 4) {
        F = Canvas.Font;
        oldScaleX = Canvas.FontScaleX;
        oldScaleY = Canvas.FontScaleY;
        Canvas.SetDrawColor(MidTextColor.R, MidTextColor.G, MidTextColor.B, BarAlpha);
        Canvas.FontScaleX = WarnTextScale * SS;
        Canvas.FontScaleY = WarnTextScale * SS;
        Canvas.Font = KF2Font;
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        Canvas.TextSize(MidHeader, TW, TH);
        Canvas.SetPos(CenX - (TW * 0.5), CenY - (TH * 0.5));
        Canvas.DrawText(MidHeader);
        Canvas.Font = F;
        Canvas.FontScaleX = oldScaleX;
        Canvas.FontScaleY = oldScaleY;
    }

    //-----------------------------------------------------//
    // B O T T O M   B A R
    //-----------------------------------------------------//
    if (MidSub ~= "") {
        return;
    }

    if (MidWaveState == 4) {
        // Past the time to show our sub text
        if ((Level.TimeSeconds - timeCheckLast) >= WarnSubStart) {
            if (WarnSubLast <= 0.0) {
                WarnSubLast = Level.TimeSeconds;
            }

            // Set the bar width
            Pct = FClamp((Level.TimeSeconds - WarnSubLast) / WarnSubGrowTime, 0.0, 1.0);
            BarWidth = WarnSubWidth * SS * Pct;
            BarAlpha = 255;

            LT = (Level.TimeSeconds - WarnSubLast) + WarnSubGrowTime;
            if (LT > Level.TimeSeconds) {
                Pct = 0.0;
            } else {
                Pct = Clamp(LT / WarnSubFadeTime, 0.0, 1.0);
            }

            TextAlpha = 255 * Pct;
        }
    } else {
        BarWidth = WarnSubWidth * SS;
        TextAlpha = BarAlpha;
    }

    if (MidWaveState >= 4 && BarAlpha > 0) {
        DrawY = CenY + (locBarHeight * 0.5) + (16.0 * SS);
        locBarHeight = WarnSubHeight * SS;

        CenX = (Canvas.ClipX * 0.5);
        CenY = DrawY+(locBarHeight * 0.5);

        // DRAW THE BAR FIRST
        Canvas.SetPos(CenX - (BarWidth * 0.5), DrawY);
        Canvas.SetDrawColor(255, 255, 255, BarAlpha);
        Canvas.DrawColor.R = 0;
        Canvas.DrawColor.G = 6;
        Canvas.DrawColor.B = 25;
        Canvas.DrawTile(
            MidSolidTex,
            BarWidth,
            locBarHeight,
            0,
            0,
            MidSolidTex.MaterialUSize(),
            MidSolidTex.MaterialVSize()
        );

        WBW = (WarnSubHeight / MidLeftTex.MaterialVSize()) * MidLeftTex.MaterialUSize() * SS;

        // LEFT SIDE
        Canvas.SetPos((CenX - (BarWidth * 0.5)) - WBW, DrawY);
        Canvas.SetDrawColor(255, 255, 255, BarAlpha);
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        Canvas.DrawTile(
            MidLeftTex,
            WBW,
            locBarHeight,
            0,
            0,
            MidLeftTex.MaterialUSize(),
            MidLeftTex.MaterialVSize()
        );

        // RIGHT SIDE
        Canvas.SetPos(CenX + (BarWidth * 0.5), DrawY);
        Canvas.SetDrawColor(255, 255, 255, BarAlpha);
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        Canvas.DrawTile(
            MidRightTex,
            WBW,
            locBarHeight,
            0,
            0,
            MidRightTex.MaterialUSize(),
            MidRightTex.MaterialVSize()
        );

        // DRAW THE TEXT YO
        Canvas.SetDrawColor(MidTextColor.R, MidTextColor.G, MidTextColor.B, TextAlpha);
        Canvas.DrawColor.R = 26;
        Canvas.DrawColor.G = 44;
        Canvas.DrawColor.B = 100;
        F = Canvas.Font;
        oldScaleX = Canvas.FontScaleX;
        oldScaleY = Canvas.FontScaleY;
        Canvas.FontScaleX = SubTextScale * SS;
        Canvas.FontScaleY = SubTextScale * SS;
        Canvas.Font = KF2Font;
        Canvas.TextSize(MidSub, TW, TH);
        Canvas.SetPos(CenX - (TW * 0.5), CenY - (TH * 0.5));
        Canvas.DrawText(MidSub);
        Canvas.Font = F;
        Canvas.FontScaleX = oldScaleX;
        Canvas.FontScaleY = oldScaleY;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------
//
//   B O S S   B A R   L I K E   K I L L I N G   F L O O R   2
//
//----------------------------------------------------------------------------------------------------------------------------------------------------------

// function DrawBossBar(Canvas Canvas)
// {
//     local int l;
//     local float Y, H;
//     local FunhouseGameReplicationInfo FGRI;

//     FGRI = FunhouseGameReplicationInfo(Level.GRI);
//     if (FGRI == none)
//         return;

//     Y = 24.0 * (Canvas.ClipY / 1080.0);

//     for (l=0; l<FGRI.ClientBosses.Length; l++)
//     {
//         H = DrawSingleBoss(FGRI.ClientBosses[l].MenuName, FGRI.ClientBosses[l].Pct, Canvas, Y);
//         Y += H;
//     }
// }

function float DrawSingleBoss(string MonName, float Pct, Canvas Canvas, float YStart) {
    local float SS, BW, CW, CenX, CenY, BL, BH;
    local float NewWidth, Overlap, BSize;
    local color FinCol;
    local Font F;
    local float oldScaleX, oldScaleY;

    F = Canvas.Font;

    FinCol.R = byte(Lerp(BossBarGreen.R, BossBarRed.R, Pct));
    FinCol.G = byte(Lerp(BossBarGreen.G, BossBarRed.G, Pct));
    FinCol.B = byte(Lerp(BossBarGreen.B, BossBarRed.B, Pct));
    FinCol.A = 255;

    //-----------------------------------------------------

    SS = Canvas.ClipY / 1080.0;

    // Find our bar width
    CW = SS * KF2TLBase.WidgetTexture.MaterialUSize() * KF2TLBase.TextureScale;

    BW = Canvas.ClipX - (CW * 2.0);
    BH = BBMid.MaterialVSize() * SS * 0.5;

    // Right bar width
    NewWidth = BBRight.MaterialUSize() * SS * 0.5;

    // Center position
    CenX = Canvas.ClipX * 0.5;
    CenY = YStart;

    // Left box is 96 px
    Overlap = 96.0 * SS * 0.5;
    BSize = BBLeft.MaterialUSize() * SS * 0.5;

    // Left part of the bar
    BL = CenX - (BW * 0.5);

    //---------------------------------------------

    // Draw the main bar
    Canvas.SetPos(BL + Overlap, CenY);
    Canvas.SetDrawColor(32, 32, 32, 190);
    Canvas.DrawTile(
        BBMid,
        BW - NewWidth - Overlap,
        BH,
        0,
        0,
        BBMid.MaterialUSize(),
        BBMid.MaterialVSize()
    );

    // Far right part
    Canvas.DrawTile(BBRight, NewWidth, BH, 0, 0, BBRight.MaterialUSize(), BBRight.MaterialVSize());

    //---------------------------------------------

    // Draw the main bar
    Canvas.SetPos(BL + Overlap, CenY);
    Canvas.SetDrawColor(FinCol.R, FinCol.G, FinCol.B, FinCol.A);
    Canvas.DrawTile(
        BBMid,
        (BW - NewWidth - Overlap) * Pct,
        BH,
        0,
        0,
        BBMid.MaterialUSize(),
        BBMid.MaterialVSize()
    );

    // Far right part
    Canvas.DrawTile(BBRight, NewWidth, BH, 0, 0, BBRight.MaterialUSize(), BBRight.MaterialVSize());

    //---------------------------------------------

    // Far left bit
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.SetPos(BL, CenY);
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.DrawTile(BBLeft, BSize, BSize, 0, 0, BBLeft.MaterialUSize(), BBLeft.MaterialVSize());

    // Draw the skull
    BSize = BBSkullSize * SS;

    CenX = BL + (BBSkullX * 0.5 * SS);
    CenY += (BBSkullY * 0.5 * SS);
    CenX -= (BSize * 0.5);
    CenY -= (BSize * 0.5);

    Canvas.SetPos(CenX, CenY);

    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.DrawTile(BBSkull, BSize, BSize, 0, 0, BBSkull.MaterialUSize(), BBSkull.MaterialVSize());

    // Draw the Text
    F = Canvas.Font;
    Canvas.Font = KF2Font;
    oldScaleX = Canvas.FontScaleX;
    oldScaleY = Canvas.FontScaleY;
    Canvas.FontScaleX = BossTextScale * SS;
    Canvas.FontScaleY = BossTextScale * SS;
    Canvas.SetPos(BL + (BossTextX * 0.5 * SS) + (2 * SS), YStart + (BossTextY * 0.5 * SS) + (2 * SS));
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.DrawText(MonName);

    Canvas.SetPos(BL + (BossTextX * 0.5 * SS), YStart + (BossTextY * 0.5 * SS));
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.DrawText(MonName);

    Canvas.Font = F;
    Canvas.FontScaleX = oldScaleX;
    Canvas.FontScaleY = oldScaleY;

    return BH + (4.0 * SS);
}

//--------------------------------------------------------------------------------------------------------
// O V E R H E A D   B A R S   F O R   P L A Y E R S
//--------------------------------------------------------------------------------------------------------
exec function SetBarStyle(byte value) {
    if (value >= BarStyles.length) {
        return;
    }

    BarStyle = value;
    if (BarStyle == BARSTL_KF2) {
        ScrnDrawPlayerInfoBase = DrawPlayerInfoBaseKF2;
    } else {
        super.SetBarStyle(value);
    }
}

simulated function DrawPlayerInfoBaseKF2(
    Canvas C,
    Pawn P,
    float ScreenLocX,
    float ScreenLocY,
    float fZoom,
    KFPlayerReplicationInfo EnemyPRI,
    bool bSameTeam
) {
    DrawOverheadBar(C, P, ScreenLocX, ScreenLocY, fZoom, EnemyPRI);
}

// Draw the actual bar
simulated function DrawOverheadBar(
    Canvas C,
    Pawn P,
    float ScreenLocX,
    float ScreenLocY,
    float fZoom,
    KFPlayerReplicationInfo EnemyPRI,
    optional string ForcedName,
    optional float ForcedHealth,
    optional float ForcedShield,
    optional class<SRVeterancyTypes> ForcedPerk,
    optional int ForcedLevel
) {
    local float XL, YL, TempX, TempY, TempSize, LeftX, MidY;
    local String S;
    local byte BeaconAlpha;
    local Material TempMaterial, TempStarMaterial;
    local byte TempLevel;
    local KFHumanPawn EnemyScrnPawn;
    local float SS, PValue;
    local font CF;
    local float Dist;
    local class<SRVeterancyTypes> ThePerk;
    local int TheLevel;
    local float oldScaleX, oldScaleY;

    Dist = vsize(P.Location - PlayerOwner.CalcViewLocation);
    if (Dist <= BarDistMin) {
        fZoom = 1.0;
    } else {
        fZoom = 1.0 - ((Dist - BarDistMin) / (BarDistMax - BarDistMin));
        fZoom = 1.0 - (Dist - HealthBarFullVisDist) / (HealthBarCutoffDist - HealthBarFullVisDist);
        if (fZoom < 0.01) {
            return;
        }

        fZoom = BarScaleMin + (fZoom * (BarScaleMax - BarScaleMin));
    }

    SS = (0.5 + ((C.ClipY / 1080.0) * 0.5)) * fZoom;

    CF = C.Font;
    oldScaleX = C.FontScaleX;
    oldScaleY = C.FontScaleY;
    C.FontScaleX = PlayerTextScale * SS;
    C.FontScaleY = PlayerTextScale * SS;
    C.Font = KF2Font;

    TempY = ScreenLocY;
    PlayerBarHeight = default.PlayerBarHeight * SS;
    PlayerBarWidth = default.PlayerBarWidth * SS;
    LeftX = ScreenLocX - (PlayerBarWidth * 0.5);
    BeaconAlpha = 255 * fZoom;

    //--------------------------------
    // LEVEL
    //--------------------------------
    if (ForcedLevel == -1) {
        TheLevel = 0;
    } else {
        TheLevel = EnemyPRI.ClientVeteranSkillLevel;
    }

    if (ForcedPerk != none) {
        ThePerk = ForcedPerk;
    } else {
        ThePerk = class<SRVeterancyTypes>(EnemyPRI.ClientVeteranSkill);
    }

    if (ClassIsChildOf(ThePerk,class'SRVeterancyTypes')) {
        S = string(TheLevel) @ ThePerk.default.VeterancyName;
        C.TextSize(S, XL, YL);
        TempY -= YL;
        C.SetDrawColor(255, 255, 255, BeaconAlpha);
        C.SetPos(LeftX, TempY);
        C.DrawText(S);
    }

    //--------------------------------
    // HEALTH BAR
    //--------------------------------
    if (P.Health > 0) {
        TempY -= (2.0 * SS) + PlayerBarHeight;

        if (ForcedHealth > 0.0) {
            PValue = ForcedHealth;
        } else {
            PValue = FClamp(P.Health / P.HealthMax, 0, 1);
        }

        // BG
        C.SetDrawColor(0, 0, 0, BeaconAlpha);
        C.SetPos(LeftX, TempY);
        C.DrawTileStretched(WhiteMaterial, PlayerBarWidth, PlayerBarHeight);

        // Overlay
        C.SetDrawColor(92, 172, 198, BeaconAlpha);
        C.SetPos(LeftX, TempY);
        C.DrawTileStretched(WhiteMaterial, PlayerBarWidth * PValue, PlayerBarHeight);
    }

    MidY = TempY - (1.0 * SS);

    //--------------------------------
    // ARMOR BAR
    //--------------------------------

    TempY -= (2.0 * SS) + PlayerBarHeight;

    // BG
    C.SetDrawColor(0, 0, 0, BeaconAlpha);
    C.SetPos(LeftX, TempY);
    C.DrawTileStretched(WhiteMaterial, PlayerBarWidth, PlayerBarHeight);

    if (P.ShieldStrength > 0 || ForcedShield > 0.0) {
        if (ForcedShield > 0.0) {
            PValue = ForcedShield;
        } else {
            PValue = FClamp(P.ShieldStrength / 100.f, 0, 3);
        }

        // Overlay
        C.SetDrawColor(3, 9, 182, BeaconAlpha);
        C.SetPos(LeftX, TempY);
        C.DrawTileStretched(WhiteMaterial, PlayerBarWidth * PValue, PlayerBarHeight);
    }

    //--------------------------------
    // PLAYER NAME
    //--------------------------------
    TempY -= (8.0 * SS) + YL;

    if (Len(ForcedName) <= 0) {
        S = class'ScrnBalance'.default.Mut.ColoredPlayerName(EnemyPRI);
    } else {
        S = ForcedName;
    }

    C.SetDrawColor(255, 255, 255, BeaconAlpha);
    C.SetPos(LeftX, TempY);
    C.DrawText(S);

    EnemyScrnPawn = KFHumanPawn(P);

    //--------------------------------
    // PERK
    //--------------------------------
    if (ThePerk != none) {
        TempSize = PlayerPerkSize * SS;
        TempX = LeftX - (4.0 * SS) - TempSize;
        TempY = MidY - (TempSize * 0.5);
        C.DrawColor.A = BeaconAlpha;

        TempLevel = ThePerk.Static.PreDrawPerk(C, TheLevel, TempMaterial,TempStarMaterial);

        C.SetPos(TempX, TempY);
        C.DrawTile(
            TempMaterial,
            TempSize,
            TempSize,
            0,
            0,
            TempMaterial.MaterialUSize(),
            TempMaterial.MaterialVSize()
        );
    }

    TempSize = PlayerPerkSize * SS;

    //--------------------------------
    // CHAT ICON
    //--------------------------------
    if (P.bIsTyping) {
        C.SetPos(LeftX + PlayerBarWidth + (4.0 * SS), MidY - (TempSize * 0.5));
        C.DrawTile(
            ChatIcon,
            TempSize,
            TempSize,
            0,
            0,
            ChatIcon.MaterialUSize(),
            ChatIcon.MaterialVSize()
        );
    }

    C.FontScaleX = oldScaleX;
    C.FontScaleY = oldScaleY;
    C.Font = CF;
}

// Draw a fancy bar?
simulated function bool ShouldDrawFancy() {
    return true;
}

//-----------------------------------------------------------------------------------------
//
// P L A Y E R   P O R T R A I T
//
//-----------------------------------------------------------------------------------------

// Border texture, drawn around portraits
simulated function Material GetBorderTexture(PlayerReplicationInfo PRI) {
    return none;
}

simulated function DrawPortraitSE(Canvas Canvas) {
    local float TempY, PortW, PortH, SS, TempW, TempH, BTW, BTH; // TempX
    local float StartX, StartY;
    local float SlidePct, Abbrev;
    local string PortraitString, ShadowString;
    local font F;
    local Material BorderTex;
    local float oldScaleX, oldScaleY;

    if (!IsKF2HUD()) {
        super.DrawPortraitSE(Canvas);
        return;
    }

    F = Canvas.Font;

    // SlidePct = Square(PortraitX);
    SlidePct = PortraitX * PortraitX * PortraitX;

    SS = Canvas.ClipY / 1080.0;

    // Size of the portrait
    PortW = 256.0 * SS * PortraitScale;
    if (bSpecialPortrait && Portrait != TraderPortrait) {
        PortH = PortW * Portrait.MaterialVSize() / Portrait.MaterialUSize();
    } else {
        PortH = 512.0 * SS * PortraitScale;
    }

    // Position
    StartX = 0.0 - (SlidePct * PortW);
    StartY = (Canvas.ClipY - (PortraitY * SS)) - PortH;

    BorderTex = GetBorderTexture(PortraitPRI);

    // Draw the border behind the portrait
    if (BorderTex == none) {
        Canvas.SetPos(StartX - PortraitBorderSize, StartY - PortraitBorderSize);
        Canvas.DrawColor = WhiteColor;
        Canvas.DrawTileStretched(
            Texture'InterfaceContent.BorderBoxA1',
            PortW + (PortraitBorderSize * 2.0),
            PortH + (PortraitBorderSize * 2.0)
        );
    }

    // Some portraits have shitty alpha, draw black behind it to fix this
    Canvas.SetPos(StartX, StartY);
    Canvas.Drawcolor = BlackColor;
    Canvas.DrawTileStretched(WhiteMaterial, PortW, PortH);

    // Draw the portrait, nothing major
    Canvas.SetPos(StartX, StartY);
    Canvas.DrawColor = WhiteColor;
    Canvas.DrawTile(Portrait, PortW, PortH, 0, 0, Portrait.MaterialUSize(), Portrait.MaterialVSize());

    // Border! Fancy
    if (BorderTex != none) {
        BTW = BorderTex.MaterialUSize() * SS * PortraitScale;
        BTH = BorderTex.MaterialVSize() * SS * PortraitScale;

        // Vertically, it's centered at the center of the portrait
        TempY = StartY + (PortH * 0.5);
        TempY -= (BTH * 0.5);

        Canvas.SetPos(StartX, TempY);
        Canvas.DrawColor = WhiteColor;
        Canvas.DrawTile(
            BorderTex,
            BTW,
            BTH,
            0,
            0,
            BorderTex.MaterialUSize(),
            BorderTex.MaterialVSize()
        );
    }

    // Now we can draw the player's name
    StartY += PortH + (PortraitTextPad * SS);
    StartX += (PortW * 0.5);

    oldScaleX = Canvas.FontScaleX;
    oldScaleY = Canvas.FontScaleY;
    Canvas.FontScaleX = (Canvas.ClipY / 1080.0) * PortraitTextScale;
    Canvas.FontScaleY = (Canvas.ClipY / 1080.0) * PortraitTextScale;

    //Canvas.Font = Font'Engine.DefaultFont';
    Canvas.Font = KF2Font;

    if (Portrait == TraderPortrait) {
        PortraitString = TraderString;
    } else {
        PortraitString = PortraitPRI.PlayerName;
    }

    PortraitString = class'ScrnFunctions'.static.ParseColorTags(PortraitString);

    Canvas.TextSize(PortraitString, TempW, TempH);

    if (TempW > PortW) {
        Abbrev = float(len(PortraitString)) * PortW / TempW;
        PortraitString = left(PortraitString, Abbrev);
        Canvas.TextSize(PortraitString, TempW, TempH);
    }

    StartX -= (TempW * 0.5);

    // Text for the shadow
    ShadowString = class'ScrnFunctions'.static.StripColorTags(PortraitString);

    Canvas.SetPos(StartX + 1.0, StartY + 1.0);
    Canvas.DrawColor = BlackColor;
    Canvas.DrawTextClipped(ShadowString);

    Canvas.SetPos(StartX, StartY);
    Canvas.DrawColor = WhiteColor;
    Canvas.DrawTextClipped(PortraitString);

    // Reset
    Canvas.Font = F;
    Canvas.FontScaleX = oldScaleX;
    Canvas.FontScaleY = oldScaleY;
}

defaultproperties {
    TinR=64
    TinG=180
    TinB=255
    KF2Font=Font'KF2HUD.KF2Font'
    KF2Digits=(DigitTexture=Texture'KF2HUD.KF2DigitTex',TextureCoords[0]=(X1=15,Y1=8,X2=68,Y2=82),TextureCoords[1]=(X1=89,Y1=8,X2=115,Y2=82),TextureCoords[2]=(X1=137,Y1=8,X2=192,Y2=82),TextureCoords[3]=(X1=210,Y1=8,X2=260,Y2=82),TextureCoords[4]=(X1=279,Y1=8,X2=331,Y2=82),TextureCoords[5]=(X1=353,Y1=8,X2=399,Y2=82),TextureCoords[6]=(X1=424,Y1=8,X2=470,Y2=82),TextureCoords[7]=(X1=494,Y1=8,X2=540,Y2=82),TextureCoords[8]=(X1=561,Y1=8,X2=610,Y2=82),TextureCoords[9]=(X1=631,Y1=8,X2=680,Y2=82),TextureCoords[10]=(X1=686,Y1=8,X2=726,Y2=82))
    KF2BLBase=(WidgetTexture=Texture'KF2HUD.KF2BL_base',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2BLScan=(WidgetTexture=Texture'KF2HUD.KF2BL_scanline',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2BLOverlay=(WidgetTexture=Texture'KF2HUD.KF2BL_xpover',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=160),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2HealthIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_cross',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2ArmorIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_shield',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2SyringeIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_syringe',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.150000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2NadeIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_nade',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2BRBase=(WidgetTexture=Texture'KF2HUD.KF2BR_base',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2BRScan=(WidgetTexture=Texture'KF2HUD.KF2BR_scanline',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2BROverlay=(WidgetTexture=Texture'KF2HUD.KF2BR_overlay',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2BRAngle=(WidgetTexture=Texture'KF2HUD.KF2BR_angle',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2BRMelee=(WidgetTexture=Texture'KF2HUD.KF2BR_melee',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2DoshIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_dosh',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2WeightIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_weight',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2BatteryIcon=(WidgetTexture=Texture'KF2HUD.kf2ui_battery',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.150000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2AltBase=(WidgetTexture=Texture'KF2HUD.KF2BR_basealt',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2AltScan=(WidgetTexture=Texture'KF2HUD.KF2BR_scanlinealt',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    KF2HealthDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,DrawPivot=DP_MiddleLeft,PosX=0.042500,PosY=0.950000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    HUDNumScale=1.200000
    XPStartX=30.000000
    XPWidth=437.000000
    PerkStartX=106.000000
    PerkStartY=145.000000
    PerkIconSize=75.000000
    PerkTextScale=0.600000
    PerkTextY=201.000000
    SyringeYBottom=231.000000
    SyringeYTop=88.000000
    SyringeHeight=143.000000
    BatteryBottom=489.000000
    BatteryTop=342.000000
    BatteryHeight=147.000000
    HealthIconX=300.000000
    HealthIconY=193.000000
    ArmorIconX=300.000000
    ArmorIconY=128.000000
    SyringeIconX=226.000000
    SyringeIconY=166.000000
    SmallIconSize=50.000000
    DoshX=459.000000
    DoshY=212.000000
    WeightX=459.000000
    WeightY=296.000000
    HUDDoshScale=1.000000
    HUDWeightScale=0.700000
    DoshIconX=260.000000
    DoshIconY=216.000000
    DoshIconSize=42.000000
    WeightIconX=266.000000
    WeightIconY=296.000000
    NadeX=265.000000
    NadeY=446.000000
    HUDNadeScale=1.300000
    NadeIconX=344.000000
    NadeIconY=447.000000
    NadeIconSize=74.000000
    FireModeX=312.000000
    FireModeY=375.000000
    FireModeSize=80.000000
    MagAmmoX=195.000000
    MagAmmoY=388.000000
    MagAmmoScale=1.300000
    AltIconX=71.000000
    AltIconY=296.000000
    AltIconSize=50.000000
    AltAmmoX=197.000000
    AltAmmoY=294.000000
    AltAmmoScale=0.800000
    ReserveX=141.000000
    ReserveY=455.000000
    ReserveScale=0.900000
    BatteryIconX=441.000000
    BatteryIconY=416.000000
    KF2TextColor=(B=255,G=255,R=255,A=192)
    ChatFontScale=0.500000
    PickupFontScale=0.600000
    KF2TLBase=(WidgetTexture=Texture'KF2HUD.KF2TL_base',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.500000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2TLScan=(WidgetTexture=Texture'KF2HUD.KF2TL_scanline',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2TLOverlay=(WidgetTexture=Texture'KF2HUD.KF2TL_redline',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.700000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=100,G=44,R=26,A=255),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2TLSquare=(WidgetTexture=Texture'KF2HUD.KF2TL_square',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.500000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2TLClock=(WidgetTexture=Texture'KF2HUD.kf2ui_clock',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    KF2TLZed=(WidgetTexture=Texture'KF2HUD.kf2ui_zed',RenderStyle=STY_Alpha,TextureCoords=(X2=512,Y2=256),TextureScale=0.100000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
    TraderBarX=310.000000
    TraderBarY=151.000000
    TraderBarWidth=505.000000
    SquareSize=50.000000
    ArrowPad=32.000000
    ArrowMinDist=100.000000
    ArrowScale=0.500000
    ArrowUp=Texture'KF2HUD.KF2TL_arrowup'
    ArrowDown=Texture'KF2HUD.KF2TL_arrowdown'
    TraderTextX=50.000000
    TraderTextY=66.000000
    TraderTextScale=0.500000
    TraderDistX=558.000000
    TraderDistY=66.000000
    TraderDistScale=0.500000
    WaveTextX=50.000000
    WaveTextY=260.000000
    WaveTextScale=0.500000
    WaveCountX=406.000000
    WaveCountY=260.000000
    WaveCountScale=0.500000
    ClockX=93.000000
    ClockY=339.000000
    ClockSize=88.000000
    ZedX=93.000000
    ZedY=333.000000
    ZedSize=90.000000
    ClockTextX=146.000000
    ClockTextY=338.000000
    ClockTextScale=0.950000
    KillScale=0.650000
    KillSkullSize=34.000000
    KillPadding=4.000000
    damageScale=0.650000
    KillDampen=0.850000
    KillBG=Texture'KF2HUD.kf2ui_kill'
    SkullIcon=Texture'KF2HUD.kf2ui_skull'
    bHideWaitMessage=true
    WarnPulseLimit=3
    WarnScaleMax=1.250000
    WarnScaleMin=0.700000
    WarnIconSize=110.000000
    WarnSubHeight=50.000000
    WarnBarWidth=900.000000
    WarnSubWidth=600.000000
    WarnPulseTime=0.130000
    WarnClip=229.000000
    WarnSubTime=2.000000
    WarnSubStart=1.000000
    WarnSubFadeTime=0.100000
    WarnSubGrowTime=0.050000
    WarnShrinkTime=0.100000
    WarnGrowTime=0.070000
    WarnStayTime=3.000000
    WarnFadeTime=0.500000
    WarnFadeAlpha=0.300000
    WarnTextScale=1.150000
    SubTextScale=0.900000
    WaveCompleteSound=Sound'KF2HUD.kf2mid_wavecomplete'
    WaveBeginSound=Sound'KF2HUD.kf2mid_waveincoming'
    MidWarnTex=Texture'KF2HUD.kf2mid_caution'
    MidSolidTex=Texture'KF2HUD.kf2mid_solid'
    MidLeftTex=Texture'KF2HUD.kf2mid_left'
    MidRightTex=Texture'KF2HUD.kf2mid_right'
    WaveIncomingString="W A V E I N C O M I N G"
    WaveCompleteString="W A V E C O M P L E T E"
    MidTextColor=(B=39,G=34,R=142)
    WaitingMessageClass="ScrnBalanceSrv.ScrnWaitingMessage"
    BBLeft=Texture'KF2HUD.kf2bb_left'
    BBMid=Texture'KF2HUD.kf2bb_middle'
    BBRight=Texture'KF2HUD.kf2bb_right'
    BBSkull=Texture'KF2HUD.kf2bb_skull'
    BBSkullSize=35.000000
    BBSkullX=64.000000
    BBSkullY=67.000000
    BossBarGreen=(B=82,G=148,R=12,A=255)
    BossBarRed=(G=40,R=150,A=255)
    BossTextX=124.000000
    BossTextY=71.000000
    BossTextScale=0.500000
    PlayerBarWidth=172.000000
    PlayerBarHeight=7.000000
    PlayerTextScale=0.400000
    PlayerPerkSize=40.000000
    BarDistMin=350.000000
    BarDistMax=1000.000000
    BarScaleMin=0.500000
    BarScaleMax=1.000000
    KF2TraderString="TRADER"
    KF2WaveString="WAVE"
    WeaponNameScale=0.700000
    WeaponNameOffset=(X=475.000000,Y=169.000000)
    PortraitScale=0.550000
    PortraitTextScale=0.400000
    PortraitY=450.000000
    PortraitTextPad=10.000000
    PortraitBorderSize=4.000000

    HudStyles(4)="KF2 HUD"
    HUDSTL_KF2=4
    HudStyle=4

    BarStyles(4)="KF2 Bars"
    BARSTL_KF2=4
    BarStyle=4
}