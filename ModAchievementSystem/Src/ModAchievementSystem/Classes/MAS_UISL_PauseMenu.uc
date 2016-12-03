class MAS_UISL_PauseMenu extends UIScreenListener config(ModAchievementSystem);

var config int iOffset_X;
var config int iOffset_Y;


event OnInit(UIScreen Screen)
{
	local UIPauseMenu Pause;
	//local int i, j;
	local UIButton ListItem;

	Pause = UIPauseMenu(Screen);
	if (Pause != none && UIShellStrategy(Pause) == none)
	{
		ListItem = UIButton(Pause.List.CreateItem(class'UIButton'));
		ListItem.ResizeToText = false;
		ListItem.InitButton('DatButton', class'MAS_UIViewAchievements'.default.m_strTitle, OnClickAchievementsButton, eUIButtonStyle_NONE);
		ListItem.SetResizeToText(false);
		ListItem.SetHeight(32);
		ListItem.SetWidth(Pause.List.width);
		ListItem.SetFontSize(22);
		ListItem.MC.SetBool("isHTML", true);
		ListItem.MC.SetNum("scale", 0);
		ListItem.MC.SetString("text", "<p align=\'LEFT\'>" $ "  " $ class'MAS_UIViewAchievements'.default.m_strTitle $ "</p>");
		ListItem.MC.FunctionVoid("realize");

/*		MoveItemToTop(Pause.List, ListItem);
		j = Pause.List.GetItemCount() - 3;
		for(i = 0; i < j; i++)
		{
			MoveItemToTop(Pause.List, Pause.List.GetItem(j));
		}*/
	}
}



simulated function MoveItemToTop(UIList List, UIPanel Item)
{
	local int i;
	local UIPanel CachedNavigatorPanel;

	List.MoveItemToTop(Item);
	for (i = 0; i < List.Navigator.NavigableControls.Length; i++)
	{
		if (List.Navigator.NavigableControls[i] == Item)
		{
			CachedNavigatorPanel = List.Navigator.NavigableControls[i];
			List.Navigator.NavigableControls.RemoveItem(CachedNavigatorPanel);
			List.Navigator.NavigableControls.InsertItem(0, CachedNavigatorPanel);
		}
	}
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
	//ScreenClass = class'UIPauseMenu';
}