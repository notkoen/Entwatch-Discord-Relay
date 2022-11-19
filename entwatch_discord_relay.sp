#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <EntWatch>
#include <discordWebhookAPI>

ConVar g_cvEnable;
ConVar g_cvWebhook;

public Plugin myinfo =
{
    name = "Entwatch Discord Relay",
    author = "koen",
    description = "Send entwatch eban/eunban notifications to discord",
    version = "1.3.2", // New API & code refactoring
    url = "https://github.com/notkoen"
};

public void OnPluginStart()
{
    // Convars
    g_cvEnable = CreateConVar("sm_ewrelay_enable", "1", "Toggle entwatch notification system", _, true, 0.0, true, 1.0);
    g_cvWebhook = CreateConVar("sm_ewrelay_webhook", "", "Discord webhook link", FCVAR_PROTECTED);
    AutoExecConfig(true);
}

public void EntWatch_OnClientBanned(int admin, int duration, int client, const char[] reason)
{
    if (!g_cvEnable.BoolValue) return;
    
    char buffer[PLATFORM_MAX_PATH], SteamID2[64], SteamID64[64];
    g_cvWebhook.GetString(buffer, sizeof(buffer));
    
    if (buffer[0] == '\0')
    {
        LogError("[EW-Relay] Invalid or no webhook specified in plugin config!");
        return;
    }
    
    Webhook hook = new Webhook("A player has been **ebanned!**");

    Embed Embed1 = new Embed();
    Embed1.SetColor(0xff0000);
    Embed1.SetTitle("Eban Notification");
    Embed1.SetTimeStampNow();

    // Admin Information
    GetClientAuthId(admin, AuthId_Steam2, SteamID2, sizeof(SteamID2));
    GetClientAuthId(admin, AuthId_SteamID64, SteamID64, sizeof(SteamID64));
    Format(buffer, sizeof(buffer), "%N ([%s](https://steamcommunity.com/profiles/%s))", admin, SteamID2, SteamID64);
    EmbedField field1 = new EmbedField("Admin:", buffer, false);
    Embed1.AddField(field1);

    // Player Information
    GetClientAuthId(client, AuthId_Steam2, SteamID2, sizeof(SteamID2));
    GetClientAuthId(client, AuthId_SteamID64, SteamID64, sizeof(SteamID64));
    Format(buffer, sizeof(buffer), "%N ([%s](https://steamcommunity.com/profiles/%s))", client, SteamID2, SteamID64);
    EmbedField field2 = new EmbedField("Player:", buffer, false);
    Embed1.AddField(field2);

    // Duration
    switch (duration)
    {
        case -1:
        {
            Format(buffer, sizeof(buffer), "Temporary");
        }
        case 0:
        {
            Format(buffer, sizeof(buffer), "Permanent");
        }
        default:
        {
            int ctime = GetTime();
            int finaltime = ctime + (duration * 60);
            Format(buffer, sizeof(buffer), "%d Minute%s \n(to <t:%d:f>)", duration, duration > 1 ? "s" : "", finaltime);
        }
    }
    EmbedField field3 = new EmbedField("Duration:", buffer, true);
    Embed1.AddField(field3);

    // Reason
    if (reason[0] != '\0')
    {
        Format(buffer, sizeof(buffer), "%s", reason);
    }
    else
    {
        Format(buffer, sizeof(buffer), "​"); // Perm-ebans can have no reason. This breaks embed, so use zero-width charcter as a filler to fix this
    }
    EmbedField field4 = new EmbedField("Reason:", buffer, false);
    Embed1.AddField(field4);

    hook.AddEmbed(Embed1);
    g_cvWebhook.GetString(buffer, sizeof(buffer));
    hook.Execute(buffer, OnWebHookExecuted);
    delete hook;
}

public void EntWatch_OnClientUnbanned(int admin, int client, const char[] reason)
{
    if (!g_cvEnable.BoolValue) return;
    
    char buffer[PLATFORM_MAX_PATH], SteamID2[64], SteamID64[64];
    g_cvWebhook.GetString(buffer, sizeof(buffer));
    
    if (buffer[0] == '\0')
    {
        LogError("[EW-Relay] Invalid or no webhook specified in plugin config!");
        return;
    }
    
    Webhook hook = new Webhook("A player has been **eunbanned!**");

    Embed Embed1 = new Embed();
    Embed1.SetColor(0x00ff00);
    Embed1.SetTitle("Eunban Notification");
    Embed1.SetTimeStampNow();

    // Admin Information
    GetClientAuthId(admin, AuthId_Steam2, SteamID2, sizeof(SteamID2));
    GetClientAuthId(admin, AuthId_SteamID64, SteamID64, sizeof(SteamID64));
    Format(buffer, sizeof(buffer), "%N ([%s](https://steamcommunity.com/profiles/%s))", admin, SteamID2, SteamID64);
    EmbedField field2 = new EmbedField("Admin:", buffer, false);
    Embed1.AddField(field2);

    // Player Information
    GetClientAuthId(client, AuthId_Steam2, SteamID2, sizeof(SteamID2));
    GetClientAuthId(client, AuthId_SteamID64, SteamID64, sizeof(SteamID64));
    Format(buffer, sizeof(buffer), "%N ([%s](https://steamcommunity.com/profiles/%s))", client, SteamID2, SteamID64);
    EmbedField field3 = new EmbedField("Player:", buffer, false);
    Embed1.AddField(field3);

    // Reason
    EmbedField field4 = new EmbedField("Reason:", reason, false);
    Embed1.AddField(field4);

    hook.AddEmbed(Embed1);
    g_cvWebhook.GetString(buffer, sizeof(buffer));
    hook.Execute(buffer, OnWebHookExecuted);
    delete hook;
}

public void OnWebHookExecuted(HTTPResponse response, any data)
{
    if (response.Status != HTTPStatus_OK)
    {
        LogError("[EW-Relay] An error occured while sending eban/eunban webhook to discord!");
        return;
    }
}