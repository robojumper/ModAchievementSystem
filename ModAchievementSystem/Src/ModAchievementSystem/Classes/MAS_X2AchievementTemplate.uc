class MAS_X2AchievementTemplate extends X2StrategyElementTemplate config(ModAchievementSystem);

//var name DataName;

var config string strImage_Disabled;
var config string strImage_Enabled;
var config string strImage_WideEnabled;
var config string strImage_WideDisabled;

var localized string strTitle;
var localized string strShortDesc;
var localized string strLongDesc;

var localized string strCategory;

var config bool bHidden;

var config int iPoints;


var config int iTotalProgressRequired; // if larger than 0, this achievement is treated as a progression achievement
var config bool bNoAutoUnlock; // by default, progression achievements are automatically unlocked when progression reaches specified total
var config bool bNoCapForProgression; // let numbers exceed the cap

var private bool bUnlockedThisSession; // we can't rely on the persistent storage always being up to date
var private bool bProgressReadThisSession; // be it a small delay or a restart that is required
var private int iProgressSessionCache; // so we are caching results

function Unlock()
{
	local MAS_PersistentAchievementStorage Storage;
	Storage = new class'MAS_PersistentAchievementStorage';
	Storage.AddUnlockedAchievement(DataName);
	bUnlockedThisSession = true;
}

function int GetProgress()
{
	local MAS_PersistentAchievementStorage Storage;
	Storage = new class'MAS_PersistentAchievementStorage';
	if(IsProgressionAchievement())
	{
		if (bProgressReadThisSession == false)
		{
			iProgressSessionCache = Storage.GetStoredProgress(DataName);
			bProgressReadThisSession = true;
		}
		return iProgressSessionCache;
	}
	else
	{
		`REDSCREEN("GetProgress Called on a non-progression achievement");
	}
}

function MakeProgress(int iProgress)
{
	SetProgress(GetProgress() + iProgress);	
}

function SetProgress(int iProgress)
{
	local MAS_PersistentAchievementStorage Storage;
	Storage = new class'MAS_PersistentAchievementStorage';

	iProgressSessionCache = iProgress;
	Storage.SetStoredProgress(DataName, iProgress);
	bProgressReadThisSession = true;
}

function bool IsUnlocked()
{
	local MAS_PersistentAchievementStorage Storage;
	Storage = new class'MAS_PersistentAchievementStorage';
	return Storage.IsAchievementPersistentlyUnlocked(DataName) || bUnlockedThisSession;
}

function bool IsProgressionAchievement()
{
	return iTotalProgressRequired > 0;
}

function string GetSmallImagePath()
{
	return IsUnlocked() ? strImage_Enabled : strImage_Disabled;
}

function string GetWideImagePath()
{
	return IsUnlocked() ? strImage_WideEnabled : strImage_WideDisabled;
}