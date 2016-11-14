class MAS_UIAchievementCard extends UIPanel;


simulated function MAS_UIAchievementCard InitAchievementCard(optional name InitName)
{
	InitPanel(InitName);
	return self;
}


simulated function PopulateAchievementCard(optional MAS_X2AchievementTemplate AchTemplate)
{

	local string strShortDesc, strLongDesc, strTitle;
	if( AchTemplate == None )
	{
		Hide();
		return;
	}

	//bWaitingForImageUpdate = false;
	strTitle = class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(AchTemplate.GetTitle()), eUIState_Header, 24);
	strLongDesc = class'UIUtilities_Text'.static.GetColoredText(AchTemplate.GetLongDesc(), eUIState_Normal, 18);
	strShortDesc = class'UIUtilities_Text'.static.GetColoredText(AchTemplate.GetShortDesc(), eUIState_Normal, 24);
	
	PopulateData(strTitle, strLongDesc, strShortDesc, "");
	SetAchievementImage(AchTemplate);
	PopulateCost(AchTemplate.iPoints);
}


simulated function SetAchievementImage(optional MAS_X2AchievementTemplate AchTemplate)
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
