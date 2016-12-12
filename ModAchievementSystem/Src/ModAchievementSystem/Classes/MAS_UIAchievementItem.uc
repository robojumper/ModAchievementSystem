class MAS_UIAchievementItem extends UIListItemString;

var MAS_X2AchievementBase AchTemplate;

simulated function UIListItemString InitListItem(optional string InitText)
{
	InitPanel();

	//OVERRIDE what the base class is setting for 3D/2D, since we're using a super giant button.
	MC.ChildSetNum("theButton", "_height", height-4);
	return self;
}

simulated function PopulateData(optional bool bRealizeDisabled)
{
	MC.BeginFunctionOp("populateData");
	MC.QueueString(AchTemplate.GetSmallImagePath());
	MC.QueueString(AchTemplate.GetTitle());
	MC.QueueString(AchTemplate.GetPointsString());
	MC.QueueString(AchTemplate.GetShortDesc());
	MC.EndOp();

	RealizeGoodState();
	RealizeDisabledState();
}

simulated function OnInit()
{
	super.OnInit();	
	PopulateData();
}


simulated function MAS_UIAchievementItem InitInventoryListAchievement(MAS_X2AchievementBase Template)
{
	AchTemplate = Template;
	InitListItem();

	RealizeGoodState();
	RealizeDisabledState();

	return self;
}

simulated function RealizeGoodState()
{
	local MAS_UIViewAchievements AchScreen;
	local int AchIndex;

	if( ClassIsChildOf(Screen.Class, class'MAS_UIViewAchievements') )
	{
		AchScreen = MAS_UIViewAchievements(Screen);
		AchIndex = AchScreen.GetItemIndex(AchTemplate);
		ShouldShowGoodState(AchScreen.ShouldShowGoodState(AchIndex));
	}
}


simulated function RealizeDisabledState()
{
	local bool bIsDisabled;
	local MAS_UIViewAchievements AchScreen;
	local int AchIndex;

	if(ClassIsChildOf(Screen.Class, class'MAS_UIViewAchievements'))
	{
		AchScreen = MAS_UIViewAchievements(Screen);
		AchIndex = AchScreen.GetItemIndex(AchTemplate);
		bIsDisabled = AchScreen.ShouldShowItemDisabledState(AchIndex);
	}

	SetDisabled(bIsDisabled);
}

defaultproperties
{
	LibID = "InventoryClassListItem";
	bShouldSet3DHeight=false;
	bCascadeFocus = false;
	height = 130;
}