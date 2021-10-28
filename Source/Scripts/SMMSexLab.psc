Scriptname SMMSexLab Hidden

int Function getActorType(Actor me) global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  int mySLGender = SL.GetGender(me)
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