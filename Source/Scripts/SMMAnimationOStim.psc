Scriptname SMMAnimationOstim Hidden

int Function GetVersion() global
  return OUtils.GetOstim().GetAPIVersion()
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
  If(asVictim)
    OStim.AddSceneMetadata("or_player_nocheat")
    OStim.AddSceneMetadata("or_npc_nocheat")
  EndIf
  If(hasPlayer)
    If(OStim.StartScene(others[0], first, false, false, false, zThirdActor = third, aggressive = asVictim, AggressingActor = others[0]))
      return 0
    EndIf
  else
    OStimSubthread st = OStim.GetUnusedSubthread()
    If(st.StartScene(others[0], first, third, 30.0, isaggressive = asVictim, aggressingActor = others[0]))
      return 1
    EndIf
  EndIf
  return -1
EndFunction


bool Function IsPlayerPartner(Actor that) global
  return OUtils.GetNPCDataBool(that, "or_k_part")
EndFunction

int Function GetArousal(Actor that) global
  OArousedScript OA = OArousedScript.GetOAroused()
  return OA.getArousal(that) as int
EndFunction

OStimSubthread Function GetSubthreadFromActor(Actor subject) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  Quest sq = OStim.subthreadquest
  Alias[] aliases = sq.GetAliases()
  int i = 0
	While (i < aliases.Length) 
		OStimSubthread thread = aliases[i] as OStimSubthread
    if (thread.actorlist.find(subject) > -1)
      return thread
    endif
		i += 1
	EndWhile
  return none
EndFunction

bool Function StopAnimating(Actor subject) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  If (!Ostim.isactoractive(subject))
    Debug.Trace("[SMM] Actor is not animating")
    return false
  ElseIf (Ostim.IsActorInvolved(subject))
    OStim.EndAnimation()
    return true
  Else
    OStimSubthread thread = GetSubthreadFromActor(subject)
    if (thread)
      thread.EndAnimation()
      return true
    endif
  EndIf
  return false
EndFunction

Actor[] Function GetPositions(int id) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  If (id == -1)
    return OStim.GetActors()
  Else
    OStimSubthread thread = OStim.GetSubthread(id)
    return thread.actorlist
  EndIf
  return PapyrusUtil.ActorArray(0)
EndFunction

bool Function IsAnimating(Actor subject) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  return OStim.IsActorActive(subject)
EndFunction