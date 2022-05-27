Scriptname SMMAnimation Hidden


bool Function hasCreatures(Actor that, Actor[] them) global
  Keyword ActorTypeNPC = Keyword.GetKeyword("ActorTypeNPC")
  If(that.HasKeyword(ActorTypeNPC))
    int i = 0
    While(i < them.length)
      If(!them[i].HasKeyword(ActorTypeNPC))
        return true
      EndIf
      i += 1
    EndWhile
    return false
  EndIf
  return true
EndFunction

; ======================================================================
; ================================== ANIMATION
; ======================================================================
; Start 1p Animation
; Return 0 for SL, 1 for OStim, -1 for Failure
int Function StartAnimationSingle(SMMMCM MCM, Actor that, String hook = "") global
  int sol = -1
  If(!that.HasKeyword(Keyword.GetKeyword("ActorTypeNPC")))
    If(MCM.bSLAllowed)
			SMMAnimationSL.StartSceneSingle(that, hook)
      sol = 0
		EndIf
  ElseIf(MCM.bSLAllowed)
    If(MCM.bOStimAllowed && (MCM.bCrtOnly || Utility.RandomInt(0, 1) == 0))
      SMMAnimationOStim.StartSceneSingle(that)
      sol = 1
    Else
      SMMAnimationSL.StartSceneSingle(that, hook)
      sol = 0
    EndIf
  ElseIf(MCM.bOStimAllowed)
    SMMAnimationOStim.StartSceneSingle(that)
    sol = 1
  EndIf
  return sol
EndFunction 

int Function StartAnimation(SMMMCM MCM, Actor victim, Actor[] them, int asVictim = 1, String hook = "") global
  int sol = -1
  If(hasCreatures(victim, them))
    If(MCM.bSLAllowed)
			sol = SMMAnimationSL.StartAnimation(MCM, victim, them, asVictim, hook)
		EndIf
  ElseIf(MCM.bSLAllowed)
    If(MCM.bOStimAllowed && (MCM.bCrtOnly || Utility.RandomInt(0, 1) == 0))
      sol = SMMAnimationOStim.StartScene(MCM, victim, them, asVictim)
    Else
      sol = SMMAnimationSL.StartAnimation(MCM, victim, them, asVictim, hook)
    EndIf
  ElseIf(MCM.bOStimAllowed)
    sol = SMMAnimationOStim.StartScene(MCM, victim, them, asVictim)
  EndIf
  If(sol != -1 && MCM.bNotifyAF)
    String vicName = victim.GetLeveledActorBase().GetName()
    String otherName = them[0].GetLeveledActorBase().GetName()
    If(MCM.bNotifyColor)
      Debug.Notification("<font color='" + MCM.sNotifyColor + "'>" + vicName + " is being engaged by " + otherName + "</font>")
    else
      Debug.Notification(vicName + " is being engaged by " + otherName + "</font>")
    EndIf
  EndIf
  return sol
EndFunction


int Function GetAllowedParticipants(int limit) global
  Debug.Trace("[SMM] <GetAllowedParticipants> Limit = " + limit)
  If(limit <= 2)
    return limit
  EndIf
  int[] odds = SMMUtility.GetMCM().iSceneTypeWeight
  int res = SMMUtility.GetFromWeight(odds) + 1
  Debug.Trace("[SMM] <GetAllowedParticipants> res = " + res)
  If(res <= limit)
    return res
  EndIf
  return limit
EndFunction

int Function GetArousal(Actor that) global
  SMMMCM MCM = SMMUtility.GetMCM()
  If(MCM.bSLAllowed)
    return SMMAnimationSL.GetArousal(that)
  ElseIf(that.HasKeywordString("ActorTypeNPC") && MCM.bOStimAllowed)
    return SMMAnimationOStim.GetArousal(that)
  EndIf
  return -1
EndFunction

bool Function IsAnimating(Actor subject) global
  SMMMCM MCM = SMMUtility.GetMCM()
  If (MCM.bSLAllowed && SMMAnimationSL.IsAnimating(subject))
    return true
  EndIf
  return MCM.bOStimAllowed && SMMAnimationOStim.StopAnimating(subject)
EndFunction

bool Function StopAnimating(Actor subject) global
  Debug.Trace("[SMM] Stop Animating for " + subject)
  SMMMCM MCM = SMMUtility.GetMCM()
  If (MCM.bSLAllowed)
    If (SMMAnimationSL.StopAnimating(subject))
      return true
    EndIf
  EndIf
  If (MCM.bOStimAllowed)
    If (SMMAnimationOStim.StopAnimating(subject))
      return true
    EndIf
  EndIf
  return false
EndFunction
