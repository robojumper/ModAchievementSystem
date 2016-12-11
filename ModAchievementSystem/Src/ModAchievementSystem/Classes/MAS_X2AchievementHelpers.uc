class MAS_X2AchievementHelpers extends Object;

static function bool AddAchievementTemplate(MAS_X2AchievementBase Template, bool ReplaceDuplicate = false)
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().AddStrategyElementTemplate(Template, ReplaceDuplicate);
}

static function MAS_X2AchievementBase FindAchievementTemplate(Name DataName)
{
	local X2StrategyElementTemplate AchievementTemplate;

	AchievementTemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(DataName);

	if( AchievementTemplate != None )
	{
		return MAS_X2AchievementBase(AchievementTemplate);
	}

	return None;
}

static function GetAllAchievementTemplates(out array<MAS_X2AchievementBase> Achievements, optional bool bGetHidden = true)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2DataTemplate Template;
	local MAS_X2AchievementBase AchievementTemplate;
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach TemplateManager.IterateTemplates(Template, none)
	{
		AchievementTemplate = MAS_X2AchievementBase(Template);
		// add if unlocked, or not hidden, or we ignored whether it is hidden
		// also, it must not be an auxiliary achievement (dedicated popup message)
		if(AchievementTemplate != none  && !AchievementTemplate.IsAuxiliaryAchievement() && (AchievementTemplate.ShouldShow() || bGetHidden))
		{
			Achievements.AddItem(AchievementTemplate);
		}
	}
}