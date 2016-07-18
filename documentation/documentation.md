# Documentation

## ModBuddy Setup

Supporting Achievements is a twofold thing.

### Registering Achievements

#### Configuration

This is done via an .ini file. Create a file named ```XComModAchievementSystem.ini``` in your Mod's ```Content``` Folder.

In there, you have to create two sections. This is what an example Achievement looks like:

```
[ModAchievementSystem.MAS_X2Achievement_ModAchievements]
+AchievementNames="MAS_TestAchievement"

[MAS_TestAchievement MAS_X2AchievementTemplate]
strImage_Disabled="img:///UILibrary_MAS.Icon_Achievement_Locked"
strImage_Enabled="img:///UILibrary_MAS.Icon_Achievement_Unlocked"
strImage_WideEnabled="img:///UILibrary_MAS.Icon_Unlocked_Wide"
strImage_WideDisabled="img:///UILibrary_MAS.Icon_Locked_Wide"
iPoints=10
bHidden=false
```

The name ```MAS_TestAchievement``` is a template name, which means **under no circumstances** should it be the same as a different template, such as ```AssaultRifle_CV```.

Notice how the Template Name corresponds to the header in line 3.

A good way to avoid conflicts is to prefix this with something like your Mod's initials + Achievement.

The four images are fallback images you can use in case you lack artistic talent. I might update these images in the future.

The points are used for completion calculation and give your users a good impression on what Achievements are easy, difficult and so on.

You can choose to hide spoiler achievements - they will not show up until you unlock them.

#### Localization

To give your achievements unique names, you need to add a localization file. Create a file called ```ModAchievementSystem.int``` in your Mod's ```Localization``` folder.

In there, one section for each Achievement.

```
[MAS_TestAchievement MAS_X2AchievementTemplate]
strTitle=Cheated.
strShortDesc=You dirty cheater.
strLongDesc=You successfully unlocked this achievement via a console command. Hoorayy!
strCategory=Test Achievements
```

```strCategory``` is used to logically group achievements. Do not create groups for one or two achievements. If you don't plan on adding a lot of achievements, use one group for all your mods.

### Compiler Setup

In your ```Src``` folder, create a folder called ```ModAchievementSystemAPI```. In there, create a folder called ```Classes```.

In this folder, create a new UnrealScript called ```MAS_API_AchievementName.uc```. Content as follows.

```
class MAS_API_AchievementName extends Object;

var name AchievementName;
```

Then open your ```Config/XComEngine.ini```

if not already present, create the section

```
[UnrealEd.EditorEngine]
```

and add 

```
+EditPackages=ModAchievementSystemAPI
```

below it. This tells the compiler to use this intermediary Information Exchange class.

## Unlocking Achievements.

You can unlock achievements via some simple lines:

```
local MAS_API_AchievementName AchNameObj;

// ...

AchNameObj = new class'MAS_API_AchievementName'; 
AchNameObj.AchievementName = 'MAS_GrimyLootRare'; // YOUR ACHIEVEMENT TEMPLATE NAME
`XEVENTMGR.TriggerEvent('UnlockAchievement', AchNameObj, , NewGameState);
```

That's all. People will see a popup and the achievement will be added to the unlocked list.