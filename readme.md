# Hammerspoon × Yabai config

## Index

- Why
- Contents
    - `.yabairc`
    - `.hammerspoon/init.lua`
    - `.hammerspoon/windowAction.lua`
- How to use it
    - Directions and actions
    - Space layout
    - Insert rule
    - Move mouse to display
    - Move window to display
    - Resize mode
    - Debug
    - Windows actions

My personal workspace configuration I use at work.

## Why?

I wanted to use tiled window manager on MacOS, I found Yabai as a great candidate for this:

- CLI commands only _(no cluttered GUI)_
- Lightweigth
- Installation with `brew` _(no Appstore)_

I installed Yabai _without disabling SIP_. Much features were not so useful and I didn’t want to risk exposing my work computer to some flaws _(including me!)_.

I already have Hammerspoon installed and was pretty happy with it so I decided to use it for hotkey configurations:

- Fully customisable with lua 👍
- You can draw stuff on screen
- You can do a lot more stuff with, event window management!

Note this is a very early setting and I’m still configuring this day to day. I’m seeing this much like a evolving tool I shape for my current needs.

Also, **big notice**, this is optimised for full keyboard use with **BÉPO**, a french first keyboard layout.

I added the corresponding **QWERTY** keys commented in front of the line so you can figure the actual layout. I also made the `.initqwerty.lua` file with the replaced hotkeys for ease.

## Contents

### `.yabairc`

Startup file for Yabai, it configures global settings, adds some rules for certain windows and adds signals to communicate with hammerspoon.

### `.hammerspoon/init.lua`

My hammerspoon main config file. Originaly it was a huge file but I started fragmenting it in several pieces to make it more digest to read. I tried to segment its content in different categories:

- `require`, constrants, images
- actions from my `windowAction` class
- helpers
    - yabai command
    - toast
    - global chooser
- bindings
    - general purpose
    - define space layout
    - window actions _(rotate, fullscreen-focus, toggle float)_
    - focus change
    - window ratio
    - modals
        - focus display
        - window insert rule
        - change window screen
        - resize window
    - debug
- callbacks
    - respond to window events _(focus, resize, move)_
    - draw window borders
    - yabai queries
    - yabai ipc

All of my shortcuts are triggered with my super key, wich is binded to `⌃⌥` _(control + alt)_. You can change it at the top level of my file in the global variable `super`.

### `.hammerspoon/windowAction.lua`

This is some nice reusable code I made for windows actions. There’s a dedicated section below that explains the use of them.

## How to use it?

I’m glad you ask. Here is how I use it. For simplicity I’ll refer to the `QWERTY` layout keys.

Most of the actions applies to the currently focused window/the space the focused window is.

Some alerts will briefly show with the actions you made, and will persistently show for the modes you enter in. They are just emojis that shows centered as a visual feedback.

Modes are triggered with `hs.modals`, which means you enter them as long as you enter a modal and leaves them when you exit a modal. You can use `escape` to exit modes.

### Directions and actions

`j` `k` `l` `;` keys corresponds to the four directions ⬅️ ⬇️ ⬆️ ➡️.  
You can use them in combination with many other modes.

For example if you use them on their own, `super` + `j` changes the focus to the left _(focus change works only with Yabai’s BSP mode)_.

`t` `g` are for browsing stacks up and down.

`y` `h` `n` stands for **swap**, **stack** and **warp**. They’ll be used later as both modes and actions.

### Space layout

You can switch to **BSP**, **Stacked** and **Float** layout for the current space with `super` + `1`, `2` or `3`

### Insert rule

You can decide which window portion to split for a new window to appear or if you want to stack it.  
Use `super` + `tab` to enter **Insert** mode, then use `super` + a direction or `h` to set the rule. Yabai will color the window portion in red.
If you press `super` + `tab` again, you enter resize mode.

### Move mouse to display

Use `super` + `v` to enter the mode and right or left direction to put your mouse to the next or previous display.

### Move window to display

Use `super` + `b` to enter the mode and right or left direction to send your window to the next or previous display.

### Resize mode

When you are in Insert rule mode, press `super` + `tab` to enter this mode. You can move edges of windows with the directions. This works only in Yabai’s BSP mode for the sides that aren’t on the edge of a screen.

You first use a direction to select horizontal/vertical edge, then all other directions will move it by 20px.

### Debug

This is just for testing purpose. The keystoke `super` + `§` will print the current window details in the console.

### Windows actions

Those are actions that applies to two windows, like swaping, stacking and warping. You first launch the action to select the first window to apply the action, then change focus to the second window, and finally you call that action again to execute the windows action. To quickly explain with an example:

> To swap two windows, you press `super` + `y` to engage swapping, then move your focus to another window with the directions, then you hit `super` + `y` again to effectively swap those two windows.
