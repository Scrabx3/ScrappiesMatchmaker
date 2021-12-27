Scriptname SMMThreadActor extends ReferenceAlias  
{Alias Script attached to Actors in a Thread Quest}

SMMMCM Property MCM Hidden
  SMMMCM Function Get()
    return Quest.GetQuest("SMM_Main") as SMMMCM
  EndFUnction
EndProperty

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  If(MCM.bSLAllowed)
    If(SMMSexLab.stopAnimation(GetReference() as Actor) > -1)
      GetOwningQuest().Stop()
    EndIf
  EndIf
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  If(aeCombatState == 1)
    If(MCM.bSLAllowed)
      SMMSexLab.stopAnimation(GetReference() as Actor) > -1
    EndIf
    GetOwningQuest().Stop()
  EndIf
EndEvent
