# Entwatch Discord Relay
Send eban and eunban notifications to discord

## Dependencies
- [Entwatch CSGO DZ](https://github.com/darkerz7/CSGO-Plugins/tree/master/EntWatch_DZ)
- [My fork of Sourcemod-Discord](https://github.com/notkoen/sourcemod-discord) *(Note: Plugin is coded using modified `discord.inc`/`discord-api.smx` so you must use my fork)

## Installation
- Put `entwatch_discord_relay` in your plugins folder
- Edit `plugin.entwatch_discord_relay.cfg` in your `cfg/sourcemod/` folder and put in your discord webhook link

## Modifications
Because this plugin is coded to work with my modified version of [Sourcemod-Discord](https://github.com/notkoen/sourcemod-discord), those that want to use the original Sourcemod-Discord plugin should update `Embed.SetColor` to use a string as my modifications uses an integer instead. As for your own entwatch plugin, make sure your version of entwatch has forwards for when you eban and eunban clients, and then update the forwards in the plugins as needed.