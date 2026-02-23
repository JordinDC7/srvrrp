# Server Command Reference (Players + Admins)

This is a practical command list for daily use on this DarkRP server.

## How to run commands

- **Chat commands**: type in chat with `/` (example: `/job Gun Dealer`).
- **ULX chat shortcuts**: type in chat with `!` (example: `!goto playername`).
- **Console commands**: open console (`~`) and run the `ulx ...` variant.

---

## Player commands (most used)

### Communication & roleplay
- `/ooc <message>`: out-of-character global chat.
- `/pm <player> <message>`: private message.
- `/me <action>`: roleplay action text.
- `/y <message>`: yell.
- `/w <message>`: whisper.
- `/advert <message>`: paid ad message.
- `/g <message>`: group chat.

### Identity & money
- `/job <name>`: set custom job title.
- `/rpname <name>` (or `/name`, `/nick`): set RP name.
- `/dropmoney <amount>` (or `/moneydrop`): drop money.
- `/give <amount>`: give money to player you're looking at.
- `/check <player> <amount>` (or `/cheque`): write a cheque.

### Property & doors
- `/toggleown`: buy/sell door you're looking at.
- `/addowner <player>` (or `/ao`): add co-owner.
- `/removeowner <player>` (or `/ro`): remove co-owner.
- `/title <text>`: set door title.
- `/unownalldoors`: sell all owned doors.

### Economy & entities
- `/buy <weapon>`: buy allowed weapon.
- `/buyammo <type>`: buy ammo.
- `/buyshipment <name>`: buy shipment.
- `/buyvehicle <name>`: buy vehicle.
- `/buygunlab`, `/buydruglab`, `/buymoneyprinter`: buy entities.
- `/setprice <amount>` (or `/price`): set sale price for owned entity.

---

## Role-specific player commands

### Civil Protection / Mayor
- `/wanted <player> <reason>`: make player wanted.
- `/unwanted <player>`: remove wanted status.
- `/warrant <player> <reason>`: request search warrant.
- `/lockdown`: start lockdown.
- `/unlockdown`: end lockdown.
- `/placelaws`: place laws board.
- `/addlaw <text>`: add law.
- `/removelaw <id>`: remove law.
- `/broadcast <message>`: mayor broadcast.

### Gun dealer / workers
- `/makeshipment`: convert held weapon into shipment.
- `/splitshipment`: split shipment you're looking at.

### Hitman / criminal
- `/hitprice <amount>`: set hit price.
- `/requesthit <player>`: request hit.

---

## Staff/Admin commands (ULX)

> Tip: most ULX commands work as both chat (`!command`) and console (`ulx command`).

### Moderation
- `!kick <player> <reason>` / `ulx kick <player> <reason>`
- `!ban <player> <minutes> <reason>` / `ulx ban ...`
- `!banid <steamid> <minutes> <reason>` / `ulx banid ...`
- `!unban <steamid>` / `ulx unban <steamid>`
- `!mute <player>` / `ulx mute <player>`
- `!gag <player>` / `ulx gag <player>`
- `!gimp <player>` / `ulx gimp <player>`

### Movement & supervision
- `!goto <player>` / `ulx goto <player>`
- `!bring <player>` / `ulx bring <player>`
- `!send <player1> <player2>` / `ulx send ...`
- `!return <player>` / `ulx return <player>`
- `!spectate <player>` / `ulx spectate <player>`
- `!tp <player1> <player2>` / `ulx teleport ...`

### Utility / admin flow
- `!asay <message>` / `ulx asay <message>`
- `!csay <message>` / `ulx csay <message>`
- `!tsay <message>` / `ulx tsay <message>`
- `!vote <question>` / `ulx vote ...`
- `!stopvote` / `ulx stopvote`
- `!map <mapname>` / `ulx map <mapname>`
- `ulx who`: list users and groups.
- `ulx debuginfo`: print ULX debug info.

### Advanced (senior admin only)
- `!cexec <player> <command>` / `ulx cexec ...`
- `!rcon <command>` / `ulx rcon ...`
- `ulx luarun <lua>`
- `ulx exec <cfgfile>`

---

## Helpful vanilla/server console commands

### For players
- `status`: show server + connected players.
- `retry`: reconnect to current server.
- `disconnect`: leave server.
- `record <name>` / `stop`: start/stop demo recording.

### For server operators
- `changelevel <map>`: switch map.
- `writeid`: write users to banned list.
- `writeip`: write banned IP list.
- `hostname "<name>"`: set server name.
- `sv_password "<password>"`: set/remove join password.

---

## Safety / operations notes

- Prefer `ulx` commands over ad-hoc lua/rcon when possible (auditability + lower risk).
- Always include clear ban/kick reasons.
- Test high-impact commands (`map`, `rcon`, `luarun`) on off-peak hours where possible.
- Keep this file updated whenever new admin addons or chat commands are added.
