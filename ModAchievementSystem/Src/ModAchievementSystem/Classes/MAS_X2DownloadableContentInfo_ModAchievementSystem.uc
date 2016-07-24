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
	EventManager.RegisterForEvent(TriggerObj, 'UnlockAchievement', class'MAS_X2AchievementUnlockHandler'.static.OnAchievementUnlocked, ELD_Immediate, 50, , true);
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
	local LWTuple AchTuple;
	local LWTValue Value;

	AchTuple = new class'LWTuple';
	AchTuple.Id = 'AchievementData';

	Value.kind = LWTVName;
	Value.n = AchName;
	AchTuple.Data.AddItem(Value);

	Value.kind = LWTVName;
	Value.n = 'UnlockAchievement';
	AchTuple.Data.AddItem(Value);

	`XEVENTMGR.TriggerEvent('UnlockAchievement', AchTuple, , );

}

exec function MakeProgressOnAchievement(name AchName)
{

	local LWTuple AchTuple;
	local LWTValue Value;

	AchTuple = new class'LWTuple';
	AchTuple.Id = 'AchievementData';

	Value.kind = LWTVName;
	Value.n = AchName;
	AchTuple.Data.AddItem(Value);

	Value.kind = LWTVName;
	Value.n = 'ProgressByNumber';
	AchTuple.Data.AddItem(Value);

	Value.kind = LWTVInt;
	Value.i = 1;
	AchTuple.Data.AddItem(Value);

	`XEVENTMGR.TriggerEvent('UnlockAchievement', AchTuple, , );

}