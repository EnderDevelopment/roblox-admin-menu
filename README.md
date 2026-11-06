# FiveM Admin Menu Resource

Ender Admin is a standalone FiveM administration menu resource with a custom NUI interface for server management and player moderation. This FiveM admin script provides player management, online player search, teleportation, player bringing, healing, reviving, freeze controls, kick functionality, and server-wide announcements. It uses ACE permissions for server-side authorization and does not require ESX, QBCore, or other frameworks.

## Install

1. Download or clone the project repository.
2. Place the `ender_admin` folder inside your FiveM server's `resources` directory.
3. Add the following line to your `server.cfg`:

   `ensure ender_admin`

4. Configure the ACE permission in your server configuration:

   `add_ace group.admin ender.admin allow`

5. Add your authorized administrators to the appropriate ACE group using your server's existing permission setup.
6. Review `config.lua` to customize the admin command, permission node, opening key, and input limits.
7. Restart your FiveM server or start the resource.

## Use

1. Join your FiveM server with an authorized administrator account.
2. Open the administration menu using `/admin` or the default `F10` key.
3. Use the Players section to browse currently connected players.
4. Search players by their name or server ID.
5. Select a player to access the available management actions:
   - Teleport to the selected player.
   - Bring the selected player to your location.
   - Heal the selected player.
   - Revive the selected player.
   - Freeze or unfreeze the selected player.
   - Kick the selected player with an optional reason.
6. Use the Announcements section to send a message to everyone currently online.
7. Confirm actions that require confirmation before they are submitted.
8. Press Escape or use the close button to close the menu.

Server administrators can customize the configuration in `config.lua`. All privileged server actions are checked against ACE permissions on the server.

---

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/e9583345-ae98-47ec-8a95-14733ed26b52?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=e9583345-ae98-47ec-8a95-14733ed26b52
