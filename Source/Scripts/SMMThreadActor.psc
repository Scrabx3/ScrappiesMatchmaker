Scriptname SMMThreadActor extends ReferenceAlias  
{Alias Script attached to Actors in a Thread Quest}

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  Spell sp = akSource as Spell
  Enchantment ench = akSource as Enchantment
  If(akSource as Weapon || sp && sp.IsHostile() || ench && ench.IsHostile())
    Actor me = GetActorReference()
    If(me)
      If(SMMAnimation.StopAnimating(me))
        GetOwningQuest().Stop()
      EndIf
    EndIf
  EndIf
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  Actor me = GetActorReference()
  If(me && aeCombatState == 1)
    If(SMMAnimation.StopAnimating(me))
      GetOwningQuest().Stop()
    EndIf
  EndIf
EndEvent
