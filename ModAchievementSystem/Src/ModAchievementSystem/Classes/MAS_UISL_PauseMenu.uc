class MAS_UISL_PauseMenu extends UIScreenListener dependson(X2GameRuleset);

var UIMovie Movie;

event OnInit(UIScreen Screen)
{
	local UINavigationHelp NavHelp;
	local UIPauseMenu Pause;
	//local UIMovie Movie;
	Pause = UIPauseMenu(Screen);
	Movie = Screen.Movie;
	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;
	if(NavHelp == none)
	{
		NavHelp = Screen.PC.Pres.GetNavHelp();
		if(NavHelp == none)
			NavHelp = Screen.Spawn(class'UINavigationHelp',Screen).InitNavHelp();
	}
	if(NavHelp != none)
	{
		//NavHelp.ClearButtonHelp();
		NavHelp.AddCenterHelp("Achievements", "", OnClickAchievements, false, "Open the Achievement Panel");
	}
}

simulated function OnClickAchievements()
{
	local UIScreen TempScreen;
	local XComPresentationLayerBase Pres;
	Pres = `PRESBASE;

	if (Pres.ScreenStack.IsNotInStack(class'MAS_UIViewAchievements'))
	{
		TempScreen = Pres.Spawn(class'MAS_UIViewAchievements', Pres);
		//UIChooseClass(TempScreen).m_UnitRef = UnitRef;
		Pres.ScreenStack.Push(TempScreen, Pres.Get2DMovie());
	}
}


defaultproperties
{
	ScreenClass = class'UIPauseMenu';
}