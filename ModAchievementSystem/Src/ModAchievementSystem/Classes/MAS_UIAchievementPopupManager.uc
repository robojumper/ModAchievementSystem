class MAS_UIAchievementPopupManager extends UIScreen config(ModAchievementSystem);



var UIX2PanelHeader TitleHeader;

var MAS_UIAchievementCard ItemCard;

var UIPanel ListContainer; // contains all controls bellow
var UIList List;
var UIPanel ListBG;

var name DisplayTag;
var name CameraTag;

var config int iOffset_X;
var config int iOffset_Y;

var name InventoryListName;

//Flag for type of info to fill in right info card. 
var bool bSelectFirstAvailable; 
var bool bUseSimpleCard; 

// Set this to specify how long camera transition should take for this screen
var float OverrideInterpTime;


struct UIAchNoticeItem
{
	var MAS_X2AchievementTemplate Template;
	var float DisplayTime;
	structDefaultProperties
	{
		DisplayTime = 0.0;
	}
};

var float MaxDisplayTime; 
var array<UIAchNoticeItem> Notices;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	//`log("UIViewAchievements Init");
	super.InitScreen(InitController, InitMovie, InitName);


	BuildScreen();
	//UpdateNavHelp();
}

simulated function BuildScreen()
{
	`log("BuildScreen Called");
	// BAsically, spawn everything and then hide it
	TitleHeader = Spawn(class'UIX2PanelHeader', self);
	TitleHeader.InitPanelHeader('TitleHeader', "", "");
	TitleHeader.SetHeaderWidth( 580 );
	//if( m_strTitle == "" && m_strSubTitleTitle == "" )
	TitleHeader.Hide();
	
	ListContainer = Spawn(class'UIPanel', self).InitPanel('InventoryContainer');
	ListContainer.AnchorBottomRight();
	ListContainer.SetPosition(iOffset_X, iOffset_Y);
	ItemCard = Spawn(class'MAS_UIAchievementCard', ListContainer).InitAchievementCard('ItemCard');
	ItemCard.Hide();

	ListBG = Spawn(class'UIPanel', ListContainer);
	ListBG.InitPanel('InventoryListBG'); 
	ListBG.bShouldPlayGenericUIAudioEvents = false;
	ListBG.Hide();

	List = Spawn(class'UIList', ListContainer);
	List.InitList(InventoryListName);
	List.bSelectFirstAvailable = bSelectFirstAvailable;
	List.bStickyHighlight = true;
	//List.OnSelectionChanged = SelectedItemChanged;
	Navigator.SetSelected(ListContainer);
	ListContainer.Navigator.SetSelected(List);
	
	/*TestItem = Spawn(class'MAS_UIAchievementItem', List.itemContainer).InitInventoryListAchievement(none);
	TestItem.SetWarning(true);
	TestItem.OnReceiveFocus();*/
	SetCategory("");
	SetBuiltLabel("");

}

event Tick(float deltaTime)
{
	local int i, iInitialNotices;

	if (bIsVisible)
	{
		if (Notices.Length == 0) return;
		if (Movie.Stack.IsCurrentClass(class'UIDialogueBox')) return;

		iInitialNotices = Notices.length;

		if (Notices.Length > 0)
		{
			// Go from end to beginning because we may be removing items from the array. 
			for (i = Notices.Length - 1; i >= 0; i--)
			{
				Notices[i].DisplayTime += deltaTime;

				if (Notices[i].DisplayTime > MaxDisplayTime)
				{
					Notices.Remove(i, 1);
				}
			}
		}

		if (Notices.Length != iInitialNotices)
		{
			List.ClearItems();
			UpdateEventNotices();
		}
	}
}

simulated function Notify(MAS_X2AchievementTemplate Template)
{
	local UIAchNoticeItem Notice;

	Notice.Template = Template;
	Notices.AddItem(Notice);
	UpdateEventNotices();
	WorldInfo.PlayAkEvent(AkEvent'SoundTacticalUI_Hacking.Unlock_Second_Item');
}

simulated function UpdateEventNotices()
{
	local int i;
	local MAS_UIAchievementItem ListItem;

	if(Notices.Length > 0)
	{
		for(i = 0; i < Notices.Length; ++i)
		{
			if( List.ItemCount <= i )
			{
				ListItem = Spawn(class'MAS_UIAchievementItem', List.itemContainer).InitInventoryListAchievement(Notices[i].Template);
			}
			else
			{
				ListItem = MAS_UIAchievementItem(List.GetItem(i));
			}

			ListItem.PopulateData();
			ListItem.SetWarning(true);
			ListItem.OnReceiveFocus();

		}
		Show();
	}
	else
	{
		Hide();
	}

	//List.SetY(-List.ShrinkToFit());
}

simulated function bool AnyNotices()
{
	return Notices.Length > 0;
}

simulated function SetCategory(string Category)
{
	MC.BeginFunctionOp("setItemCategory");
	MC.QueueString(Category);
	MC.EndOp();
}

simulated function SetBuiltLabel(string Label)
{
	MC.BeginFunctionOp("setBuiltLabel");
	MC.QueueString(Label);
	MC.EndOp();
}



simulated function SetChooseResearchLayout()
{
	MC.FunctionVoid( "setChooseResearchLayout" );
}


simulated function PlaySFX(String Sound)
{
	`XSTRATEGYSOUNDMGR.PlaySoundEvent(Sound);
}


defaultproperties
{
	Package = "/ package/gfxInventory/Inventory";

	InventoryListName="inventoryListMC";
	bAnimateOnInit = true;
	bSelectFirstAvailable = true;

	OverrideInterpTime = -1;
	MaxDisplayTime = 4.0;

	bShowDuringCinematic=true
}