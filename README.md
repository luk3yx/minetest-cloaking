# Minetest cloaking mod

Allows players to cloak and uncloak.

## What is cloaking?

In this instance, cloaking is a way to go invisible and become undetectable by
most mods (unless they explicitly want to detect cloaked players, so they can
still send chat messages to them).

## Why is cloaking so hacky, and where does it send the 'left the game' messages?

Cloaking sends no left the game messages, it leaves that up to the built-in left
the game functions. The aim of cloaking is to trick other mods into thinking the
player is not in-game, and for this it must be hacky.

## Help, it crashes

If it crashes, it is either caused by a mod not liking non-existent players
running around, or by a bug in cloaking itself.

## How do I use cloaking?

Cloaking adds a modding API and two chatcommands. Both of these require the
`cloaking` privilege to execute, however you can uncloak yourself without any
privileges.

- `/cloak [victim]`: Cloaks yourself, alternatively an unsuspecting `victim`.
- `/uncloak [victim]`: Uncloaks yourself, or a `victim`.

## How do I download cloaking?

You can either run
`git clone https://github.com/luk3yx/minetest-cloaking cloaking`, or download
a  [zip](https://github.com/luk3yx/minetest-cloaking/archive/master.zip) or
[tar.gz](https://github.com/luk3yx/minetest-cloaking/archive/master.tar.gz)
file. You will need to rename the folder from `minetest-cloaking-master` to
`cloaking` for it to work properly.

## How do I use the API?

Cloaking adds the following functions:

- `cloaking.cloak_player(player)`: Cloaks a player.
- `cloaking.uncloak_player(player)`: Uncloaks a player.
- `cloaking.get_cloaked_players()`: Gets a list of cloaked player names.
- `cloaking.is_cloaked(player)`: Checks if a player is cloaked.
- `cloaking.on_chat_message(player, message)`: Returns `true` and warns `player`
    if they are cloaked and trying to send a chat message, otherwise returns
    `nil`.

It also adds the following functions that ignore cloaked players and can
interact with them:
`cloaking.get_connected_players`, `cloaking.get_objects_inside_radius` and
`cloaking.get_player_by_name`.

If you want your chatcommand to work with cloaked players, you can add
`_allow_while_cloaked = true` to the chatcommand definition. This does not
require that you add `cloaking` to `depends.txt`, as when cloaking is not loaded
this parameter is simply ignored.
