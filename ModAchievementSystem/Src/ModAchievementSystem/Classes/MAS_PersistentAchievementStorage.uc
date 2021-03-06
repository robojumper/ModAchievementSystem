// This is the storage for vanilla achievements.
// Mod added ones can implement campaign ones if they want by implementing IsUnlocked
class MAS_PersistentAchievementStorage extends Object config(MAS_NullConfig);

var config array<name> UnlockedAchievements;

struct ProgressStore
{
	var name AchievementName;
	var int iProgress;
};

var config array<ProgressStore> AchievementProgresses;


// DONT CALL THESE FROM ANYWHERE. USE THE TEMPLATE FUNCTIONS RATHER

function AddUnlockedAchievement(name AchName)
{
	if (UnlockedAchievements.Find(AchName) == INDEX_NONE)
	{
		UnlockedAchievements.AddItem(AchName);
		SaveConfig();
	}
	else
	{
		`warn("tried to unlock an achievement that is already unlocked");
	}
}


function bool IsAchievementPersistentlyUnlocked(name AchievementName)
{
	local bool unlocked;
	unlocked = default.UnlockedAchievements.Find(AchievementName) != INDEX_NONE;
	//`log("Achievement" @ AchievementName @ "is" @ unlocked);
	return unlocked;	
}

function int GetStoredProgress(name AchievementName)
{
	local ProgressStore Store;

	foreach AchievementProgresses(Store)
	{
		if(Store.AchievementName == AchievementName)
		{
			return Store.iProgress;
		}
	}
	return 0;
}

function SetStoredProgress(name Achievement, int iProgress)
{
	local ProgressStore Store;
	local int idx;

	foreach AchievementProgresses(Store, idx)
	{
		if(Store.AchievementName == Achievement)
		{
			AchievementProgresses[idx].iProgress = iProgress;
			SaveConfig();
			return;
		}
	}
	Store.AchievementName = Achievement;
	Store.iProgress = iProgress;
	AchievementProgresses.AddItem(Store);
	SaveConfig();
}

function ClearAchievement(name Achievement)
{
	local ProgressStore Store;
	local int idx;

	for(idx = AchievementProgresses.Length - 1; idx >= 0; idx--)
	{
		if(Store.AchievementName == Achievement)
		{
			AchievementProgresses.Remove(idx, 1);
		}
	}

	idx = UnlockedAchievements.Find(Achievement);
	if (idx != INDEX_NONE)
	{
		UnlockedAchievements.Remove(idx, 1);
	}
	SaveConfig();
}