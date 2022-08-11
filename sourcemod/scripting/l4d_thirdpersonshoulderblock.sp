#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks_silver>
#include <colors>
#define PLUGIN_VERSION "1.5"

ConVar	Cvar_Enabled;

public Plugin myinfo =
{
	name = "Thirdpersonshoulder Block",
	author = "Don",
	description = "Kicks clients who enable the thirdpersonshoulder mode on L4D1/2 to prevent them from looking around corners, through walls etc.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=159582"
}

public void OnPluginStart()
{
	/* Only load the plugin if the server is running Left 4 Dead or Left 4 Dead 2.
	 * Loading the plugin on Counter-Strike: Source or Team Fortress 2 would cause all clients to get kicked,
	 * because the thirdpersonshoulder mode and the corresponding ConVar that we check do not exist there.
	 */
	char sGame[64];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "left4dead2", false))
	{
		if (!StrEqual(sGame, "left4dead", false))
		{
			SetFailState("Plugin only supports L4D1/2");
		}
	}
	LoadTranslations("tpsblock.phrases");
	CreateConVar("l4d_tpsblock_version", PLUGIN_VERSION, "Version of the Thirdpersonshoulder Block plugin", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	Cvar_Enabled = CreateConVar("l4d_tpsblock_enabled", "1", "Enable Thirdpersonshoulder Block", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateTimer(GetRandomFloat(2.5, 3.5), CheckClients, _, TIMER_REPEAT);
}

public Action CheckClients(Handle timer)
{
	if (GetConVarBool(Cvar_Enabled))
	{
		for (int iClientIndex = 1; iClientIndex <= MaxClients; iClientIndex++)
		{
			if (IsClientInGame(iClientIndex) && !IsFakeClient(iClientIndex))
			{
				if (GetClientTeam(iClientIndex) != L4D_TEAM_SPECTATOR)	// Only query clients on survivor or infected team, ignore spectators.
				{
					QueryClientConVar(iClientIndex, "c_thirdpersonshoulder", QueryClientConVarCallback);
				}
			}
		}
	}
}

public void QueryClientConVarCallback(QueryCookie cookie,int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
	if (IsClientInGame(client) && !IsClientInKickQueue(client))
	{
		/* If the ConVar was somehow not found on the client, is not valid or is protected, kick the client.
		 * The ConVar should always be readable unless the client is trying to prevent it from being read out.
		 */
		if (result != ConVarQuery_Okay)

		{
			ChangeClientTeam(client, L4D_TEAM_SPECTATOR);
			CPrintToChat(client, "%t", "Cvar invalid");
		}
		/* If the ConVar was found on the client, but is not set to either "false" or "0",
		 * kick the client as well, as he might be using thirdpersonshoulder.
		 */
		else if (!StrEqual(cvarValue, "false") && !StrEqual(cvarValue, "0"))
		{
			ChangeClientTeam(client, L4D_TEAM_SPECTATOR);
			CPrintToChat(client, "%t", "Cvar value 1");
		}
	}
}
