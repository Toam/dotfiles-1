-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Rajout de vicious
vicious = require("vicious")

-- VICIOUS
-- Initialize widget
memwidget = wibox.widget.textbox()
-- Initialize widget
cpuwidget = wibox.widget.textbox()
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1% ")
uptimewidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, " $1% ", 13)
vicious.register(uptimewidget, vicious.widgets.uptime, " $1d")
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, "%R")


-- Load Debian menu entries
--require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
  title = "Oops, there were errors during startup!",
  text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, an error happened!",
    text = err })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/jrousseau/.config/awesome/themes/awesome-themes-3.5/redhalo/theme.lua")

gears.wallpaper.maximized( "/home/jrousseau/lock.png")

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
editor = os.getenv("EDITOR") or "editor"
-- editor_cmd = terminal .. " -e " .. editor
editor_cmd = "kate"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.

tags = {}

tags[1] = awful.tag({ "vim", "mongo", "spotify" }, 1, layouts[1])
tags[2] = awful.tag({ "chrome", "firefox" }, 2, layouts[1])

-- }}}


-- {{{ Wibox
-- Create a textclock widget
os.setlocale("fr_FR.UTF-8") -- Français

-- Create a systray
mysystray = wibox.widget.systray()


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
)

-- Create a promptbox for each screen
mypromptbox[1] = awful.widget.prompt()
mypromptbox[2] = awful.widget.prompt()

-- Create the wibox

mywibox[1] = awful.wibox({ position = "top", screen = 1, height = "20" })
mywibox[2] = awful.wibox({ position = "top", screen = 2, height = "20" })

local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(awful.widget.taglist(1, awful.widget.taglist.filter.all, mytaglist.buttons))
left_layout:add(mypromptbox[1])

local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(memwidget)
right_layout:add(cpuwidget)
right_layout:add(uptimewidget)

local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_right(right_layout)

mywibox[1]:set_widget(layout)

local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(awful.widget.taglist(2, awful.widget.taglist.filter.all, mytaglist.buttons))
left_layout:add(mypromptbox[2])

local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(datewidget)

local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_right(right_layout)

mywibox[2]:set_widget(layout)


-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))


-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
awful.key({ modkey, "Control"    }, "l", function () awful.util.spawn("i3lock -i /home/jrousseau/lock.png") end),
awful.key({ modkey, "Shift"    }, "s", function () awful.util.spawn("konsole -e tmuxinator start polka") end),
awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

awful.key({ modkey,           }, "j",
function ()
  awful.client.focus.byidx( 1)
  if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "k",
function ()
  awful.client.focus.byidx(-1)
  if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
awful.key({ modkey,           }, "Tab",
function ()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
awful.key({ modkey, "Control" }, "r", awesome.restart),
awful.key({ modkey, "Shift"   }, "q", awesome.quit),

awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),


awful.key({ modkey, "Control" }, "n", awful.client.restore),

-- Prompt
awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

awful.key({ modkey }, "x",
function ()
  awful.prompt.run({ prompt = "Run Lua code: " },
  mypromptbox[mouse.screen].widget,
  awful.util.eval, nil,
  awful.util.getdir("cache") .. "/history_eval")
end)
)

clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
awful.key({ modkey,           }, "n",
function (c)
  -- The client currently has the input focus, so it cannot be
  -- minimized, since minimized clients can't have the focus.
  c.minimized = true
end),
awful.key({ modkey,           }, "m",
function (c)
  c.maximized_horizontal = not c.maximized_horizontal
  c.maximized_vertical   = not c.maximized_vertical
end)
)

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
  properties = { border_width = beautiful.border_width,
  border_color = beautiful.border_normal,
  focus = true,
  keys = clientkeys,
  buttons = clientbuttons } },
  { rule = { class = "MPlayer" },
  properties = { floating = true } },
  { rule = { class = "pinentry" },
  properties = { floating = true } },
  { rule = { class = "gimp" },
  properties = { floating = true } },
  -- Set Firefox to always map on tags number 2 of screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--os.execute("konsole -e tmuxinator start polka &")
