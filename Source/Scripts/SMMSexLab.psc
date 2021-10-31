Scriptname SMMSexLab Hidden

int Function getActorType(Actor me) global
  int mySLGender = SexLabUtil.GetAPI().GetGender(me)
  If(mySLGender == 3) ;Female Creature
    return 4
  ElseIf(mySLGender == 2) ;Male Creature
    return 3
  Else ;Humanoid
    int myVanillaGender = me.GetLeveledActorBase().GetSex()
    If(myVanillaGender == mySLGender) ;Either male or female
      return myVanillaGender
    Else ;Futa
      return 2
    EndIf
  EndIf
EndFunction

int Function GetArousal(Actor that) global
  slaFrameworkScr SLA = Quest.GetQuest("sla_Framework") as slaFrameworkScr
  return SLA.GetActorArousal(that)
EndFunction

int Function stopAnimation(Actor that) Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  int sol = SL.FindActorController(that)
  If(sol != -1)
    SL.GetController(sol).EndAnimation()
  EndIf
  return sol
EndFunction

; ======================================================================
; ================================== ANIMATION
; ======================================================================
Function StartSceneSingle(Actor that, String hook) global
  SexLabUtil.QuickStart(that, hook = hook)
EndFunction

int Function StartAnimation(SMMMCM MCM, Actor first, Actor[] others, int asVictim, string hook = "") Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  If(SL.Enabled == false)
    return -1
  ElseIf(SL.IsValidActor(first) == false)
    return -1
  ELse
    int i = 0
    While(i < others.length)
      If(SL.IsValidActor(others[i]) == false)
        return -1
      EndIf
      i += 1
    EndWhile
  EndIf
  Actor victim = none
  If(asVictim == 1)
    victim = first
  EndIf
  others = SL.SortActors(PapyrusUtil.PushActor(others, first))
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
		If(anims)
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
