class MAS_UIAchievementCard extends UIPanel config(ModAchievementSystem);

var config int iXScale;
var config int iYScale;
var config int iXOffset;

simulated function MAS_UIAchievementCard InitAchievementCard(optional name InitName)
{
	InitPanel(InitName);
	
	return self;
}

simulated function PopulateAchievementCard(optional MAS_X2AchievementBase AchTemplate)
{

	local string strLongDesc, strTitle;
	//local string strShortDesc;

	if( AchTemplate == None )
	{
		Hide();
		return;
	}

	strTitle = class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(AchTemplate.GetTitle() $ " - " $ AchTemplate.GetPoints() @ class'MAS_UIViewAchievements'.default.m_strPoints), eUIState_Header, 24);
	/*strLongDesc = class'UIUtilities_Text'.static.GetColoredText(AchTemplate.GetLongDesc(), eUIState_Normal, 18);
	strShortDesc = class'UIUtilities_Text'.static.GetColoredText(AchTemplate.GetShortDesc(), eUIState_Normal, 24);*/
	//strTitle = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(AchTemplate.GetTitle());
	strLongDesc = AchTemplate.GetLongDesc();
	//strShortDesc = AchTemplate.GetShortDesc();

	PopulateData(strTitle, "", strLongDesc, "");
	SetAchievementImage(AchTemplate);
	//PopulateCost(AchTemplate.GetPoints());
}


simulated function SetAchievementImage(optional MAS_X2AchievementBase AchTemplate)
{
	local array<string> Images;
	local int i;

	if (AchTemplate != none)
	{
		Images = AchTemplate.GetWideImagePathStack();
	}

	MC.BeginFunctionOp("SetImageStack");
	for (i = 0; i < Images.Length; i++)
	{
		MC.QueueString(Images[i]);
	}
	MC.EndOp();
	
	// This fixes the smaller size of imagestacks
	// Calculations in the config file
	MC.ChildSetNum("WeaponImageSet", "_xscale", iXScale);
	MC.ChildSetNum("WeaponImageSet", "_yscale", iYScale);
	MC.ChildSetNum("WeaponImageSet", "_x", iXOffset);
	
}

simulated function PopulateData(string Title, string LongDesc, string ShortDesc, string ImagePath)
{
	mc.BeginFunctionOp("PopulateData");
	mc.QueueString(Title);
	
	
	mc.QueueString(ShortDesc $"\n" $ LongDesc);
	
	mc.QueueString(ImagePath);
	mc.EndOp();

	Show();
}

/*
simulated function PopulateCost(int Points) {
	local int offset;
	
//	mc.ChildSetBool("description", "hasScrollbar", true);

	mc.BeginFunctionOp("PopulateCostData");
	mc.QueueString(class'MAS_UIViewAchievements'.default.m_strPoints);
	mc.QueueString(string(Points));
	mc.QueueString("");
	mc.QueueString("");
	mc.QueueString("");
	mc.EndOp();

	offset = 0;

	offset += int(mc.GetNum("title._y"));
	offset += int(mc.GetNum("title._height"));
	offset += 70;

	// issue: the displaced control makes the card think it needs to scroll,
	// but our corrected one does not need to do that
	// card still scrolls :/
	`log("textHeightBefore:" @ mc.GetNum("description.textfield.textHeight"));
	`log("maskHeightBefore:" @ mc.GetNum("description.mask._height"));
	mc.ChildSetNum("description", "_y", offset);
	offset = int(mc.GetNum("costValue._y"));
	offset += int(mc.GetNum("costValue.textHeight"));
	offset += 10;
	mc.ChildFunctionNum("description", "setMaskHeight", int(mc.GetNum("bg._y")) + int(mc.GetNum("bg._height")) - offset - 10);

	/*if (mc.GetNum("description.textfield.textHeight") > mc.GetNum("description.mask._height"))
	{
		mc.ChildSetBool("description", "hasScrollbar", false);
		mc.ChildFunctionVoid("description", "ResetScroll");
	}*/
	`log("textHeightAfter:" @ mc.GetNum("description.textfield.textHeight"));
	`log("maskHeightAfter:" @ mc.GetNum("description.mask._height"));

	//mc.ChildFunctionVoid("description", "EnableScrollbar");
}*/

defaultproperties
{
	LibID = "X2ItemCard";
}
