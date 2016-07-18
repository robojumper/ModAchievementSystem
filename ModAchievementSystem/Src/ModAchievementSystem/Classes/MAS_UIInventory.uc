class MAS_UIInventory extends UIScreen;

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

var name InventoryListName;

// Set this to specify how long camera transition should take for this screen
var float OverrideInterpTime;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	//`log("UIViewAchievements Init");
	super.InitScreen(InitController, InitMovie, InitName);

	BuildScreen();
	UpdateNavHelp();
}

simulated function BuildScreen()
{
	`log("BuildScreen Called");
	TitleHeader = Spawn(class'UIX2PanelHeader', self);
	TitleHeader.InitPanelHeader('TitleHeader', m_strTitle, m_strSubTitleTitle);
	TitleHeader.SetHeaderWidth( 580 );
	if( m_strTitle == "" && m_strSubTitleTitle == "" )
		TitleHeader.Hide();

	ListContainer = Spawn(class'UIPanel', self).InitPanel('InventoryContainer');

	ItemCard = Spawn(class'MAS_UIAchievementCard', ListContainer).InitAchievementCard('ItemCard');
	//ItemCard.Hide();
	//`log("ItemCard Created");
	//ItemCard.SetPosition(615, 0);

	ListBG = Spawn(class'UIPanel', ListContainer);
	ListBG.InitPanel('InventoryListBG'); 
	ListBG.bShouldPlayGenericUIAudioEvents = false;
	ListBG.Show();

	List = Spawn(class'UIList', ListContainer);
	List.InitList(InventoryListName);
	List.bStickyHighlight = true;
	List.OnSelectionChanged = SelectedItemChanged;
	Navigator.SetSelected(ListContainer);
	ListContainer.Navigator.SetSelected(List);
	
	SetCategory(m_strInventoryLabel);
	SetBuiltLabel(m_strTotalLabel);

	// send mouse scroll events to the list
	ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

}

simulated function PopulateData()
{
	// override behavior in child classes
	List.ClearItems();
	PopulateAchievementCard();

	if( List.ItemCount == 0 && m_strEmptyListTitle  != "" )
	{
		TitleHeader.SetText(m_strTitle, m_strEmptyListTitle);
		SetCategory("");
	}
}

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
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
}


simulated function PopulateAchievementCard(optional MAS_X2AchievementTemplate AchievementTemplate)
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
}

simulated function UpdateNavHelp()
{
	/*`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
	`HQPRES.m_kAvengerHUD.NavHelp.AddBackButton(CloseScreen);*/
}

simulated function bool OnUnrealCommand(int cmd, int arg)
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
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	UpdateNavHelp();
}

simulated function PlaySFX(String Sound)
{
	`XSTRATEGYSOUNDMGR.PlaySoundEvent(Sound);
}

simulated function OnCancel()
{
	CloseScreen();
}

defaultproperties
{
	//Package = "/ package/gfxInventory/Inventory";

	InventoryListName="inventoryListMC";
	bAnimateOnInit = true;

	OverrideInterpTime = -1;
}