class MAS_X2DownloadableContentInfo_ModAchievementSystem extends X2DownloadableContentInfo;

static event InstallNewCampaign(XComGameState StartState)
{
	local MAS_XComGameState_AchievementObject AchievementObject;
	AchievementObject = MAS_XComGameState_AchievementObject(StartState.CreateStateObject(class'MAS_XComGameState_AchievementObject'));
	StartState.AddStateObject(AchievementObject);

	AddAchievementTriggers(AchievementObject);
}


static event OnLoadedSavedGame()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local MAS_XComGameState_AchievementObject AchievementObject;

	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Mod Achievement State");

	// Add Achievement Object
	AchievementObject = MAS_XComGameState_AchievementObject(History.GetSingleGameStateObjectForClass(class'MAS_XComGameState_AchievementObject', true));
	if (AchievementObject == none) // Prevent duplicate Achievement Objects
	{
		AchievementObject = MAS_XComGameState_AchievementObject(NewGameState.CreateStateObject(class'MAS_XComGameState_AchievementObject'));
		NewGameState.AddStateObject(AchievementObject);
	}
	

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		AddAchievementTriggers(AchievementObject);
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

}

static function AddAchievementTriggers(Object TriggerObj)
{
	local X2EventManager EventManager;

	// Set up triggers for achievements
	EventManager = class'X2EventManager'.static.GetEventManager();
	EventManager.RegisterForEvent(TriggerObj, 'UnlockAchievement', class'MAS_X2AchievementUnlockHandler'.static.OnAchievementUnlocked, ELD_OnStateSubmitted, 50, , true);
}

exec function ViewAchievements()
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

exec function TriggerAchievement(name AchName)
{

	//local XComGameStateHistory History;
	local XComGameState NewGameState;
	//local X2EventManager EventManager;

	local MAS_API_AchievementName AchNameObj;

	//History = class'XComGameStateHistory'.static.GetGameStateHistory();
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Unlocking Achievement" @ AchName);

	//EventManager = class'X2EventManager'.static.GetEventManager();

	AchNameObj = new class'MAS_API_AchievementName';
	AchNameObj.AchievementName = AchName;

	`XEVENTMGR.TriggerEvent('UnlockAchievement', AchNameObj, , NewGameState);
	`log("Triggered UnlockAchievement for" @ AchNameObj.AchievementName);
	`GAMERULES.SubmitGameState(NewGameState);

}


exec function LogAllAchievements()
{
	local array<MAS_X2AchievementTemplate> Achievements;
	local MAS_X2AchievementTemplate AchTemplate;
	
	class'MAS_X2AchievementHelpers'.static.GetAllAchievementTemplates(Achievements);

	foreach Achievements(AchTemplate)
	{
		`log("Found an Achievement:"@AchTemplate.DataName);
	}
}