class MAS_UISL_FinalShell extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIFinalShell ShellScreen;
	local UIX2MenuButton Button;

	ShellScreen = UIFinalShell(Screen);

	if (ShellScreen != none)
	{
		//ShellScreen.CreateItem('Achievements', class'MAS_UIViewAchievements'.default.m_strTitle);
		Button = ShellScreen.Spawn(class'UIX2MenuButton', ShellScreen.MainMenuContainer);

		Button.InitMenuButton(false, 'Achievements', Caps(class'MAS_UIViewAchievements'.default.m_strTitle), OnMenuButtonClicked);
		Button.OnSizeRealized = ShellScreen.OnButtonSizeRealized;
		ShellScreen.MainMenu.AddItem(Button);
	}
}

// Button callbacks
simulated function OnMenuButtonClicked(UIButton button)
{
	if( UIFinalShell(button.ParentPanel.ParentPanel).m_bDisableActions)
		return;

	if (button.MCName == 'Achievements')
	{
		button.ConsoleCommand("ViewAchievements");
	}
}