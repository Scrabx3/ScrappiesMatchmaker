Scriptname SMMAnimFrame Hidden


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
			SMMSexLab.StartSceneSingle(that, hook)
      sol = 0
		EndIf
  ElseIf(MCM.bSLAllowed)
    If(MCM.bOStimAllowed && (MCM.bCrtOnly || Utility.RandomInt(0, 1) == 0))
      SMMOstim.StartSceneSingle(that)
      sol = 1
    Else
      SMMSexLab.StartSceneSingle(that, hook)
      sol = 0
    EndIf
  ElseIf(MCM.bOStimAllowed)
    SMMOstim.StartSceneSingle(that)
    sol = 1
  EndIf
  return sol
EndFunction 

int Function StartAnimation(SMMMCM MCM, Actor victim, Actor[] them, int asVictim = 1, String hook = "") global
  int sol = -1
  If(hasCreatures(victim, them))
    If(MCM.bSLAllowed)
			sol = SMMSexLab.StartAnimation(MCM, victim, them, asVictim, hook)
		EndIf
  ElseIf(MCM.bSLAllowed)
    If(MCM.bOStimAllowed && (MCM.bCrtOnly || Utility.RandomInt(0, 1) == 0))
      sol = SMMOstim.StartScene(MCM, victim, them, asVictim)
    Else
      sol = SMMSexLab.StartAnimation(MCM, victim, them, asVictim, hook)
    EndIf
  ElseIf(MCM.bOStimAllowed)
    sol = SMMOstim.StartScene(MCM, victim, them, asVictim)
  EndIf
  If(sol != -1 && MCM.bNotifyAF)
    String vicName = victim.GetLeveledActorBase().GetName()
    String otherName = them[0].GetLeveledActorBase().GetName()
    If(MCM.bNotifyColorAF)
      Debug.Notification("<font color='" + MCM.sNotifyColorAF + "'>" + vicName + " is being engaged by " + otherName + "</font>")
    else
      Debug.Notification(vicName + " is being engaged by " + otherName + "</font>")
    EndIf
  EndIf
  return sol
EndFunction