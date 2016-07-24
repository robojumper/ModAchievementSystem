class MAS_UIViewAchievements extends MAS_UIInventory;

struct AchievementGroup
{
	var int iTotalPoints;
	var int iGottenPoints;
	var int iTotalAchievements;
	var int iGottenAchievements;
	var string strCategoryName;
	var array<MAS_X2AchievementTemplate> Achievements;
};

var localized string m_strPoints;

var array<AchievementGroup> GroupsCache;

var array<MAS_X2AchievementTemplate> m_arrAchievements;

//var array<Commodity>		arrItems;
var int						iSelectedItem;
//var array<StateObjectReference> m_arrRefs;

var bool		m_bShowButton;
var bool		m_bInfoOnly;
var EUIState	m_eMainColor;

var public localized String m_strBuy;


//-------------- EVENT HANDLING --------------------------------------------------------
simulated function OnPurchaseClicked(UIList kList, int itemIndex)
{
	if (itemIndex != iSelectedItem)
	{
		iSelectedItem = itemIndex;
	}

	/*if (CanAffordItem(iSelectedItem))
	{
		OnInfoClicked(iSelectedItem);
			//Movie.Stack.Pop(self);
		//UpdateData();
	}*/
	else
	{
		class'UIUtilities_Sound'.static.PlayNegativeSound();
	}
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`log("UIViewAchievements Init");
	super.InitScreen(InitController, InitMovie, InitName);
	
	// Move and resize list to accommodate label
	List.OnItemDoubleClicked = OnPurchaseClicked;

	GetItems();
	SetBuiltLabel("Points");
	
	SetChooseResearchLayout();
	PopulateData();
	//MC.FunctionVoid("onPopulateDebugData");
	
	ItemCard.Hide();
}

simulated function PopulateData()
{
	local MAS_X2AchievementTemplate Template;
	//local int i;
	local string GroupName;
	local AchievementGroup GroupIterator;
	List.ClearItems();
	List.bSelectFirstAvailable = false;
	
	//
	/*for(i = 0; i < m_arrAchievements.Length; i++)
	{
		Template = m_arrAchievements[i];
		if (cachedCategory != Template.strCategory)
		{
			Spawn(class'UIInventory_HeaderListItem', List.ItemContainer).InitHeaderItem("", Template.strCategory);
			cachedCategory = Template.strCategory;
		}
		Spawn(class'MAS_UIAchievementItem', List.itemContainer).InitInventoryListAchievement(Template);
	}*/
	foreach GroupsCache(GroupIterator)
	{
		GroupName = GroupIterator.strCategoryName $ ": " $ GroupIterator.iGottenAchievements $ "/" $ GroupIterator.iTotalAchievements $ " - " $ GroupIterator.iGottenPoints $ "/" $ GroupIterator.iTotalPoints @ m_strPoints;
		Spawn(class'UIInventory_HeaderListItem', List.ItemContainer).InitHeaderItem("", GroupName);
		foreach GroupIterator.Achievements(Template)
		{
			Spawn(class'MAS_UIAchievementItem', List.itemContainer).InitInventoryListAchievement(Template);
		}
	}

}


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
	
	m_arrAchievements = GetAchievements(false); // don't get hidden ones
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
		group.Achievements.AddItem(Ach);
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
	// so mods are ordered by category
	// in there by whether they are unlocked
	// and then by points
	m_arrAchievements.Sort(SortByPoints);
	m_arrAchievements.Sort(SortByEnabled);
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

static function int SortByCategory(MAS_X2AchievementTemplate A, MAS_X2AchievementTemplate B)
{
	return A.strCategory > B.strCategory ? -1 : 0;
}

simulated function String GetButtonString(int ItemIndex)
{
	return m_strBuy;
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

defaultproperties
{
	InputState = eInputState_Consume;
	m_bShowButton = false
	bHideOnLoseFocus = true;
	m_eMainColor = eUIState_Normal
}
