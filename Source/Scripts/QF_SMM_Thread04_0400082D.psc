;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname QF_SMM_Thread04_0400082D Extends Quest Hidden

;BEGIN ALIAS PROPERTY Partner03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Partner03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Initiator
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Initiator Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Partner01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Partner01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Partner00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Partner00 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Partner02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Partner02 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE SMMThread
Quest __temp = self as Quest
SMMThread kmyQuest = __temp as SMMThread
;END AUTOCAST
;BEGIN CODE
kmyQuest.CleanUp()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
