class MAS_UISL_PauseMenu extends UIScreenListener config(ModAchievementSystem);

var config int iOffset_X;
var config int iOffset_Y;

event OnInit(UIScreen Screen)
{
	local UIPauseMenu Pause;
	local vector2d wayoffpos;
	local UIListItemString ListItem;
	local int i, j;

	Pause = UIPauseMenu(Screen);
	if (Pause != none && UIShellStrategy(Pause) == none)
	{
		ListItem = UIListItemString(Pause.List.CreateItem());
		ListItem.InitListItem(class'MAS_UIViewAchievements'.default.m_strTitle);
		ListItem.SetConfirmButtonStyle(eUIConfirmButtonStyle_Default, , , , OnClickAchievementsButton, );
		wayoffpos.Y = 3;
		ListItem.ConfirmButton.SetNormalizedPosition(wayoffpos);

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