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
	var MAS_X2AchievementBase Template;
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
	Hide();
	//UpdateNavHelp();
}

// To show an achievement, trigger 'ShowAchievementMessage' with an LWTuple as the Data: Id = 'AchievementMessage'
// Data[0].n = AchievementName
static function EventListenerReturn ShowMessageHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{

	local MAS_X2AchievementBase Achievement;

	local LWTuple AchievementTuple;
	local name AchievementName;
	`log("Received Unlock Message!");
	AchievementTuple = LWTuple(EventData);
	if (AchievementTuple != none && AchievementTuple.Id == 'AchievementMessage')
	{
		AchievementName = AchievementTuple.Data[0].n;
	}

	Achievement = class'MAS_X2AchievementHelpers'.static.FindAchievementTemplate(AchievementName);

	ShowUnlockMessage(Achievement);

	return ELR_NoInterrupt;
}

static function ShowUnlockMessage(MAS_X2AchievementBase AchievementTemplate)
{
	local XComPresentationLayerBase Pres;

	local MAS_UIAchievementPopupManager Popups;
	local MAS_UIAchievementPopupManager ActorIterator;

	Pres = `PRESBASE;
		
	foreach Pres.AllActors(class'MAS_UIAchievementPopupManager', ActorIterator)
	{
		Popups = ActorIterator;
	}
		
	if(Popups == none)
	{
		`log("Created a new Achievement Popup Manager Screen");
		Popups = Pres.Spawn(class'MAS_UIAchievementPopupManager', Pres);
		Popups.InitScreen(XComPlayerController(Pres.Owner), Pres.Get2DMovie());
		Pres.Get2DMovie().LoadScreen(Popups);
	}
		
	Popups.Notify(AchievementTemplate);
}

simulated function BuildScreen()
{
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

simulated function Notify(MAS_X2AchievementBase Template)
{
	local UIAchNoticeItem Notice;
	if (Template != none)
	{
		Notice.Template = Template;
		Notices.AddItem(Notice);
		UpdateEventNotices();
		if (Template.IsUnlocked())
		{
			WorldInfo.PlayAkEvent(AkEvent'SoundTacticalUI_Hacking.Unlock_Second_Item');
		}
	}
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
			if (Notices[i].Template.IsUnlocked())
			{
				ListItem.SetWarning(true);
				ListItem.OnReceiveFocus();
			}

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