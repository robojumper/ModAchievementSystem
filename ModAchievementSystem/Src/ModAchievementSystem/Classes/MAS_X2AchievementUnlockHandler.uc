class MAS_X2AchievementUnlockHandler extends Object;

static function EventListenerReturn OnAchievementUnlocked(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{	
	local MAS_X2AchievementTemplate Achievement;

	local MAS_API_AchievementName NameObject;
	local LWTuple AchievementTuple;
	local name AchievementName;

	local name Command;

	NameObject = MAS_API_AchievementName(EventData);
	if (NameObject != none)
	{
		AchievementName = NameObject.AchievementName;
		Command = 'UnlockAchievement';
	}
	
	AchievementTuple = LWTuple(EventData);
	if (AchievementTuple != none && AchievementTuple.Id == 'AchievementData')
	{
		AchievementName = AchievementTuple.Data[0].n;
		Command = AchievementTuple.Data[1].n;
	}

	Achievement = class'MAS_X2AchievementHelpers'.static.FindAchievementTemplate(AchievementName);
	if (Achievement != none)
	{
		if (Command == 'UnlockAchievement')
		{
			TryUnlockAchievement(Achievement);
		}
		else if (Command == 'ProgressByNumber')
		{
			Achievement.MakeProgress(AchievementTuple.Data[2].i);
			CheckProgress(Achievement);
		}
		else if (Command == 'SetProgress')
		{
			Achievement.SetProgress(AchievementTuple.Data[2].i);
			CheckProgress(Achievement);
		}
	}
	return ELR_NoInterrupt;
}

static function CheckProgress(MAS_X2AchievementTemplate Achievement)
{
	if (Achievement.GetProgress() >= Achievement.iTotalProgressRequired && !Achievement.bNoAutoUnlock && Achievement.IsProgressionAchievement())
	{
		TryUnlockAchievement(Achievement);
	}
}

static function TryUnlockAchievement(MAS_X2AchievementTemplate Achievement)
{
	local XComPresentationLayerBase Pres;

	local MAS_UIAchievementPopupManager Popups;
	local MAS_UIAchievementPopupManager ActorIterator;

	if (Achievement.IsUnlocked() == false)
	{
		
		//Achievement.bUnlockedThisSession = true; // Hack because storage doesn't work until the next startup (or small delay)
		Achievement.Unlock();
		`log("MAS -- An Achievement has been unlocked. It is" @ Achievement.DataName);
		Pres = `PRESBASE;
		
		foreach Pres.AllActors(class'MAS_UIAchievementPopupManager', ActorIterator)
		{
			Popups = ActorIterator;
		}

		if(Popups == none)
		{
			`log("Created a new Achievement Popup Manager Screen");
			Popups = Pres.Spawn(class'MAS_UIAchievementPopupManager', Pres);
			Popups.InitScreen(XComPlayerController(Pres.Owner), Pres.Get2DMovie());
			Pres.Get2DMovie().LoadScreen(Popups);
		}
		
		Popups.Notify(Achievement);
			
		//Pres.UITutorialBox(Achievement.strTitle, Achievement.strShortDesc $ "<br/> <br/>" $ Achievement.strLongDesc, Achievement.GetWideImagePath());
			
		return;	
	}
	`log("MAS -- Achievement" @ Achievement.DataName @ "is already unlocked, but congrats nonetheless. :P");
	return;
}