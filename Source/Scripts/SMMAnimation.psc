Scriptname SMMAnimation Hidden

; ======================================================================
; ================================== ANIMATION
; ======================================================================
; Start 1p Animation
int Function StartAnimationSingle(SMMMCM MCM, Actor that, String hook = "") global
  If(MCM.bSLAllowed)
		return SexLabUtil.QuickStart(that, hook = hook).tid
	EndIf
  return -1
EndFunction 

int Function StartAnimation(SMMMCM MCM, Actor victim, Actor[] them, int asVictim = 1, String hook = "") global
  int sol = -1
  If(MCM.bSLAllowed)
		sol = StartAnimationImpl(MCM, victim, them, asVictim, hook)
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

int Function StartAnimationImpl(SMMMCM MCM, Actor first, Actor[] partners, int asVictim, string hook = "") global
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
  Actor[] positions = PapyrusUtil.PushActor(partners, first)
  positions[positions.Length - 1] = positions[0]
  positions[0] = first
  int[] genders = Utility.CreateIntArray(positions.length)
  int i = 0
  While(i < genders.length)
    genders[i] = SL.GetGender(positions[i])
    i += 1
  EndWhile
	While(positions.length > 0)
    bool creatures = genders.find(2) > -1 || genders.find(3) > -1
    int n
    If(positions.length == 2 && !creatures)
	    int males = SL.MaleCount(positions)
	    If(genders[0] == 1 && males == 1) ; F<-M
        n = 0
      Else ; F<-F // M<-F // M<-M
        n = 1 + males
      EndIf
	  Else
      If(genders[0] == 0 || victim && SL.GetGender(victim) == 0)
        n = 4
      Else
        n = 5
      EndIf
	  EndIf
    String tags = MCM.SLTags[n]
    SexLabThread thread = SL.StartScene(positions, tags, victim, asHook = hook)
    If (thread)
      thread.SetConsent(asVictim == 0)
      return thread.GetThreadID()
    EndIf
    Debug.Trace("[Kudasai] No Animations found, reducing Array size from size = " + positions.length)
    int j = positions.Length
    While(j > 0)
      j -= 1
      If(positions[j] != victim)
        positions = PapyrusUtil.RemoveActor(positions, positions[j])
        genders = Utility.CreateIntArray(positions.length)
        int k = 0
        While(k < genders.length)
          genders[k] = SL.GetGender(positions[k])
          k += 1
        EndWhile
      EndIf
    EndWhile
	EndWhile
  return -1
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

int Function GetArousal(Actor akActor) global
  slaFrameworkScr SLA = Quest.GetQuest("sla_Framework") as slaFrameworkScr
  If(SLA == none)
    Debug.Trace("[SMM] <GetArousal> SLA not found")
    return -1
  EndIf
  return SLA.GetActorArousal(akActor)
EndFunction

bool Function IsAnimating(Actor akActor) global
  SMMMCM MCM = SMMUtility.GetMCM()
  If (!MCM.bSLAllowed)
    return false
  EndIf
  SexLabFramework SL = SexLabUtil.GetAPI()
  return SL.FindActorController(akActor) > -1
EndFunction

bool Function StopAnimating(Actor akActor, int tid = -1) global
  Debug.Trace("[SMM] Stop Animating for " + akActor)
  SMMMCM MCM = SMMUtility.GetMCM()
  If (!MCM.bSLAllowed)
    return false
  EndIf
  SexLabFramework SL = SexLabUtil.GetAPI()
  if (tid == -1)
    tid = SL.FindActorController(akActor)
    if (tid == -1)
      Debug.Trace("[SMM] Actor = " + akActor + " is not part of any SL Animation.")
      return false
    endif
  endif
  sslThreadController controller = SL.GetController(tid)
  if (!controller)
    Debug.Trace("[SMM] Actor = " + akActor + " is not part of any SL Animation.")
    return false
  endif
  controller.EndAnimation()
  return true
EndFunction
