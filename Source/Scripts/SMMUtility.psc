Scriptname SMMUtility Hidden

SMMMCM Function GetMCM() global
  return Quest.GetQuest("SMM_Main") as SMMMCM
EndFunction

bool Function HasSchlong(Actor subject) global
  If (Game.GetModByName("Schlongs of Skyrim.esp") != 255)
    Faction SchlongFac = Game.GetFormFromFile(0x00AFF8, "Schlongs of Skyrim.esp") as Faction
		return subject.IsInFaction(SchlongFac)
  EndIf
  return false 
EndFunction

int Function GetFromWeight(int[] weights) global
  int all = 0
  int i = 0
  While(i < weights.length)
    all += weights[i]
    i += 1
  EndWhile
  int this = Utility.RandomInt(1, all)
  int limit = 0
  int n = 0
  While(limit < this)
    limit += weights[n]
    n += 1
  EndWhile
  return n
EndFunction

; JContainers in LE is outdated. Using workaround Functions to get Array manually
; Dw lads, its just JContainers and 20 other Utilities, LE is still doing fiiiine
Form[] Function asJFormArray(int jObj) global
  int m = JArray.count(jObj)
  Form[] ret = PapyrusUtil.FormArray(m)
  int i = 0
  While(i < m)
    ret[i] = JArray.getForm(jObj, i)
    i += 1
  EndWhile
  return ret
EndFunction

int[] Function asJIntArray(int jObj) global
  int m = JArray.count(jObj)
  int[] ret = Utility.CreateIntArray(m)
  int i = 0
  While(i < m)
    ret[i] = JArray.getInt(jObj, i)
    i += 1
  EndWhile
  return ret
EndFunction

String[] Function asJStringArray(int jObj) global
  int m = JArray.count(jObj)
  String[] ret = PapyrusUtil.StringArray(m)
  int i = 0
  While(i < m)
    ret[i] = JArray.getStr(jObj, i)
    i += 1
  EndWhile
  return ret
EndFunction

Bool[] Function asJBoolArray(int jObj) global
  int m = JArray.count(jObj)
  Bool[] ret = PapyrusUtil.BoolArray(m)
  int i = 0
  While(i < m)
    ret[i] = JArray.getInt(jObj, i)
    i += 1
  EndWhile
  return ret
EndFunction
