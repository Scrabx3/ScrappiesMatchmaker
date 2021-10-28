Scriptname SMMThread extends Quest  
{Generic Thread Script. Takes on Aliases and starts a Scene once no more Aliases can be added anymore}

SMMScan Property Scan Auto
ReferenceAlias[] Property SceneActors Auto

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  
EndEvent