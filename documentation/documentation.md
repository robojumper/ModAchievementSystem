# Documentation

## ModBuddy Setup

Supporting Achievements is a twofold thing.

### Registering Achievements

#### Configuration

This is done via an .ini file. Create a file named ```XComModAchievementSystem.ini``` in your Mod's ```Config``` Folder.

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

##### Progression Achievements

Progression Achievements are achievements that show progress on their short Description.

They can either be completely cosmetic and regularly re-set to the accurate number, or unlock automatically when the required progress is met.

```
iTotalProgressRequired=3
bNoAutoUnlock=true
bNoCapForProgression=false
```

An achievement will be considered a progression achievement when ```iTotalProgressRequired > 0```.

If ```bNoAutoUnlock``` is true, the counter will just go up and not unlock the achievement automatically - you have to unlock it manually.

If ```bNoCapForProgression``` is true, there can be descriptions like "Kill Sectoids (7/3)". If it is false, the number will be capped at max.

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

In your ```Src``` folder, create a folder called ```LW_Tuple```. In there, create a folder called ```Classes```.

In this folder, create a new UnrealScript called ```LWTuple.uc```. Content as follows.

[LWTuple.uc](https://github.com/robojumper/ModAchievementSystem/blob/master/ModAchievementSystem/Src/LW_Tuple/Classes/LWTuple.uc)

Then open your ```Config/XComEngine.ini```

if not already present, create the section

```
[UnrealEd.EditorEngine]
```

and add 

```
+EditPackages=LW_Tuple
```

below it. This tells the compiler to use this Information Exchange class.

## Unlocking Achievements.

You can unlock achievements via some simple lines:

```
local LWTuple AchTuple;
local LWTValue Value;
// ...

AchTuple = new class'LWTuple'; 
AchTuple.Id = 'AchievementData'; // Must be this name

// First entry: Achievement Name.
Value.kind = LWTVName;
Value.n = 'MyAchievementName';
AchTuple.Data.AddItem(Value);

// Second Entry: Command
Value.kind = LWTVName;
Value.n = 'UnlockAchievement';
AchTuple.Data.AddItem(Value);

`XEVENTMGR.TriggerEvent('UnlockAchievement', AchTuple, , );
```

That's all. People will see a popup and the achievement will be added to the unlocked list.

You don't need to worry about unlocking an achievement multiple times. Just trigger it, users will only see a popup the first time you trigger it.

## Progression Achievements

This short schematic outlines the commands my achievement mod can react to.

```
Data[0] = (kind=LWTVName, n='AchievementName') // Achievement name
	Data[1] = (kind=LWTVName, n='UnlockAchievement') // unlock this achievement
	Data[1] = (kind=LWTVName, n='ProgressByNumber')  // increase progress on this achievement
		Data[2] = (kind=LWTVInt, i=pointsToProgress) // the amount of points to add (maybe negative?)
	Data[1] = (kind=LWTVName, n='SetProgress') // overwrite progress on this achievement
		Data[2] = (kind=LWTVInt, i=NewProgress) // the new progress number
```

What does this mean?

```
local LWTuple AchTuple;
local LWTValue Value;

AchTuple = new class'LWTuple';
AchTuple.Id = 'AchievementData';

Value.kind = LWTVName;
Value.n = 'MyProgressionAchievement';
AchTuple.Data.AddItem(Value);

Value.kind = LWTVName;
Value.n = 'ProgressByNumber';
AchTuple.Data.AddItem(Value);

Value.kind = LWTVInt;
Value.i = 1;
AchTuple.Data.AddItem(Value);

`XEVENTMGR.TriggerEvent('UnlockAchievement', AchTuple, , );
```

In this code, we add 1 point of progression to the achievement ```MyProgressionAchievement```. Remember - if ```bNoAutoUnlock = true```, you need to unlock it manually.


## Your completely own achievement

The above code describes MAS' built-in achievement mechanics. You can always create your own achievements, with custom conditions, custom display, everything.

To do that, you need to add two packages: `LWTuple` and `AchievementInterface`

Compiler Setup is similar to LWTuple for AchievementInterface - the former is linked above, the latter file is here:

[MAS_X2AchievementBase.uc](https://github.com/robojumper/ModAchievementSystem/blob/master/ModAchievementSystem/Src/AchievementInterface/Classes/MAS_X2AchievementBase.uc)

Extend this class, and add templates created from your subclass to the `X2StrategyElementTemplateManager` in order to have them picked up.

Let's take a look at the methods to implement:

* IsUnlocked() - whether this achievement will be highlighted green in the list, and shown at the top.
* ShouldShow() - whether this achievement will get a position on the list. If not, it counts towards points and completion, but doesn't show
* GetPoints() - points to calculate completion rates. Also shown in the list and in popups
* GetTitle() - card+item title
* GetShortDesc() - item description
* GetLongDesc() - card description
* GetCategory() - shown in list item headers. Used to calculate completions
* GetSmallImagePath() - item image. 64x64
* GetWideImagePathStack() - stack of card images. should be created at 560x315, and then scaled to 512x256 for importing. Max. 9
* Reset() - reset this achievement to 0
* IsAuxiliaryAchievement() - this achievement doesn't count, it can only be used as a popup message.


Showing popup messages happens via an LWTuple:

```
local LWTuple SendTuple;
local LWTValue Val;

SendTuple = new class'LWTuple';
SendTuple.Id = 'AchievementMessage';

Val.kind = LWTVName;
Val.n = 'MyAchievementTemplate';
SendTuple.Data.AddItem(Val);

`XEVENTMGR.TriggerEvent('ShowAchievementMessage', SendTuple);

```