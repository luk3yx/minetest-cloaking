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
running around, or by a bug in cloaking. At the moment, cloaking is known to
crash with `instrumentation` enabled, as that overrides built-in functions.

## How do I use cloaking?

Cloaking adds a modding API and two chatcommands. Both of these require the
`privs` priv to execute, however you can uncloak yourself without any priv.

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

It also adds the following functions that ignore cloaked players and can
interact with them:
`cloaking.get_connected_players`, `cloaking.get_objects_inside_radius` and
`cloaking.get_player_by_name`.
