Scriptname SMMAnimationSL Hidden

Function StartSceneSingle(Actor that, String hook) global
  SexLabUtil.QuickStart(that, hook = hook)
EndFunction

int Function StartAnimation(SMMMCM MCM, Actor first, Actor[] partners, int asVictim, string hook = "") Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  If(SL.Enabled == false)
    return -1
  ElseIf(SL.IsValidActor(first) == false)
    return -1
  ELse
    int i = 0
    While(i < partners.length)
      If(SL.IsValidActor(partners[i]) == false)
        return -1
      EndIf
      i += 1
    EndWhile
  EndIf
  Actor victim = none
  If(asVictim == 1)
    victim = first
  EndIf
  Actor[] others = SL.SortActors(PapyrusUtil.PushActor(partners, first))
  int fg = SL.GetGender(first)
  sslBaseAnimation[] anims
	bool breakLoop = false
	While(!breakLoop)
		If(fg > 1) ; Creature
	    anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[10])
	  ElseIf(others.length == 2)
	    int males = SL.MaleCount(others)
	    If(fg == 1 && males > 0) ; Female first & Male Partner
	      anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[0])
	    else ; male count is now 0 for lesbian; 2 for gay or 1 for male first & female partner
	      anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[males + 1])
	    EndIf
	  else ; Array Entry (4/5) for 3, (6/7) for 4 or (8/9) for 5
	    anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[(others.length * 2) - (1 + fg)])
	  EndIf
		If(anims.Length)
			breakLoop = true
		ElseIf(others.length < 2)
			return -1
		else
			others = PapyrusUtil.RemoveActor(others, others[0])
		EndIf
	EndWhile
  ; Start Scene
  return SL.StartSex(others, anims, victim, hook = hook)
EndFunction


int Function GetActorType(Actor subject) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  int sex = SL.GetGender(subject)
  If (sex > 2)
    sex += 1
  ElseIf (sex == 2)
    If(Game.GetModByName("Schlongs of Skyrim.esp") != 255)
      Faction schlongified = Game.GetFormFromFile(0x00AFF8, "Schlongs of Skyrim.esp") as Faction
      sex += subject.IsInFaction(schlongified) as int
    EndIf
  EndIf
  return sex
EndFunction

int Function GetArousal(Actor that) global
  slaFrameworkScr SLA = Quest.GetQuest("sla_Framework") as slaFrameworkScr
  return SLA.GetActorArousal(that)
EndFunction

bool Function IsAnimating(Actor subject) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  return SL.FindActorController(subject) > -1
EndFunction

bool Function StopAnimating(Actor subject, int tid = -1) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  if (tid == -1)
    tid = SL.FindActorController(subject)
    if (tid == -1)
      Debug.Trace("[SMM] Actor = " + subject + " is not part of any SL Animation.")
      return false
    endif
  endif
  sslThreadController controller = SL.GetController(tid)
  if (!controller)
    Debug.Trace("[SMM] Actor = " + subject + " is not part of any SL Animation.")
    return false
  endif
  controller.EndAnimation()
  return true
EndFunction