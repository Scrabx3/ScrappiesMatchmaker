;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname SF_SMMThreadPlScene_04000809 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
(GetOwningQuest() as SMMThread).Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
SMMThread t = GetOwningQuest() as SMMThread
If(t.consent == 0)
  t.StartScene()
  reached = true
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
SMMThread t = GetOwningQuest() as SMMThread
If(t.consent == 0)
  RegisterForSingleUpdate(t.MCM.iStalkTime)
  If(t.MCM.bStalkNotify)
    Debug.Notification("You get the feeling as if someone is lurking up to you")
		If(t.MCM.bStalkNotifyName)
			Debug.Notification(t.GetInit().GetLeveledActorBase().GetName() + " is trying to Lurk up to you.")
		Else
			Debug.Notification("You get the feeling as if someone is lurking up to you")
		EndIf
  EndIf
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Bool Property reached  Auto  

Event OnUpdate()
	If(!Reached)
		SMMThread t = GetOwningQuest() as SMMThread
		t.Stop()
		If(t.MCM.bStalkNotify)
			Debug.Notification("Your Pursuer gave up")
		EndIf
	EndIf
EndEvent
