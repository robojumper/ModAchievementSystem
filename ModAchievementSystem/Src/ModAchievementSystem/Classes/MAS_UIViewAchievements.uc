class MAS_UIViewAchievements extends UIScreen;

struct AchievementGroup
{
	var int iTotalPoints;
	var int iGottenPoints;
	var int iTotalAchievements;
	var int iGottenAchievements;
	var string strCategoryName;
	var array<MAS_X2AchievementBase> Achievements;

	// keep track if we are collapsed, i.e. only show the header, not the whole list
	var bool bCollapsed;

	var UIInventory_HeaderListItem CachedHeaderListItem;
};

var localized string m_strTitle;
var localized string m_strSubTitleTitle;
var localized string m_strInventoryLabel;
var localized string m_strPoints;

var array<AchievementGroup> GroupsCache;

var array<MAS_X2AchievementBase> m_arrAchievements;

//var array<Commodity>		arrItems;
var int						iSelectedItem;
//var array<StateObjectReference> m_arrRefs;

var bool		m_bShowButton;
var bool		m_bInfoOnly;
var EUIState	m_eMainColor;


var UIX2PanelHeader TitleHeader;

var MAS_UIAchievementCard ItemCard;

var UIPanel ListContainer; // contains all controls below
var UIList List;
var UIPanel ListBG;

var name InventoryListName;

// press B to back
// press A to collapse expand selected
// press X to expand all / collapse all
// press Y to reset all
var UINavigationHelp NavHelp;

// true = all will be collapsed on next click
// false = all will be collapsed on next click
var bool bToggle;

