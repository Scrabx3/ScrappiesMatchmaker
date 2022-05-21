;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname QF_SMM_Scan_04000802 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Actor11
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor11 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor15
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor15 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor12
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor12 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor19
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor19 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor13
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor13 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor00 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor16
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor16 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor14
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor14 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor17
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor17 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor18
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor18 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Actor09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Actor09 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE SMMScan
Quest __temp = self as Quest
SMMScan kmyQuest = __temp as SMMScan
;END AUTOCAST
;BEGIN CODE
kmyQuest.ShutDown()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
