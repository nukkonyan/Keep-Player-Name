#include	<sdktools>
#include	<clientprefs>
#include	<multicolors>

Handle	name_storage,
		force_name_storage;

public	Plugin	myinfo	=	{
	name		=	"[ANY] Keep Player Name",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Stores the player name to make sure player stays within the same name",
	version		=	"1.0.1",
	url			=	"https://steamcommunity.com/id/Teamkiller324"
}

public	void	OnPluginStart()	{
	LoadTranslations("common.phrases");
	LoadTranslations("keep_player_name.phrases");
	
	name_storage		=	RegClientCookie("keep_player_name",				"Keeps The Players Name",	CookieAccess_Private);
	force_name_storage	=	RegClientCookie("keep_player_name_forcename",	"The clients forced name",	CookieAccess_Private);
	
	RegAdminCmd("sm_forcename",			ForceName,			ADMFLAG_SLAY,	"Force a clients name");
	RegAdminCmd("sm_removeforcename",	RemoveForceName,	ADMFLAG_SLAY,	"Remove a clients forced name");
	RegAdminCmd("sm_clearname",			ClearName,			ADMFLAG_SLAY,	"Clear a clients kept name");
}

public	void	OnClientCookiesCached(int client)	{
	cookies(client);
}

public	void	OnClientPutInServer(int client)	{
	char	cookie[256];
	GetClientCookie(client,	force_name_storage,	cookie,	sizeof(cookie));
	if(StrEqual(cookie,	""))
		cookies(client);
	else if(!StrEqual(cookie,	""))
		SetClientName(client,	cookie);
}

void	cookies(int client)	{
	if(IsClientInGame(client) && !IsFakeClient(client))	{
		char	cookie		[256],
				clientname	[256];
		GetClientCookie(client,	name_storage,	cookie,	sizeof(cookie));
		GetClientName(client,	clientname,	sizeof(clientname));
		if(StrEqual(cookie,	""))
			SetClientCookie(client,	name_storage,	clientname);
		else if(!StrEqual(cookie,	""))
			SetClientName(client,	cookie);
	}
}

public	void	OnClientSettingsChanged(int client)	{
	char	cookie_storedname[256],
			cookie_forcedname[256];
	GetClientCookie(client,	name_storage,		cookie_storedname,	sizeof(cookie_storedname));
	GetClientCookie(client,	force_name_storage,	cookie_forcedname,	sizeof(cookie_forcedname));
	
	if(!StrEqual(cookie_storedname,	""))
		SetClientName(client,	cookie_storedname);
	else if(!StrEqual(cookie_forcedname,	""))
		SetClientName(client,	cookie_forcedname);
}

Action	ForceName(int client,	int args)	{
	if(args != 2)	{
		CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_usage");
		return	Plugin_Handled;
	}
	
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
		char	name[256];
		GetClientName(target,	name,	sizeof(name));
		SetClientCookie(target,	force_name_storage,	name);
	}
	
	CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_set",	target_name,	arg2);
	return	Plugin_Handled;
}

Action	RemoveForceName(int client,	int args)	{
	if(args != 1)	{
		CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_usage_remove");
		return	Plugin_Handled;
	}
	
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
		SetClientCookie(target,	force_name_storage,	"");
	}
	
	CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_set_remove",	target_name);
	
	return	Plugin_Handled;
}

Action	ClearName(int client,	int args)	{
	if(args != 1)	{
		CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_forcename_usage");
		return	Plugin_Handled;
	}
	
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
	}
	
	CPrintToChat(client,	"[Keep Player Name] %t",	"keep_player_name_clearname_set",	target_name);
	
	return	Plugin_Handled;
}