//-------------- EVENT HANDLING --------------------------------------------------------
simulated function OnChildClicked(UIList kList, int itemIndex)
{
	local int i;
	local UIPanel Control;

	if (itemIndex != iSelectedItem)
	{
		iSelectedItem = itemIndex;
	}

	Control = kList.GetItem(iSelectedItem);

	for (i = 0; i < GroupsCache.Length; i++)
	{
		if (Control == GroupsCache[i].CachedHeaderListItem)
		{
			GroupsCache[i].bCollapsed = !GroupsCache[i].bCollapsed;
			PopulateData();
			return;
		}
	}
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`log("UIViewAchievements Init");
	super.InitScreen(InitController, InitMovie, InitName);
	
	BuildScreen();

	NavHelp = Pc.Pres.m_kNavHelpScreen.NavHelp;

	List.OnItemClicked = OnChildClicked;

	GetItems();
	SetBuiltLabel(m_strPoints);
	
	SetChooseResearchLayout();
	PopulateData();
	
	ItemCard.Hide();
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


	// send mouse scroll events to the list
	ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

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

simulated function PopulateAchievementCard(optional MAS_X2AchievementBase AchievementTemplate)
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


simulated function PopulateData()
{
	local MAS_X2AchievementBase Template;
	local UIInventory_HeaderListItem HeaderItem;
	local int i;
	local string GroupName;
	local AchievementGroup GroupIterator;
	List.ClearItems();
	List.bSelectFirstAvailable = true;
	

	foreach GroupsCache(GroupIterator, i)
	{
		GroupName = GroupIterator.strCategoryName $ ": " $ GroupIterator.iGottenAchievements $ "/" $ GroupIterator.iTotalAchievements $ " - " $ GroupIterator.iGottenPoints $ "/" $ GroupIterator.iTotalPoints @ m_strPoints;
		HeaderItem = Spawn(class'MAS_UISelectableHeaderListItem', List.ItemContainer);
		
		HeaderItem.InitHeaderItem("", GroupName);
		//HeaderItem.ProcessMouseEvents(OnHeaderMouseEvent);
		GroupsCache[i].CachedHeaderListItem = HeaderItem;

		if (GroupIterator.bCollapsed)
		{
			continue;
		}
		foreach GroupIterator.Achievements(Template)
		{
			Spawn(class'MAS_UIAchievementItem', List.itemContainer).InitInventoryListAchievement(Template);
		}
	}

	UpdateNavHelp();

}

simulated function GetItems()
{
	local string cachedCategory;
	//local int number, totalAchievements, gottenAchievements, totalPoints, gottenPoints;
	local MAS_X2AchievementBase Ach;
	local AchievementGroup group;
	
	m_arrAchievements = GetAchievements(true); // get all, filter after
	SortItems();

	cachedCategory = m_arrAchievements[0].GetCategory();
	group.strCategoryName = m_arrAchievements[0].GetCategory();
	foreach m_arrAchievements(Ach)
	{
		if (cachedCategory != Ach.GetCategory())
		{
			// finish group and create new one
			GroupsCache.AddItem(group);
			group = GetEmptyGroup();
			group.strCategoryName = Ach.GetCategory();
			cachedCategory = Ach.GetCategory();
		}
		group.iTotalAchievements += 1;
		group.iGottenAchievements += (Ach.IsUnlocked() ? 1 : 0);
		group.iTotalPoints += Ach.GetPointsMaximum();
		group.iGottenPoints += (Ach.GetPoints());
		if (Ach.ShouldShow()) {
			group.Achievements.AddItem(Ach);
		}
	}
	GroupsCache.AddItem(group);
}

simulated function AchievementGroup GetEmptyGroup()
{
	local AchievementGroup Group;
	return Group;
}

simulated function SortItems()
{
	// should be a stable sorting algoritm
	// so achievements are ordered by category
	// in there by whether they are unlocked
	// and then by points
	m_arrAchievements.Sort(SortByPoints);
	m_arrAchievements.Sort(SortByEnabled);
	m_arrAchievements.Sort(SortByHidden);
	m_arrAchievements.Sort(SortByCategory);
}

static function int SortByPoints(MAS_X2AchievementBase A, MAS_X2AchievementBase B)
{
	return A.GetPoints() > B.GetPoints() ? -1 : 0;
}

static function int SortByEnabled(MAS_X2AchievementBase A, MAS_X2AchievementBase B)
{
	return (!A.IsUnlocked() && B.IsUnlocked()) ? -1 : 0;
}

static function int SortByHidden(MAS_X2AchievementBase A, MAS_X2AchievementBase B)
{
	return (A.ShouldShow() && !B.ShouldShow()) ? -1 : 0;
}

static function int SortByCategory(MAS_X2AchievementBase A, MAS_X2AchievementBase B)
{
	return A.GetCategory() > B.GetCategory() ? -1 : 0;
}

simulated function bool ShouldShowGoodState(int index)
{
	return m_arrAchievements[index].IsUnlocked();
}

simulated function bool ShouldShowItemDisabledState(int index)
{
	return !m_arrAchievements[index].IsUnlocked();
}

simulated function int GetItemIndex(MAS_X2AchievementBase Item)
{
	local int i;

	for(i = 0; i < m_arrAchievements.Length; i++)
	{
		if(m_arrAchievements[i] == Item)
		{
			return i;
		}
	}

	return -1;
}


//This is overwritten in the research archives. 
simulated function array<MAS_X2AchievementBase> GetAchievements(bool bGetHidden)
{
	//local MAS_X2AchievementTemplate Template;
	local array<MAS_X2AchievementBase> AchTemplates;

	class'MAS_X2AchievementHelpers'.static.GetAllAchievementTemplates(AchTemplates, bGetHidden);
	return AchTemplates;
}


simulated function UpdateNavHelp()
{

	if(NavHelp == None)
		NavHelp = Movie.Pres.GetNavHelp();
	if(NavHelp == None)
		NavHelp = Spawn(class'UINavigationHelp',self).InitNavHelp();

	NavHelp.ClearButtonHelp();
	
	NavHelp.bIsVerticalHelp = `ISCONTROLLERACTIVE;

	if (`ISCONTROLLERACTIVE)
	{
		// Add left nav help to show what buttons you can use
		NavHelp.AddLeftHelp("Collapse/Expand", class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_A_X);
		NavHelp.AddLeftHelp("Cancel", class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_B_CIRCLE);
		NavHelp.AddLeftHelp("Collapse/Expand All", class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_X_SQUARE);
		NavHelp.AddLeftHelp("Reset All", class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_Y_TRIANGLE);
	}
	else
	{
		NavHelp.AddCenterHelp("Collapse/Expand All", , ToggleExpandCollapseAll);
		NavHelp.AddCenterHelp("Reset All", , OnResetAll);
	}
	NavHelp.Show();
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
			CloseScreen();
			break;
		case class'UIUtilities_Input'.const.FXS_BUTTON_X:
			ToggleExpandCollapseAll();
			break;
		case class'UIUtilities_Input'.const.FXS_BUTTON_Y:
			OnResetAll();
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

simulated function ToggleExpandCollapseAll()
{
	local int i;
	bToggle = !bToggle;
	for (i = 0; i < GroupsCache.Length; i++)
	{
		GroupsCache[i].bCollapsed = bToggle;
	}
	PopulateData();
}

function OnResetAll() 
{
	local TDialogueBoxData      kDialogData;


	kDialogData.eType = eDialog_Warning;
	kDialogData.strText = "This will irreversably reset all Achievement Data!"; 
	kDialogData.fnCallback = ResetAllAchCallback;

	kDialogData.strTitle = "Reset Achievements";
	kDialogData.strAccept = class'UIUtilities_text'.default.m_strGenericConfirm; 
	kDialogData.strCancel = class'UIUtilities_text'.default.m_strGenericCancel; 

	Movie.Pres.UIRaiseDialog( kDialogData );
}

simulated public function ResetAllAchCallback(eUIAction eAction)
{
	local int i;
	if (eAction == eUIAction_Accept)
	{
		Movie.Pres.PlayUISound(eSUISound_MenuSelect);
		// DELETE ALL
		for (i = 0; i < m_arrAchievements.Length; i++)
		{
			m_arrAchievements[i].Reset();
		}
		PopulateData();
	}
	else if( eAction == eUIAction_Cancel )
	{
		Movie.Pres.PlayUISound(eSUISound_MenuClose);
	}
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

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	UpdateNavHelp();
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();

	NavHelp.ClearButtonHelp();
}

simulated function CloseScreen()
{

	NavHelp.ClearButtonHelp();
	super.CloseScreen();	
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
	bConsumeMouseEvents=true;
	InputState = eInputState_Consume;
	m_bShowButton = false
	bHideOnLoseFocus = true;
	m_eMainColor = eUIState_Normal
}
