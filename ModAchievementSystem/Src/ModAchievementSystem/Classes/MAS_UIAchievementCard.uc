class MAS_UIAchievementCard extends UIPanel;


simulated function MAS_UIAchievementCard InitAchievementCard(optional name InitName)
{
	InitPanel(InitName);
	`log("An Achievement Card has been inited");
	//History = `XCOMHISTORY;
	return self;
}


simulated function PopulateAchievementCard(optional MAS_X2AchievementTemplate AchTemplate)
{

	local string strShortDesc, strLongDesc, strTitle;
	//`log("I AM THE CARD");
	if( AchTemplate == None )
	{
		Hide();
		return;
	}

	//bWaitingForImageUpdate = false;
	strTitle = class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(AchTemplate.strTitle), eUIState_Header, 24);
	strLongDesc = class'UIUtilities_Text'.static.GetColoredText(AchTemplate.strLongDesc, eUIState_Normal, 18);
	strShortDesc = class'UIUtilities_Text'.static.GetColoredText(AchTemplate.strShortDesc, eUIState_Normal, 24);
	
	PopulateData(strTitle, strLongDesc, strShortDesc, "");
	SetAchievementImage(AchTemplate);
	PopulateCost(AchTemplate.iPoints);
}


simulated function SetAchievementImage(optional MAS_X2AchievementTemplate AchTemplate)
{
	local string Image;
	//`log("I CAN SHOW MY IMAGE");
	if (AchTemplate != none)
	{
		Image = AchTemplate.GetWideImagePath();
	}

	MC.BeginFunctionOp("SetImageStack");
	MC.QueueString(Image);
	MC.EndOp();

}

simulated function PopulateData(string Title, string LongDesc, string ShortDesc, string ImagePath)
{
	//`log("I CAN POPULATE");
	mc.BeginFunctionOp("PopulateData");
	mc.QueueString(Title);
	
	
	mc.QueueString(ShortDesc $"\n" $ LongDesc);
	
	mc.QueueString(ImagePath);
	mc.EndOp();

	Show();
}

simulated function PopulateCost(int Points) {
	mc.BeginFunctionOp("PopulateCostData");
	mc.QueueString("");
	mc.QueueString("");
	mc.QueueString(class'MAS_UIViewAchievements'.default.m_strPoints);
	mc.QueueString(string(Points));
	mc.EndOp();

}

defaultproperties
{
	LibID = "X2ItemCard";
}
