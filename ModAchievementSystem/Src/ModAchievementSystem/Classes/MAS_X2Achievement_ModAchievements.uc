class MAS_X2Achievement_ModAchievements extends X2StrategyElement config(ModAchievementSystem);

var config array<name> AchievementNames;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Achievements;
	local MAS_X2AchievementTemplate Template;
	local Name Ach;

	`log("MAS -- Adding Mod Achievements");
	foreach default.AchievementNames(Ach)
	{
		Template = new(None, string(Ach)) class'MAS_X2AchievementTemplate';
		Template.SetTemplateName(Ach);
		Achievements.AddItem(Template);
	}
	return Achievements;
}