# Entwatch Discord Relay

Send eban and eunban notifications to discord.

## Features

- Send eban and eunban notifications to Discord
- Does not require an external discord API plugin to run
- Includes names, IDs, and steam profile links to both admins and the target
- Calculates when issued restrictions will end as a Unix timestamp

## Dependencies

- [Entwatch CSGO DZ](https://github.com/darkerz7/CSGO-Plugins/tree/master/EntWatch_DZ)
- Sarrus' [DiscordWebhookAPI](https://github.com/Sarrus1/DiscordWebhookAPI)

## Installation

- Compile `entwatch_discord_relay.sp` and place it in your plugins folder
- Run the plugin once so it generates the config file
- Edit `plugin.entwatch_discord_relay.cfg` in your `cfg/sourcemod/` folder and put in your discord webhook link

## Modifications

If you are using a different Entwatch plugin outside of DarkerZ's plugin, make sure your version of entwatch has the same if not similar forwards for when you eban and eunban clients, and then update the code accordingly.
