#include	<sdktools>
#include	<clientprefs>
#include	<multicolors>

#pragma		semicolon	1
#pragma		newdecls	required
#pragma		dynamic		131072 

Handle	name_storage,
		force_name_storage;

public	Plugin	myinfo	=	{
	name		=	"[ANY] Keep Player Name",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Stores the player name to make sure player stays within the same name",
	version		=	"1.1.0",
	url			=	"https://steamcommunity.com/id/Teamkiller324"
}

public	void	OnPluginStart()	{
	LoadTranslations("common.phrases");
	LoadTranslations("keep_player_name.phrases");
	
	name_storage		=	RegClientCookie("keep_player_name",				"Keeps The Players Name",	CookieAccess_Private);
	force_name_storage	=	RegClientCookie("keep_player_name_forcename",	"The clients forced name",	CookieAccess_Private);
	
	HookUserMessage(GetUserMessageId("SayText2"),	suppress_NameChange,	true);
	
	RegAdminCmd("sm_forcename",			ForceName,			ADMFLAG_SLAY,	"Force a clients name");
	RegAdminCmd("sm_clearname",			ClearName,			ADMFLAG_SLAY,	"Clear a clients kept name");
	
	//If reloading plugin or loading plugin mid-game
	for(int i = 0; i < MaxClients; i++)	{
		if(!IsValidClient(i))
			return;
		if(IsClientInGame(i))
			cookies(i);
	}
}

//Taken from Suppress Manager | Credits Bacardi
Action	suppress_NameChange(UserMsg msg_id,	Handle bf,	const players[],	int playersNum,	bool reliable,	bool init)	{
	if(!reliable)
		return Plugin_Continue;
	
	//Block out name changes
	char buffer[25];
	if(GetUserMessageType() == UM_Protobuf)	{
		PbReadString(bf, "msg_name", buffer, sizeof(buffer));
		if(StrContains(buffer, "Name_Change",	false)	!=	-1)
			return Plugin_Handled;
	}
	else	{
		BfReadChar(bf);
		BfReadChar(bf);
		BfReadString(bf, buffer, sizeof(buffer));

		if(StrContains(buffer, "Name_Change",	false)	!=	-1)
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

public	void	OnClientCookiesCached(int client)	{
	cookies(client);
}

public	void	OnClientPutInServer(int client)	{
	cookies(client);
}

public	void	OnClientDisconnect(int client)	{
	cookies(client);
}

public	void	OnClientSettingsChanged(int client)	{
	cookies(client);	
}

void	cookies(int client)	{
	if(IsValidClient(client))	{
		char	cookie_storedname[256],
				cookie_forcedname[256];
		GetClientCookie(client,	name_storage,		cookie_storedname,	sizeof(cookie_storedname));
		GetClientCookie(client,	force_name_storage,	cookie_forcedname,	sizeof(cookie_forcedname));
		
		if(StrEqual(cookie_forcedname,	""))	{
			if(!StrEqual(cookie_storedname,	""))	{
				if(IsClientInGame(client) && IsValidTeam(client))
					SetClientName(client,	cookie_storedname);
			}
		}
		else if(!StrEqual(cookie_forcedname,	""))	{
			if(IsClientInGame(client) && IsValidTeam(client))
				SetClientName(client,	cookie_forcedname);
		}
	}
}

Action	ForceName(int client,	int args)	{		
	switch(args)	{
		case	0:	{
			char	name[256];
			GetClientCookie(client,	name_storage,	name,	sizeof(name));
			SetClientName(client,	name);
			
			SetClientCookie(client,	force_name_storage,	"");
			
			CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_reset");
			return	Plugin_Handled;
		}
		case	2:	{
			char	arg1			[256],
					arg2			[256],
					target_name		[MAX_TARGET_LENGTH];
			int		target_list		[MAXPLAYERS],
					target_count;
			bool	tn_is_ml;
			
			GetCmdArg(1,	arg1,	sizeof(arg1));
			GetCmdArg(2,	arg2,	sizeof(arg2));
			
			if((target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
			{
				ReplyToTargetError(client, target_count);
				return Plugin_Handled;
			}
			
			for(int i = 0; i < target_count; i++)	{
				int	target	=	target_list[i];
				SetClientCookie(target,	force_name_storage,	arg2);
				SetClientName(target,	arg2);
			}
			
			CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_set",	target_name,	arg2);
			return	Plugin_Handled;
		}
		default:	{
			CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_usage");
			return	Plugin_Handled;
		}
	}
}

Action	ClearName(int client,	int args)	{		
	switch(args)	{
		case	0:	{
			char	name[256];
			GetClientInfo(client,	"name",	name,	sizeof(name));
			SetClientName(client,	name);
			
			SetClientCookie(client,	name_storage,	"");
			
			CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_clearname_reset");
			return	Plugin_Handled;
		}
		case	2:	{
			char	arg1			[256],
					target_name		[MAX_TARGET_LENGTH];
			int		target_list		[MAXPLAYERS],
					target_count;
			bool	tn_is_ml;
			
			GetCmdArg(1, arg1, sizeof(arg1));
			if((target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
			{
				ReplyToTargetError(client, target_count);
				return Plugin_Handled;
			}
			
			for(int i = 0; i < target_count; i++)	{
				int	target	=	target_list[i];
				SetClientCookie(target,	name_storage,	"");
				
				char	cookie[256];
				GetClientCookie(target,	name_storage,	cookie,	sizeof(cookie));
				SetClientName(target,	cookie);
			}
	
			CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_clearname_set",	target_name);
			return	Plugin_Handled;
		}
		default:	{
			CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_clearname_usage");
			return	Plugin_Handled;
		}
	}
}

stock	bool	IsValidClient(int client)	{
	if(client	<	1)
		return	false;
	if(client	>	MaxClients)
		return	false;
	if(IsFakeClient(client))
		return	false;
	return	true;
}

stock	bool	IsValidTeam(int client)	{
	if(GetClientTeam(client)	<	1)
		return	false;
	return	true;
}