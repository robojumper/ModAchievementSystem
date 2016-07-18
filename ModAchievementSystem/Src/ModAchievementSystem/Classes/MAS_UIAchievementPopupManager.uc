class MAS_UIAchievementPopupManager extends UIScreen;

var localized string m_strTitle;
var localized string m_strSubTitleTitle;
var localized string m_strConfirmButtonLabel;
var localized string m_strInventoryLabel;
var localized string m_strSellLabel;
var localized string m_strTotalLabel;
var localized string m_strEmptyListTitle;

var UIX2PanelHeader TitleHeader;

var MAS_UIAchievementCard ItemCard;

var UIPanel ListContainer; // contains all controls bellow
var UIList List;
var UIPanel ListBG;

var XComGameStateHistory History;
var XComGameState_HeadquartersXCom XComHQ;

var name DisplayTag;
var name CameraTag;

var MAS_UIAchievementItem TestItem;

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

	History = `XCOMHISTORY;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ(true);

	BuildScreen();
	UpdateNavHelp();
}

simulated function BuildScreen()
{
	`log("BuildScreen Called");
	// BAsically, spawn everything and then hide it
	/*TitleHeader = Spawn(class'UIX2PanelHeader', self);
	TitleHeader.InitPanelHeader('TitleHeader', m_strTitle, m_strSubTitleTitle);
	TitleHeader.SetHeaderWidth( 580 );
	if( m_strTitle == "" && m_strSubTitleTitle == "" )
		TitleHeader.Hide();
	*/
	ListContainer = Spawn(class'UIPanel', self).InitPanel('InventoryContainer');
	ListContainer.AnchorBottomRight();
	ListContainer.SetPosition(-600, -400);
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
	SetCategory(m_strInventoryLabel);
	SetBuiltLabel(m_strTotalLabel);

	// send mouse scroll events to the list
	ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

	if( bIsIn3D )
		class'UIUtilities'.static.DisplayUI3D(DisplayTag, CameraTag, OverrideInterpTime != -1 ? OverrideInterpTime : `HQINTERPTIME);
}

/*simulated function PopulateData()
{
	// override behavior in child classes
	List.ClearItems();
	PopulateAchievementCard();

	if( List.ItemCount == 0 && m_strEmptyListTitle  != "" )
	{
		TitleHeader.SetText(m_strTitle, m_strEmptyListTitle);
		SetCategory("");
	}
}*/

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
				ListItem = Spawn(class'MAS_UIAchievementItem', List.itemContainer).InitInventoryListAchievement(Notices[i].Template);
			else
				ListItem = MAS_UIAchievementItem(List.GetItem(i));

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

	List.SetY(-List.ShrinkToFit());
}

simulated function bool AnyNotices()
{
	return Notices.Length > 0;
}


/*simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local MAS_UIAchievementItem ListItem;
	//`log("MAS -- Changed Selection");
	ListItem = MAS_UIAchievementItem(ContainerList.GetItem(ItemIndex));
	if(ListItem != none)
	{
		if(ListItem.AchTemplate != none)
		{
			PopulateAchievementCard(ListItem.AchTemplate);
			//`log("MAS -- Populated card");
		}
		
	}
}*/


/*simulated function PopulateAchievementCard(optional MAS_X2AchievementTemplate AchievementTemplate)
{
	if( ItemCard != none )
	{
		if( AchievementTemplate != None )
		{
			ItemCard.PopulateAchievementCard(AchievementTemplate);
			//`log("MAS -- Populated card called");
			ItemCard.Show();
		}
		else
		{
			ItemCard.Hide();
		}
	}
}*/

/*simulated function PopulateItemCard(optional X2ItemTemplate ItemTemplate, optional StateObjectReference ItemRef)
{
	if( ItemCard != none )
	{
		if( ItemTemplate != None )
		{
			ItemCard.PopulateItemCard(ItemTemplate, ItemRef);
			ItemCard.Show();
		}
		else
			ItemCard.Hide();
	}
}*/

