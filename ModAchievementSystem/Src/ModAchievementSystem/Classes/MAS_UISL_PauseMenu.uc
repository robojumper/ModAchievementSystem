class MAS_UISL_PauseMenu extends UIScreenListener config(ModAchievementSystem);

var config int iOffset_X;
var config int iOffset_Y;

event OnInit(UIScreen Screen)
{
	local UIPauseMenu Pause;

	local UIButton Button;

	Pause = UIPauseMenu(Screen);

	Button = Pause.Spawn(class'UIButton', Pause).InitButton('Button', "Achievements", OnClickAchievementsButton);
	Button.AnchorTopCenter();
	Button.SetX(iOffset_X);
	Button.SetY(iOffset_Y);
}

simulated function OnClickAchievementsButton(UIButton Button)
{
	OnClickAchievements();
}

simulated function OnClickAchievements()
{
	local UIScreen TempScreen;
	local XComPresentationLayerBase Pres;
	Pres = `PRESBASE;

	if (Pres.ScreenStack.IsNotInStack(class'MAS_UIViewAchievements'))
	{
		TempScreen = Pres.Spawn(class'MAS_UIViewAchievements', Pres);
		Pres.ScreenStack.Push(TempScreen, Pres.Get2DMovie());
	}
}


defaultproperties
{
	ScreenClass = class'UIPauseMenu';
}