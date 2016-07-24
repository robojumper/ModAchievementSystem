class MAS_UIAchievementItem extends UIListItemString;

var MAS_X2AchievementTemplate AchTemplate;

simulated function UIListItemString InitListItem(optional string InitText)
{
	InitPanel();

	//OVERRIDE what the base class is setting for 3D/2D, since we're using a super giant button.
	MC.ChildSetNum("theButton", "_height", height-4);
	return self;
}

simulated function PopulateData(optional bool bRealizeDisabled)
{
	local string shortDesc;
	shortDesc = AchTemplate.strShortDesc @ AchTemplate.IsProgressionAchievement() ? "(" $ (AchTemplate.bNoCapForProgression ? AchTemplate.GetProgress() : Min(AchTemplate.GetProgress(), AchTemplate.iTotalProgressRequired)) $ "/" $ AchTemplate.iTotalProgressRequired $ ")" : "";
	MC.BeginFunctionOp("populateData");
	MC.QueueString(AchTemplate.GetSmallImagePath());
	MC.QueueString(AchTemplate.strTitle);
	MC.QueueString(AchTemplate.iPoints @ class'MAS_UIViewAchievements'.default.m_strPoints);
	MC.QueueString(shortDesc);
	MC.EndOp();

	RealizeGoodState();
	RealizeDisabledState();
}

simulated function OnInit()
{
	super.OnInit();	
	PopulateData();
}


simulated function MAS_UIAchievementItem InitInventoryListAchievement(MAS_X2AchievementTemplate Template)
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