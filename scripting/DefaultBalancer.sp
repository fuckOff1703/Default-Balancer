#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

Handle g_hBalanceTeams;

public Plugin myinfo =
{
	name	=	"Default Balancer",
	author	=	"OkyHp & fuckOff1703",
	version	=	"1.0.2",
	url		=	"OkyHek#2441"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] szError, int iErr_max)
{
	if(GetEngineVersion() != Engine_CSGO && GetEngineVersion() != Engine_CSS)
	{
		strcopy(szError, iErr_max, "This plugin works only on CS:GO and CS:S!");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	GameData hGameData = LoadGameConfigFile("DefaultBalancer.games");
	if (!hGameData)
	{
		SetFailState("Failed to load DefaultBalancer gamedata.");
	}

	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CCSGameRules::BalanceTeams");

	DynamicDetour hDetourRestartRound = DynamicDetour.FromConf(hGameData, "CCSGameRules::RestartRound");

	hGameData.Close();

	g_hBalanceTeams = EndPrepSDKCall();
	
	if (!g_hBalanceTeams)
	{
		SetFailState("Failed to setup CCSGameRules::BalanceTeams");
	}

	if(!hDetourRestartRound)
	{
		SetFailState("Failed to setup detour for CCSGameRules::RestartRound");
	}

	if(!hDetourRestartRound.Enable(Hook_Pre, RestartRound_Callback))
	{
		SetFailState("Failed to enable detour for CCSGameRules::RestartRound");
	}
}

public void OnConfigsExecuted()
{
	FindConVar("mp_autoteambalance").IntValue = 0;
}

public MRESReturn RestartRound_Callback()
{
	SDKCall(g_hBalanceTeams);
	return MRES_Ignored;
}