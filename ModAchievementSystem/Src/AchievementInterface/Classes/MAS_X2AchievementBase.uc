// This is an abstract base class for all achievements
// The implementation of MAS_X2AchievementTemplate should be considered
// an example, you can implement your own achievements if you want
class MAS_X2AchievementBase extends X2StrategyElementTemplate abstract;

// Is this achievement unlocked?
function bool IsUnlocked()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return false;
}

// Should this achievement be shown?
function bool ShouldShow()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return true;
}

// How many points?
function int GetPoints()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return -1;
}

// Title shown in List Item + Card
function string GetTitle()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return "ERROR";
}

// Description shown in List Item + Card
function string GetShortDesc()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return "ERROR";
}

// Title shown in Card
function string GetLongDesc()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return "ERROR";
}

// Category used for sorting and grouping
function string GetCategory()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return "ERROR";
}

// Image for the List Item
function string GetSmallImagePath()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return "";
}

// Images for the card. Can be stacked
function array<string> GetWideImagePathStack()
{
	local array<string> Images;
	Images.Length = 0;
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return Images;
}

// Reset this achievement
function Reset()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
}

// these achievements will not get picked up by the list screen
// use this for achievements progression popups
// i.e. never unlocked, context-aware description
function bool IsAuxiliaryAchievement()
{
	`REDSCREEN(default.class.name @ "does not implement" @ GetFuncName());
	return false;
}