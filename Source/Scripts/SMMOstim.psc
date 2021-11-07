Scriptname SMMOstim Hidden

int Function GetArousal(Actor that) global
  OArousedScript OA = OArousedScript.GetOAroused()
  return OA.getArousal(that) as int
EndFunction

int Function GetVersion() global
  return OUtils.GetOstim().GetAPIVersion()
EndFunction

bool Function FindInit(Actor that, int ID) global
  OSexIntegrationMain OStim = OUtils.GetOstim()
  If(ID == -1)
    return OStim.IsActorInvolved(that)
  Else
    OStimSubthread st = OStim.GetSubthread(ID)
    return st.actorlist.Find(that) > -1
  EndIf
  return false
EndFunction

Function StartSceneSingle(Actor that) global
  OUtils.GetOstim().Masturbate(that)
EndFunction

int Function StartScene(SMMMCM MCM, Actor first, Actor[] others, int asVictim) global
  OSexIntegrationMain OStim = OUtils.GetOstim()
  Actor Player = Game.GetPlayer()
	bool hasPlayer = (first == Player || others.Find(Player) > -1)
  Actor third = none
  If(others.length > 1)
    third = others[1]
  EndIf
  If(hasPlayer)
    If(OStim.StartScene(others[0], first, false, true, false, zThirdActor = third, aggressive = asVictim, AggressingActor = others[0]))
      return 0
    EndIf
  else
    OStimSubthread st = OStim.GetUnusedSubthread()
    float timer = Utility.RandomFloat(MCM.fOtMinD, MCM.fOtMaxD)
    If(st.StartScene(others[0], first, third, timer, isaggressive = asVictim, aggressingActor = others[0]))
      return 1
    EndIf
  EndIf
  return -1
EndFunction