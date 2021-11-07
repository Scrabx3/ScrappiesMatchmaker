Scriptname SMMThreadCollect extends ActiveMagicEffect  

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Keyword Property ActorTypeNPC Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  bool npc = akTarget.HasKeyword(ActorTypeNPC)
  If(MCM.bSpecGender && npc && !Scan.isValidGenderCombination(akCaster, akTarget) || !npc && !MCM.bSpecCrt || Utility.RandomFloat(0, 99.9) >= MCM.fSpecChance)
    return
  EndIf
  SMMThread t = StorageUtil.GetFormValue(akCaster, "Thread") as SMMThread
  If(t)
    t.AddActor(akTarget)
  EndIf
EndEvent