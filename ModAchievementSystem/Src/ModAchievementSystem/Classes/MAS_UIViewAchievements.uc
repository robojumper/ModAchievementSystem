// TODO: This should be refactored to one class
class MAS_UIViewAchievements extends UIScreen;

struct AchievementGroup
{
	var int iTotalPoints;
	var int iGottenPoints;
	var int iTotalAchievements;
	var int iGottenAchievements;
	var string strCategoryName;
	var array<MAS_X2AchievementTemplate> Achievements;

	// keep track if we are collapsed, i.e. only show the header, not the whole list
	var bool bCollapsed;

	var UIInventory_HeaderListItem CachedHeaderListItem;
};

var localized string m_strTitle;
var localized string m_strSubTitleTitle;
var localized string m_strInventoryLabel;
var localized string m_strPoints;

var array<AchievementGroup> GroupsCache;

var array<MAS_X2AchievementTemplate> m_arrAchievements;

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
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

simulated function PopulateData()
{
	local MAS_X2AchievementTemplate Template;
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

}

/*
simulated function OnHeaderMouseEvent(UIPanel Control, int cmd)
{
	local int i;
	if(cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
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
}
*/


function bool OnInfoClicked(int iOption)
{
	// TODO
	return false;
}


simulated function GetItems()
{

	local string cachedCategory;
	//local int number, totalAchievements, gottenAchievements, totalPoints, gottenPoints;
	local MAS_X2AchievementTemplate Ach;
	local AchievementGroup group;
	
	m_arrAchievements = GetAchievements(true); // get all, filter after
	SortItems();

	cachedCategory = m_arrAchievements[0].strCategory;
	group.strCategoryName = m_arrAchievements[0].strCategory;
	foreach m_arrAchievements(Ach)
	{
		if (cachedCategory != Ach.strCategory)
		{
			// finish group and create new one
			`log("New Category:" @ Ach.strCategory);
			GroupsCache.AddItem(group);
			group = GetEmptyGroup();
			group.strCategoryName = Ach.strCategory;
			cachedCategory = Ach.strCategory;
		}
		group.iTotalAchievements += 1;
		group.iGottenAchievements += (Ach.IsUnlocked() ? 1 : 0);
		group.iTotalPoints += Ach.iPoints;
		group.iGottenPoints += (Ach.IsUnlocked() ? Ach.iPoints : 0);
		if (Ach.IsUnlocked() || !Ach.bHidden) {
			group.Achievements.AddItem(Ach);
		}
		`log("Added Ach:" @ Ach.DataName);
		
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

static function int SortByPoints(MAS_X2AchievementTemplate A, MAS_X2AchievementTemplate B)
{
	return A.iPoints > B.iPoints ? -1 : 0;
}

static function int SortByEnabled(MAS_X2AchievementTemplate A, MAS_X2AchievementTemplate B)
{
	return (!A.IsUnlocked() && B.IsUnlocked()) ? -1 : 0;
}

static function int SortByHidden(MAS_X2AchievementTemplate A, MAS_X2AchievementTemplate B)
{
	return (!A.bHidden && B.bHidden) ? -1 : 0;
}

static function int SortByCategory(MAS_X2AchievementTemplate A, MAS_X2AchievementTemplate B)
{
	return A.strCategory > B.strCategory ? -1 : 0;
}

simulated function bool ShouldShowGoodState(int index)
{
	return m_arrAchievements[index].IsUnlocked();
}

simulated function bool ShouldShowItemDisabledState(int index)
{
	return !m_arrAchievements[index].IsUnlocked();
}

simulated function int GetItemIndex(MAS_X2AchievementTemplate Item)
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
simulated function array<MAS_X2AchievementTemplate> GetAchievements(bool bGetHidden)
{
	//local MAS_X2AchievementTemplate Template;
	local array<MAS_X2AchievementTemplate> AchTemplates;

	class'MAS_X2AchievementHelpers'.static.GetAllAchievementTemplates(AchTemplates, bGetHidden);
	return AchTemplates;
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

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
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
	Package = "/ package/gfxInventory/Inventory";

	InventoryListName="inventoryListMC";
	bAnimateOnInit = true;
	
	InputState = eInputState_Consume;
	m_bShowButton = false
	bHideOnLoseFocus = true;
	m_eMainColor = eUIState_Normal
}
