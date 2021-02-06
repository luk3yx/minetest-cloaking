# Minetest cloaking mod

Allows admins to become invisible and appear as if they are not in-game at all.
Inspired by Star Trek's [cloaking device].

[cloaking device]: https://memory-alpha.fandom.com/wiki/Cloaking_device

## What is cloaking?

In this instance, cloaking is a way to go invisible and become undetectable by
most mods (unless they explicitly want to detect cloaked players, so they can
still send chat messages to them).

## Why is cloaking so hacky?

The aim of cloaking is to trick other mods into thinking the player is not
in-game, and a lot of hacks are used to do this.

## Help, it crashes

If it crashes, it is either caused by a mod not liking non-existent players
running around, or by a bug in cloaking itself.

## How do I use cloaking?

Cloaking adds a modding API and some chatcommands. All of the chatcommands
require the "cloaking" privilege to execute, with the exception of `/uncloak`
when used on yourself.

- `/cloak [victim]`: Cloaks yourself, alternatively an unsuspecting `victim`.
- `/uncloak [victim]`: Uncloaks yourself, or a `victim`.
- `/cloak_chat <message>`: Sends `<message>` to all online players with the
    `cloaking` privilege.
    - You can disable cloaked chat by adding
      `cloaking.enable_cloaked_chat = false` to minetest.conf.
- `/shadow [victim]`: Attaches you to a player. If `victim` is not specified,
    this command will detach you instead.
    - Requires both the "cloaking" and "teleport" privileges.
    - This command can only be used while cloaked.
    - You can disable this by adding `cloaking.enable_shadow = false` to
      minetest.conf.

## How do I download cloaking?

You can either run
`git clone https://git.minetest.land/luk3yx/cloaking.git` or download this mod
from [ContentDB](https://content.minetest.net/packages/luk3yx/cloaking).

## How do I use the API?

Cloaking adds the following functions:

- `cloaking.cloak(player)`: Cloaks a player.
- `cloaking.uncloak(player)`: Uncloaks a player.
- `cloaking.get_cloaked_players()`: Gets a list of cloaked player names.
- `cloaking.get_connected_names()`: Gets a list of cloaked and uncloaked player
    names.
- `cloaking.is_cloaked(player)`: Checks if a player is cloaked.
- `cloaking.hide_player(player)`: Hides a player without cloaking them.
- `cloaking.unhide_player(player)`: Unhides a player previously hidden with
    `cloaking.hide_player()`.
- `cloaking.chat`: Cloaked chat API, this is `nil` if cloaked chat is disabled.
  - `cloaking.chat.send(message)`: Sends a message to cloaked chat.
  - `cloaking.chat.prefix`: The text (`-Cloaked-`) that is prepended to cloaked
    chat messages before they are sent to players.

*Any above functions requiring "player" as a parameter also accept a player name, provided the player is online.*

It also adds the following functions that ignore cloaked players and can
interact with them:
`cloaking.get_connected_players`, `cloaking.get_objects_inside_radius` and
`cloaking.get_player_by_name`.

If you have made chatcommand work with players that aren't in-game, you can add
`_allow_while_cloaked = true` to the chatcommand definition. If you explicitly
don't want your chatcommand working with cloaked players, you can add
`_disallow_while_cloaked = true` to the definition.
These modifications do not require that you add cloaking as a dependency, as
when cloaking is not loaded this parameter is simply ignored.

## Backported bugfixes

To ensure server stability, the cloaking mod backports the following bugfixes
if it determines they are necessary for your server:

 - Blocking newlines in chat messages (MT < 5.0.1).
 - Prevent saying `%2` in chat from crashing the server (MT == 5.1.0).
 - Prevent hacked clients from being able to access the inventories of other
    players (MT < 5.4.0). *Note that this fix currently needs testing and
    does not work on MT 0.4.*

If you do not want this for whatever reason (although I do not recommend it),
you can disable these backports by adding `cloaking.backport_bugfixes = false`
to your minetest.conf.
