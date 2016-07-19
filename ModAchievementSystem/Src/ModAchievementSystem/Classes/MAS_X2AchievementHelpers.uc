class MAS_X2AchievementHelpers extends Object;

static function bool AddAchievementTemplate(MAS_X2AchievementTemplate Template, bool ReplaceDuplicate = false)
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().AddStrategyElementTemplate(Template, ReplaceDuplicate);
}

static function MAS_X2AchievementTemplate FindAchievementTemplate(Name DataName)
{
	local X2StrategyElementTemplate AchievementTemplate;

	AchievementTemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(DataName);

	if( AchievementTemplate != None )
	{
		return MAS_X2AchievementTemplate(AchievementTemplate);
	}

	return None;
}

static function GetAllAchievementTemplates(out array<MAS_X2AchievementTemplate> Achievements, optional bool bGetHidden = true)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2DataTemplate Template;
	local MAS_X2AchievementTemplate AchievementTemplate;
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach TemplateManager.IterateTemplates(Template, none)
	{
		AchievementTemplate = MAS_X2AchievementTemplate(Template);

		if(AchievementTemplate != none && (AchievementTemplate.IsUnlocked() || !AchievementTemplate.bHidden))
		{
			Achievements.AddItem(AchievementTemplate);
		}
	}

}

static function bool IsAchievementUnlocked(name AchievementName)
{
	local bool unlocked;
	unlocked = class'MAS_PersistentAchievementStorage'.default.UnlockedAchievements.Find(AchievementName) != INDEX_NONE;
	//`log("Achievement" @ AchievementName @ "is" @ unlocked);
	return unlocked;
	
}