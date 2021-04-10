//------------------------------------------
// HUD uses this to get some info from the server
//------------------------------------------
class KF2HUDReplicator extends Actor
	config(FunhouseGame);

var()					FunhouseGameReplicationInfo			FGRI;
var() config			array<String>						BossTypes;

var() config			float								CheckTime;
var()					float								CheckGoal;

Struct BossStruct
{
	var()				KFMonster					Monster;
	var()				int							Health;
	var()				int							HealthMax;
};
var()					array<BossStruct>					ActiveBosses;

//--------------------------------------------------------------------------

// Check for monsters
function Tick(float DT)
{
	if (Level.TimeSeconds >= CheckGoal)
	{
		CheckGoal = Level.TimeSeconds + CheckTime;
		UpdateMonsters();
	}
}

// Find a monster's boss entry
function BossStruct FindBossStruct(KFMonster M)
{
	local int l;
	local bool bFound;
	local BossStruct BS;
	
	for (l=0; l<ActiveBosses.Length; l++)
	{
		if (ActiveBosses[l].Monster == M)
		{
			bFound = true;
			return ActiveBosses[l];
		}
	}
	
	// NOT FOUND, LET'S GENERATE A NEW BOSS
	if (!bFound)
	{
		BS.Monster = M;
		BS.Health = M.Health;
		BS.HealthMax = M.HealthMax;
		
		ActiveBosses[ActiveBosses.Length] = BS;
		
		return BS;
	}
}

// Is this monster a boss?
function bool IsBoss(KFMonster M)
{
	local int l;
	
	for (l=0; l < BossTypes.Length; l++)
	{
		if (string(M.Class) ~= BossTypes[l])
			return true;
	}
	
	return false;
}

// A monster was spawned - this is called from other things
function MonsterSpawned(KFMonster M)
{
	local int l;
	
	// Not a boss, forget about it
	if (!IsBoss(M))
		return;
	
	// Add the monster to the boss array
	Log("KF2HUDReplicator - Detected boss:" @ string(M.Class));
	FindBossStruct(M);
	UpdateInformation();
}

// Called at an interval, update the monster health
function UpdateMonsters()
{
	local int l;
	local array<BossStruct> NewBosses;
	local bool bGreasy;
	
	for (l=0; l<ActiveBosses.Length; l++)
	{
		// Monster is dead or doesn't exist
		if (ActiveBosses[l].Monster == None || ActiveBosses[l].Monster.Health <= 0)
		{
			bGreasy = true;
			continue;
		}
		
		// HEALTH DOES NOT MATCH
		if (ActiveBosses[l].Monster.Health != ActiveBosses[l].Health)
		{
			bGreasy = true;
			ActiveBosses[l].Health = ActiveBosses[l].Monster.Health;
		}
		
		// HEALTH MAX DOES NOT MATCH
		if (ActiveBosses[l].Monster.HealthMax != ActiveBosses[l].HealthMax)
		{
			bGreasy = true;
			ActiveBosses[l].HealthMax = ActiveBosses[l].Monster.HealthMax;
		}
		
		NewBosses[NewBosses.Length] = ActiveBosses[l];
	}
	
	// Set to our new boss list
	ActiveBosses = NewBosses;
	
	// GREASY, INFORMATION NEEDS TO BE CHANGED
	if (bGreasy)
		UpdateInformation();
}

// Update the info, this should send it to some clients
function UpdateInformation()
{
	local String S;
	local float Pct;
	local int l;
	
	if (FGRI == None)
		return;
	
	if (ActiveBosses.Length <= 0)
		S = "NONE";
	else
	{
		for (l=0; l<ActiveBosses.Length; l++)
		{
			Pct = FClamp((ActiveBosses[l].Health * 1.0) / (ActiveBosses[l].HealthMax * 1.0), 0.0, 1.0);

			if (Len(S) > 0)
				S = S $ "|";

			S = S $ ActiveBosses[l].Monster.MenuName $ "," $ string(Pct);
		}
	}
	
	FGRI.BossHealthString = S;
}

defaultproperties
{
     CheckTime=0.200000
     bHidden=True
}
