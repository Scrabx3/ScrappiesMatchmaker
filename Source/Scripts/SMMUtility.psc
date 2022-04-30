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