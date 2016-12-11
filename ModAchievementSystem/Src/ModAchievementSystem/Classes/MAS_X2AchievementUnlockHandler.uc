// This class is responsible for managing the vanilla achievement interactions
// Mod added ones can not use it
// For popups there is an event
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

	Achievement = MAS_X2AchievementTemplate(class'MAS_X2AchievementHelpers'.static.FindAchievementTemplate(AchievementName));
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
	local LWTuple AchTuple;
	local LWTValue Val;
	if (Achievement.IsUnlocked() == false)
	{
		Achievement.Unlock();
		//class'MAS_UIAchievementPopupManager'.static.ShowUnlockMessage(Achievement);
		AchTuple = new class'LWTuple';
		AchTuple.Id = 'AchievementMessage';

		Val.kind = LWTVName;
		Val.n = Achievement.DataName;
		AchTuple.Data.AddItem(Val);
		`XEVENTMGR.TriggerEvent('ShowAchievementMessage', AchTuple);
	}
}