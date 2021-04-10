class AssetLoader extends Actor
    notplaceable;

//we need to do this shit or custom font won't load client side
//also added true KF2 font instead of 'Elegance' font that Zedek had originally
#exec OBJ LOAD FILE="KF2Font.utx" package="FPPHUD"

defaultproperties
{
}
