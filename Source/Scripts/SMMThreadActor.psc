Scriptname SMMThreadActor extends ReferenceAlias  
{Alias Script attached to Actors in a Thread Quest}

SMMMCM Property MCM Hidden
  SMMMCM Function Get()
    return Quest.GetQuest("SMM_Main") as SMMMCM
  EndFUnction
EndProperty

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  If(GetOwningQuest().GetStage() < 20)
    return    
  EndIf
  If(MCM.bSLAllowed)
    SMMSexLab.stopAnimation(GetReference() as Actor)
  EndIf
EndEvent