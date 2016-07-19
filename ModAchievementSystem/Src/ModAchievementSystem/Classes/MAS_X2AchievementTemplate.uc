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

var bool bUnlockedThisSession;

function bool IsUnlocked()
{
	return class'MAS_X2AchievementHelpers'.static.IsAchievementUnlocked(DataName) || bUnlockedThisSession;
}

function string GetSmallImagePath()
{
	return IsUnlocked() ? strImage_Enabled : strImage_Disabled;
}

function string GetWideImagePath()
{
	return IsUnlocked() ? strImage_WideEnabled : strImage_WideDisabled;
}