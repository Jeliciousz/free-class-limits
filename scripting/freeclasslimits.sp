#include <sourcemod>
#include <dhooks>
#include <tf2>
#include <tf2_stocks>

#define GAMEDATA "freeclasslimits"

ConVar g_cvMpTournament;

ConVar g_cvClasslimitScout;
ConVar g_cvClasslimitSoldier;
ConVar g_cvClasslimitPyro;
ConVar g_cvClasslimitDemoman;
ConVar g_cvClasslimitHeavy;
ConVar g_cvClasslimitEngineer;
ConVar g_cvClasslimitMedic;
ConVar g_cvClasslimitSniper;
ConVar g_cvClasslimitSpy;

public Plugin myinfo =
{
    name = "Free Class Limits",
    author = "Jeliciousz, brokenphilip",
    description = "Allow setting class limits without tournament mode being enabled.",
    version = "0.0.3",
    url = "https://github.com/Jeliciousz/free-class-limits"
};

public OnPluginStart()
{
    g_cvMpTournament = FindConVar("mp_tournament");
    
    g_cvClasslimitScout = FindConVar("tf_tournament_classlimit_scout");
    g_cvClasslimitSoldier = FindConVar("tf_tournament_classlimit_soldier");
    g_cvClasslimitPyro = FindConVar("tf_tournament_classlimit_pyro");
    g_cvClasslimitDemoman = FindConVar("tf_tournament_classlimit_demoman");
    g_cvClasslimitHeavy = FindConVar("tf_tournament_classlimit_heavy");
    g_cvClasslimitEngineer = FindConVar("tf_tournament_classlimit_engineer");
    g_cvClasslimitMedic = FindConVar("tf_tournament_classlimit_medic");
    g_cvClasslimitSniper = FindConVar("tf_tournament_classlimit_sniper");
    g_cvClasslimitSpy = FindConVar("tf_tournament_classlimit_spy");
    
    GameData hGameData = LoadGameConfigFile(GAMEDATA);
    if( hGameData == null ) 
        SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

    Handle hDHook_GetClassLimit = DHookCreateFromConf(hGameData, "CTFGameRules::GetClassLimit");
    if( !hDHook_GetClassLimit )
        SetFailState("Failed to setup hook for CTFGameRules::GetClassLimit.");

    if ( !DHookEnableDetour(hDHook_GetClassLimit, false, DHook_GetClassLimit) )
        SetFailState("Failed to detour CTFGameRules::GetClassLimit.");

    delete hGameData;

    HookEvent("teamplay_round_active", Event_RoundActive)

    PrintToServer("Free Class Limits loaded!")
}

public void Event_RoundActive(Event event, const char[] name, bool dontBroadcast)
{
    bool full_reset = event.GetBool("full_reset");

    if (!full_reset)
    {
        return;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || IsFakeClient(client))
        {
            continue;
        }
        TFTeam clientTeam = TF2_GetClientTeam(client);
        if (clientTeam != TFTeam_Blue && clientTeam != TFTeam_Red)
        {
            continue;
        }

        SendConVarValue(client, g_cvMpTournament, "1");
    }
}

public MRESReturn DHook_GetClassLimit(DHookReturn hReturn, DHookParam hParams)
{
    TFClassType class = view_as<TFClassType>(DHookGetParam(hParams, 1));

    switch (class)
    {
        case TFClass_Scout: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitScout));
        case TFClass_Soldier: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitSoldier));
        case TFClass_Pyro: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitPyro));
        case TFClass_DemoMan: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitDemoman));
        case TFClass_Heavy: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitHeavy));
        case TFClass_Engineer: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitEngineer));
        case TFClass_Medic: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitMedic));
        case TFClass_Sniper: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitSniper));
        case TFClass_Spy: DHookSetReturn(hReturn, GetConVarInt(g_cvClasslimitSpy));
        default: return MRES_Ignored;
    }

    return MRES_Supercede;
}
