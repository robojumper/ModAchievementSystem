class MAS_PersistentAchievementStorage extends Object config(MAS_NullConfig);

var config array<name> UnlockedAchievements;

function AddUnlockedAchievement(name AchName)
{
	if (UnlockedAchievements.Find(AchName) == INDEX_NONE)
	{
		UnlockedAchievements.AddItem(AchName);
		SaveConfig();
	}
}