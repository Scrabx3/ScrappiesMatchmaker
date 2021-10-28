Scriptname SMMOstim Hidden

int Function GetArousal(Actor that) global
  OArousedScript OA = OArousedScript.GetOAroused()
  return OA.getArousal(that) as int
EndFunction