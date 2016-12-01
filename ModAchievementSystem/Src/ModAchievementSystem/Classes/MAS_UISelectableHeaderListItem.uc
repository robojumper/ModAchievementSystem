class MAS_UISelectableHeaderListItem extends UIInventory_HeaderListItem;

var string strIcon, strHeader, strSubHeader;

simulated function PopulateData(string IconPath, string HeaderText, string SubHeaderText)
{
	if (IconPath != "")
		strIcon = IconPath;
	
	if (HeaderText != "")
		strHeader = HeaderText;
	
	if (SubHeaderText != "")
		strSubHeader = SubHeaderText;
	
	SetData(strIcon, strHeader, strSubHeader);
}

simulated function SetData(string IconPath, string HeaderText, string SubHeaderText)
{
	MC.BeginFunctionOp("populateData");
	MC.QueueString(IconPath);
	MC.QueueString(HeaderText);
	MC.QueueString(SubHeaderText);
	MC.EndOp();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	SetData(class'UIUtilities_Image'.const.LootIcon_Objectives, "     " @ strHeader, strSubHeader);
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	SetData(strIcon, strHeader, strSubHeader);
}

defaultproperties
{
	bProcessesMouseEvents = true
}