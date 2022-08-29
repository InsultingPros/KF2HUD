class KF2GUILabel extends GUILabel;

var()		byte		AlignMode;
var()		font		KF2Font;
var()		bool		bKorean;
var()		float		KoreanScale;

function bool InternalDraw(Canvas canvas)
{
	local float AW, AH, AL, AT, SS, TW, TH;
	local float TempX, TempY;
	local Font F;

	if (bVisible)
	{
		AW = ActualWidth();
		AH = ActualHeight();
		AL = ActualLeft();
		AT = ActualTop();

		SS = canvas.ClipY / 1080.0;

		F = Canvas.Font;

		// if (default.bKorean)
		// 	Canvas.Font = Class'FHLang_Core'.default.KoreanFont;
		// else
			Canvas.Font = KF2Font;

		Canvas.FontScaleX = 1.0;
		Canvas.FontScaleY = 1.0;

		Canvas.TextSize(Caption, TW, TH);

		Canvas.FontScaleX = (AH / TH) * SS;
		Canvas.FontScaleY = (AH / TH) * SS;

		if (default.bKorean)
		{
			Canvas.FontScaleX *= KoreanScale;
			Canvas.FontScaleY *= KoreanScale;
		}

		Canvas.TextSize(Caption, TW, TH);

		TempY = (AT + (AH*0.5)) - (TH*0.5);

		if (AlignMode == 0)
			TempX = AL;
		else if (AlignMode == 1)
			TempX = ( AL+ (AW*0.5) ) - (TW*0.5);
		else if (AlignMode == 2)
			TempX = (AL+AW) - TW;

		Canvas.SetPos(TempX, TempY);
		Canvas.DrawColor = TextColor;
		Canvas.DrawText(Caption);

		Canvas.Font = F;
		Canvas.FontScaleX = 1.0;
		Canvas.FontScaleY = 1.0;
	}

	return true;
}

defaultproperties
{
     KF2Font=Font'KF2HUD.KF2Font'
     KoreanScale=0.900000
     OnDraw=KF2GUILabel.InternalDraw
}
