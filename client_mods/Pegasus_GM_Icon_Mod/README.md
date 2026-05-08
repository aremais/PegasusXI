# Pegasus GM Icon Client Mod

Client-side DAT/UI mod for the Pegasus GM/nameplate icon.

## Status

The actual patched DAT is not committed to this repository because the CI sanity checker reads changed files as UTF-8 text, and binary DAT files fail that check.

The patched DAT should be distributed separately to the admin/client pack maintainer.

## Patched file to distribute separately

ROM\119\51.DAT

## Edited texture

menu ustatshd

## Confirmed test

Confirmed working in-game with:

!togglegm

## Install notes

This is not a server-side code change. It must be distributed with the client files or XIPivot/XIView overlay.

Recommended install locations:

Direct client replacement:

SquareEnix\FINAL FANTASY XI\ROM\119\51.DAT

XIView/XIPivot overlay replacement:

polplugins\DATs\xiview\ROM\119\51.dat

If XIView is shipped with the client, patch the XIView overlay copy too because it can override the base ROM file.

## Admin notes

Open ROM\119\51.DAT in TexHammer and edit the texture:

menu ustatshd

Texture info:

DXT3
256x256

The working Pegasus icon size was around 13x13 to 15x15 px.
