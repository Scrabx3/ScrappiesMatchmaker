Scriptname RMMRemoveFriendFac extends ActiveMagicEffect  

RMMMCM Property MCM Auto
Faction Property FriendFac Auto
Faction Property TmpTeam Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterForSingleUpdate(MCM.iRecoveryTime + 1)
EndEvent

Event OnUpdate()
	Actor me = GetCasterActor()
	me.RemoveFromFaction(FriendFac)
	If(me.IsInFaction(TmpTeam))
		me.SetPlayerTeammate(true, true)
		me.RemoveFromFaction(tmpTeam)
	EndIf
	Dispel()
EndEvent