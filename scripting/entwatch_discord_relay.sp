#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <entwatch>
#include <discord>

ConVar g_cvEWRelay_Enable;
ConVar g_cvEWRelay_Webhook;

bool g_bEWRelayEnable;
char g_sEWRelayWebhook[PLATFORM_MAX_PATH];

public Plugin myinfo =
{
    name = "Entwatch Discord Relay",
    author = "koen",
    description = "Send entwatch eban/eunban notifications to discord",
    version = "1.1",
    url = "https://steamcommunity.com/id/notkoen/"
};

public void OnPluginStart()
{
    // Convars
    g_cvEWRelay_Enable = CreateConVar("sm_ewrelay_enable", "1", "Toggle entwatch notification system", _, true, 0.0, true, 1.0);
    g_cvEWRelay_Webhook = CreateConVar("sm_ewrelay_webhook", "", "Discord webhook link");
    AutoExecConfig(true);

    // Hook convar changes
    HookConVarChange(g_cvEWRelay_Enable, OnConvarChange);
    HookConVarChange(g_cvEWRelay_Webhook, OnConvarChange);
}

public void OnConfigsExecuted()
{
    g_bEWRelayEnable = g_cvEWRelay_Enable.BoolValue;
    GetConVarString(g_cvEWRelay_Webhook, g_sEWRelayWebhook, sizeof(g_sEWRelayWebhook));
}

public void OnConvarChange(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    if (cvar == g_cvEWRelay_Enable)
        g_bEWRelayEnable = g_cvEWRelay_Enable.BoolValue;
    else if (cvar == g_cvEWRelay_Webhook)
        GetConVarString(g_cvEWRelay_Webhook, g_sEWRelayWebhook, sizeof(g_sEWRelayWebhook));
}

public void EntWatch_OnClientBanned(int admin, int duration, int client, const char[] reason)
{
    if (strlen(g_sEWRelayWebhook) == 0)
    {
        LogError("[EW-Relay] Invalid or no webhook specified in plugin config!");
    }
    else if (g_bEWRelayEnable)
    {
        DiscordWebHook hook = new DiscordWebHook(g_sEWRelayWebhook);

        hook.SetContent("A player has been **ebanned!**");
        hook.SetUsername("Entwatch Notification");

        MessageEmbed Embed = new MessageEmbed();

        Embed.SetColor(0xff0000);
        Embed.SetTitle("Eban Notification");

        // Admin Information
        char sAdmin_SteamID[64], sAdmin_Buffer[128];
        GetClientAuthId(admin, AuthId_Steam2, sAdmin_SteamID, sizeof(sAdmin_SteamID));
        FormatEx(sAdmin_Buffer, sizeof(sAdmin_Buffer), "%N (%s)", admin, sAdmin_SteamID);
        Embed.AddField("Admin:", sAdmin_Buffer, true);

        // Player Information
        char sPlayer_SteamID[64], sPlayer_Buffer[128];
        GetClientAuthId(client, AuthId_Steam2, sPlayer_SteamID, sizeof(sPlayer_SteamID));
        FormatEx(sPlayer_Buffer, sizeof(sPlayer_Buffer), "%N (%s)", client, sPlayer_SteamID);
        Embed.AddField("Player:", sPlayer_Buffer, true);

        // Duration
        char sDurationBuffer[8];
        FormatEx(sDurationBuffer, sizeof(sDurationBuffer), "%d", duration);
        Embed.AddField("Duration:", sDurationBuffer, true);

        // Reason
        Embed.AddField("Reason:", reason, false);

        // Time stamp
        Embed.SetTimeStamp(GetTime() - (8 * 3600));

        hook.Embed(Embed);
        hook.Send();
        delete hook;
    }
}

public void EntWatch_OnClientUnbanned(int admin, int client, const char[] reason)
{
    if (strlen(g_sEWRelayWebhook) == 0)
    {
        LogError("[EW-Relay] Invalid or no webhook specified in plugin config!");
    }
    else if (g_bEWRelayEnable)
    {
        DiscordWebHook hook = new DiscordWebHook(g_sEWRelayWebhook);

        hook.SetContent("A player has been **eunbanned!**");
        hook.SetUsername("Entwatch Notification");

        MessageEmbed Embed = new MessageEmbed();

        Embed.SetColor(0x00ff00);
        Embed.SetTitle("Eunban Notification");

        // Admin Information
        char sAdmin_SteamID[64], sAdmin_Buffer[128];
        GetClientAuthId(admin, AuthId_Steam2, sAdmin_SteamID, sizeof(sAdmin_SteamID));
        FormatEx(sAdmin_Buffer, sizeof(sAdmin_Buffer), "%N (%s)", admin, sAdmin_SteamID);
        Embed.AddField("Admin:", sAdmin_Buffer, true);

        // Player Information
        char sPlayer_SteamID[64], sPlayer_Buffer[128];
        GetClientAuthId(client, AuthId_Steam2, sPlayer_SteamID, sizeof(sPlayer_SteamID));
        FormatEx(sPlayer_Buffer, sizeof(sPlayer_Buffer), "%N (%s)", client, sPlayer_SteamID);
        Embed.AddField("Player:", sPlayer_Buffer, true);

        // Reason
        Embed.AddField("Reason:", reason, false);

        // Time stamp
        Embed.SetTimeStamp(GetTime() - (8 * 3600));

        hook.Embed(Embed);
        hook.Send();
        delete hook;
    }
}