/*simulated function PopulateResearchCard(optional Commodity ItemCommodity, optional StateObjectReference ItemRef)
{
	ItemCard.PopulateResearchCard(ItemCommodity, ItemRef);
	ItemCard.Show();
}*/

/*simulated function PopulateSimpleCommodityCard(optional Commodity ItemCommodity, optional StateObjectReference ItemRef)
{
	ItemCard.PopulateSimpleCommodityCard(ItemCommodity, ItemRef);
	ItemCard.Show();
}*/

/*simulated function HideQueue()
{
	local UIScreen QueueScreen;
	
	QueueScreen = Movie.Stack.GetScreen(class'UIFacility_Storage');
	if( QueueScreen != None )
		UIFacility_Storage(QueueScreen).Hide();
}*/

/*simulated function ShowQueue(optional bool bRefreshQueue = false)
{
	local UIScreen QueueScreen;
	
	QueueScreen = Movie.Stack.GetScreen(class'UIFacility_Storage');
	if( QueueScreen != None )
	{
		if(bRefreshQueue)
		{
			//UIFacility_Storage(QueueScreen).UpdateBuildQueue();
		}
		UIFacility_Storage(QueueScreen).Show();
	}
}*/

simulated function UpdateNavHelp()
{
	/*`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
	`HQPRES.m_kAvengerHUD.NavHelp.AddBackButton(CloseScreen);*/
}

/*simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	// Only pay attention to presses or repeats; ignoring other input types
	// NOTE: Ensure repeats only occur with arrow keys
	if ( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	bHandled = true;
	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			OnCancel();
			break;
		case class'UIUtilities_Input'.const.FXS_BUTTON_START:
			`HQPRES.UIPauseMenu( ,true );
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}*/

// -1 will hide the highlight.
/*simulated function SetTabHighlight(int TabIndex)
{
	MC.BeginFunctionOp("setTabHighlight");
	MC.QueueNumber(TabIndex);
	MC.EndOp();
}*/

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

/*simulated function SetBuildItemLayout()
{
	MC.FunctionVoid( "setBuildItemLayout" );
}*/

simulated function SetChooseResearchLayout()
{
	MC.FunctionVoid( "setChooseResearchLayout" );
}

/*simulated function SetInventoryLayout()
{
	MC.FunctionVoid( "setInventoryLayout" );
}

simulated function SetBlackMarketLayout()
{
	MC.FunctionVoid( "setBlackMarketLayout" );
}*/

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	if(bIsIn3D)
		UIMovie_3D(Movie).HideDisplay(DisplayTag);
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	UpdateNavHelp();
	if(bIsIn3D)
		class'UIUtilities'.static.DisplayUI3D(DisplayTag, CameraTag, `HQINTERPTIME);
}

simulated function PlaySFX(String Sound)
{
	`XSTRATEGYSOUNDMGR.PlaySoundEvent(Sound);
}

simulated function XComGameState_HeadquartersResistance RESHQ()
{
	return class'UIUtilities_Strategy'.static.GetResistanceHQ();
}

simulated function XComGameState_HeadquartersAlien ALIENHQ()
{
	return class'UIUtilities_Strategy'.static.GetAlienHQ();
}

simulated function XComGameState_BlackMarket BLACKMARKET()
{
	return class'UIUtilities_Strategy'.static.GetBlackMarket();
}

simulated function OnCancel()
{
	CloseScreen();
	if(bIsIn3D)
		UIMovie_3D(Movie).HideDisplay(DisplayTag);
}

defaultproperties
{
	Package = "/ package/gfxInventory/Inventory";

	InventoryListName="inventoryListMC";
	bAnimateOnInit = true;
	bSelectFirstAvailable = true;

	OverrideInterpTime = -1;
	MaxDisplayTime = 5.0; 
}