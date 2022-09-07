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
  Actor[] positions = PapyrusUtil.PushActor(partners, first)
  positions[positions.Length - 1] = positions[0]
  positions[0] = first
  int[] genders = Utility.CreateIntArray(positions.length)
  int i = 0
  While(i < genders.length)
    genders[i] = SL.GetGender(positions[i])
    i += 1
  EndWhile
  sslBaseAnimation[] anims
	bool breakLoop = false
	While(!breakLoop)
    bool creatures = genders.find(3) > -1 || genders.find(4) > -1
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
    String[] tags = GetTags(MCM.SLTags[n])
    If (creatures)
      anims = SL.GetCreatureAnimationsByRaceTags(positions.Length, positions[positions.Length - 1].GetRace(), tags[0], tags[1])
    Else
      anims = SL.GetAnimationsByTags(positions.length, tags[0], tags[1])
    EndIf
		If(anims.Length)
      Debug.Trace("[Kudasai] Found Animations = " + anims.Length)
			breakLoop = true
		Else
      If(positions.length <= 2) ; Didnt find an animation with 2 or less actors
        Debug.Trace("[Kudasai] No Animations found", 2)
        return -1
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
    EndIf
	EndWhile
  return SL.StartSex(positions, anims, victim, hook = hook)
EndFunction

String[] Function GetTags(String str) global
  String[] all = PapyrusUtil.StringSplit(str, ",")
  String[] res = new String[2]
  int i = 0
  While(i < all.Length)
    If(StringUtil.GetNthChar(all[i], 0) == "-")
      res[1] = res[1] + (StringUtil.Substring(all[i], 1) + ",")
    Else
      res[0] = res[0] + all[i] + ","
    EndIf
    i += 1
  EndWhile
  return res
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