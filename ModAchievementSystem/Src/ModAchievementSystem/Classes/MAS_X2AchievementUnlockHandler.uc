class MAS_X2AchievementUnlockHandler extends Object;

static function EventListenerReturn OnAchievementUnlocked(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local MAS_API_AchievementName NameObject;
	local MAS_PersistentAchievementStorage Storage;
	local MAS_X2AchievementTemplate Achievement;
	local XComPresentationLayerBase Pres;

	local MAS_UIAchievementPopupManager Popups;
	local MAS_UIAchievementItem Item;

	NameObject = MAS_API_AchievementName(EventData);
	if (NameObject != none)
	{
		Achievement = class'MAS_X2AchievementHelpers'.static.FindAchievementTemplate(NameObject.AchievementName);
		if (Achievement != none)
		{
			if (Achievement.IsUnlocked() == false) // remove that later
			{
				Storage = new class'MAS_PersistentAchievementStorage';
				Storage.AddUnlockedAchievement(Achievement.DataName);
				`log("MAS -- An Achievement has been unlocked. It is" @ Achievement.DataName);
				Pres = `PRESBASE;
				if(Pres.ScreenStack.IsNotInStack(class'MAS_UIAchievementPopupManager'))
				{
					Popups = Pres.Spawn(class'MAS_UIAchievementPopupManager', Pres);
					Pres.ScreenStack.Push(Popups, Pres.Get2DMovie());
				}
				else
				{
					Popups = MAS_UIAchievementPopupManager(Pres.ScreenStack.GetScreen(class'MAS_UIAchievementPopupManager'));
				}

				Popups.Notify(Achievement);
				
				//Pres.UITutorialBox(Achievement.strTitle, Achievement.strShortDesc $ "<br/> <br/>" $ Achievement.strLongDesc, Achievement.GetWideImagePath());
				
				return ELR_NoInterrupt;	
			}
			`log("MAS -- Achievement" @ Achievement.DataName @ "is already unlocked, but congrats nonetheless. :P");
			return ELR_NoInterrupt;
		}
	}
	`REDSCREEN("BAD ACHIEVEMENT:" @ NameObject.AchievementName);
	return ELR_NoInterrupt;

}