-- NOTE: IN order to move around windows mjolnir must have access to Accessibility
-- This can be set in Security & Privacy properties

-- local files
dofile(package.searchpath("utils", package.path))

-- adds some functionality to bg.grid
dofile(package.searchpath("grid", package.path))

local homeDir = os.getenv("HOME")
local log = hs.logger.new('jjr-init','info')
local workFile = homeDir .. "/.hsenv"

log.i('Initializing')

--------------------------------------------------------------
---
--- Auto updates
---
--------------------------------------------------------------


-- save the time when updates are checked
function checkforupdates()
   updates.check()
   settings.set('lastcheckedupdates', os.time())
end

local function fileExists(filename)
   return hs.fs.attributes(filename) ~= nil
end

local function isWorkConfig(filename)
   return fileExists(workFile)
end

--------------------------------------------------------------
---
--- Keybindings
---
--------------------------------------------------------------
local minimash = {"alt", "ctrl"}
local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "ctrl", "shift"}

-- hs.hotkey.bind(mash, 'X', logger.show)
-- hs.hotkey.bind(mash, "R", repl.open)
hs.hotkey.bind(mashshift, "c", hs.console.getConsole) -- doesn't work
hs.hotkey.bind(mashshift, "e", "Reloading Hammerspoon Config",  function()
                  hs.alert.show("Reloaded Hammerspoon config")
		  hs.reload()
end		  
)

-- App keybindings

-- return a function to bind to hs.hotkey for launching the specified app
local function launch_fn(app)
   return function() hs.application.launchOrFocus(app) end
end

-- hs.hotkey.bind({"alt"}, '1', launch_fn("iTerm"))
hs.hotkey.bind({"alt"}, '1', launch_fn("kitty"))
hs.hotkey.bind({"alt", "shift"}, '1', launch_fn("Conductor"))
-- editors
hs.hotkey.bind({"alt"}, '2', launch_fn("Emacs"))
hs.hotkey.bind({"alt", "shift"}, '2', launch_fn("Emacs"))
hs.hotkey.bind({"ctrl", "shift"}, '2', launch_fn("Emacs"))

hs.hotkey.bind({"alt"}, '3', launch_fn("Finder"))
hs.hotkey.bind({"alt"}, '4', launch_fn("Slack"))
-- hs.hotkey.bind({"alt", "shift"}, '4', launch_fn("Pulse SMS"))
hs.hotkey.bind({"alt", "shift"}, '4', launch_fn("Android Messages"))
hs.hotkey.bind({"alt"}, '5', launch_fn("Todoist"))
hs.hotkey.bind({"alt", "shift"}, '5', launch_fn("TogglDesktop"))
hs.hotkey.bind({"alt"}, '6', launch_fn("zoom.us"))
hs.hotkey.bind({"alt", "shift"}, '6', launch_fn("Granola"))
hs.hotkey.bind({"alt"}, '7', launch_fn("Google Chrome"))
-- firefox starts in safe mode if alt is pressed on launch so this happens because I have my key repeat set really fast
hs.hotkey.bind({"alt", "shift"}, '8', launch_fn("Brave Browser"))
hs.hotkey.bind({"alt"}, '8', launch_fn("Dia"))
hs.hotkey.bind({"alt"}, '9', launch_fn("Obsidian"))
hs.hotkey.bind({"alt", "shift"}, '9', launch_fn("Kontakt 7"))
hs.hotkey.bind({"alt"}, '0', launch_fn("MuseScore 4"))
hs.hotkey.bind({"alt", "shift"}, '0', launch_fn("YouTube Music"))

-- https://gist.github.com/lancethomps/a5ac103f334b171f70ce2ff983220b4f
hs.hotkey.bind(mash, '0', launch_fn("Notification Dismisser"))


hs.hotkey.bind({"control", "shift", "command"}, 'q',
   function() 
      os.execute('pmset sleepnow') 
end)

-- puts display to sleep
hs.hotkey.bind(mashshift, 'l', 
               function() 
                  os.execute('pmset sleepnow') 

               end
)

-- claude code executive assistant 
hs.hotkey.bind(mashshift, 'r', 
               function() 
                  os.execute('~/ea/scripts/save-transcript.sh') 

               end
)


hs.hotkey.bind({"control", "shift", "command"}, '1',
   function()
      log.i('Output set to MacBook Pro Speakers')
      local success, reason, code = os.execute('/opt/homebrew/bin/SwitchAudioSource -t output -s "MacBook Pro Speakers"')
      --log.i("Success: " .. success .. " Reason: " .. reason)
end)
hs.hotkey.bind({"control", "shift", "command"}, '2',
   function()
      log.i('Output set to CalDigit TS4 Audio - Front')
      local success, reason, code = os.execute('/opt/homebrew/bin/SwitchAudioSource -t output -s "CalDigit TS4 Audio - Front"')
      --log.i("Success: " .. success .. " Reason: " .. reason)
end)
hs.hotkey.bind({"control", "shift", "command"}, '3',
   function()
      log.i('Output set to Vocaster One USB')
      local success, reason, code = os.execute('/opt/homebrew/bin/SwitchAudioSource -t output -s "Vocaster One USB"')
	 --log.i("Success: " .. success .. " Reason: " .. reason)
end)



-- Just use cmd-ctrl-Q on the mac
-- hs.hotkey.bind(mashshift, 'l', 
--                function() 
--                   hs.caffeinate.lockScreen()
--                end
-- )


--------------------------------------------------------------
---
--- Grid and window movement
---
-------------------------------------------------------------- 

-- use the whole screen
hs.grid.setMargins(hs.geometry(0,0))
hs.grid.setGrid("12x2")


hs.hotkey.bind(minimash, ';', hs.grid.show)
hs.hotkey.bind(minimash, 'U', hs.grid.maximizeWindow)
hs.hotkey.bind(minimash, 'J', hs.grid.pushWindowDown)
hs.hotkey.bind(minimash, 'K', hs.grid.pushWindowUp)
hs.hotkey.bind(mash, 'K', hs.grid.pushWindowTopHalf)
-- hs.hotkey.bind(mash, 'J', hs.grid.pushWindowBottomHalf)
-- hs.hotkey.bind(minimash, 'H', hs.grid.pushWindowLeftAndResize)
-- hs.hotkey.bind(minimash, 'L', hs.grid.pushWindowRightAndResize)
hs.hotkey.bind(mash, 'H', hs.grid.pushWindowLeftThird)
hs.hotkey.bind(mash, 'J', hs.grid.pushWindowMiddle)
hs.hotkey.bind(mash, 'L', hs.grid.pushWindowRightThird)

hs.hotkey.bind(minimash, 'H', hs.grid.pushWindowLeft)
hs.hotkey.bind(minimash, 'L', hs.grid.pushWindowRight)
hs.hotkey.bind(minimash, 'P', hs.grid.pushWindowTopRight)
hs.hotkey.bind(minimash, '.', hs.grid.pushWindowBottomRight)
hs.hotkey.bind(minimash, 'Y', hs.grid.pushWindowTopLeft)
hs.hotkey.bind(minimash, 'B', hs.grid.pushWindowBottomLeft)

local function moveWindowToLeftScreen()
   local win = hs.window.focusedWindow()
   if not win then return end -- No window focused

   local currentScreen = win:screen()
   hs.alert.show(currentScreen)
   local westScreen = currentScreen:neighborWest() -- Find the screen to the left

   if westScreen then
      win:moveToScreen(westScreen)
   else
      hs.alert.show("Already on the leftmost screen")
   end
end
local function moveWindowToRightScreen()
   local win = hs.window.focusedWindow()
   if not win then return end -- No window focused

   local currentScreen = win:screen()
   if not currentScreen then return end 
   local eastScreen = currentScreen:neighborEast() 

   if eastScreen then
      win:moveToScreen(eastScreen)
   else
      hs.alert.show("Already on the rightmost screen")
   end
end

function moveWindowToDisplay(d)
   return function()
      local displays = hs.screen.allScreens()
      local win = hs.window.focusedWindow()
      win:moveToScreen(displays[d], false, true)
   end
end

-- 1. Create a modal object.
--    This object will hold the keybindings that are ONLY active
--    after you press the initial hotkey.
local myTwoStepMode = hs.hotkey.modal.new()

-- 2. Define what happens when you press 'J' *while the mode is active*.
myTwoStepMode:bind("", "A", function()
		      hs.grid.pushWindowLeftHalf()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "D", function()
		      hs.grid.pushWindowRightHalf()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "Q", function()
		      hs.grid.pushWindowTopLeft()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "E", function()
		      hs.grid.pushWindowTopRight()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "Z", function()
		      hs.grid.pushWindowBottomLeft()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "C", function()
		      hs.grid.pushWindowBottomRight()
		      myTwoStepMode:exit() 
end)

myTwoStepMode:bind("shift", "A", function()
		      hs.grid.pushWindowLeftThird()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("shift", "D", function()
		      hs.grid.pushWindowRightThird()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "S", function()
		      hs.grid.pushWindowMiddle()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("", "W", function()
		      hs.grid.maximizeWindow()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("ctrl", "A", function()
		      hs.grid.pushWindowLeft()		      
end)
myTwoStepMode:bind("ctrl", "D", function()
		      hs.grid.pushWindowRight()
end)
myTwoStepMode:bind("cmd", "A", function()
		      moveWindowToDisplay(2)()
		      myTwoStepMode:exit() 
end)
myTwoStepMode:bind("cmd", "D", function()
		      moveWindowToDisplay(1)()
		      myTwoStepMode:exit() 
end)

-- bail out
myTwoStepMode:bind("", "escape", function()
		      myTwoStepMode:exit()
end)
-- 3. Bind the initial key combination ('ctrl + alt + H') to ENTER the modal state.
hs.hotkey.bind({"ctrl", "shift"}, 'A', function()
      myTwoStepMode:enter()
end)

function myLayoutComms()
   local mainScreen = hs.screen.allScreens()[1]
   local secondScreen = hs.screen.allScreens()[2]

   if secondScreen then
      hs.application.launchOrFocus("Firefox")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,1,2), secondScreen)

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(1,0,1,2), secondScreen)

      hs.application.launchOrFocus("Slack")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(1,0,1,2), mainScreen)

      hs.application.launchOrFocus("Todoist")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,1,2), mainScreen)
   else
      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.pushWindowLeftHalf()

      hs.application.launchOrFocus("Slack")
      os.execute("sleep .2")
      hs.grid.pushWindowTopRight()

      hs.application.launchOrFocus("Todoist")
      os.execute("sleep .2")
      hs.grid.pushWindowBottomRight()
      
   end
end


function myLayoutFrontEndDevelopment()
   local mainScreen = hs.screen.allScreens()[1]
   local secondScreen = hs.screen.allScreens()[2]

   if secondScreen then
      hs.application.launchOrFocus("Emacs")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(1,0,1,2), secondScreen)

      hs.application.launchOrFocus("iTerm")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,1,2), secondScreen)

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,2,2), mainScreen)
   else
      hs.application.launchOrFocus("Emacs")
      os.execute("sleep .2")
      hs.grid.pushWindowLeftHalf()


      hs.application.launchOrFocus("iTerm")
      os.execute("sleep .2")
      hs.grid.pushWindowLeftHalf()

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.pushWindowRightHalf()
   end 
end

function myLayoutDebugging()
   local mainScreen = hs.screen.allScreens()[1]
   local secondScreen = hs.screen.allScreens()[2]

   if secondScreen then
      hs.application.launchOrFocus("iTerm")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,1,2), secondScreen)

      intellijWindows = hs.application.allWindows(hs.application("Intellij IDEA"))
      for k, v in pairs(intellijWindows) do
         os.execute("sleep .2")
         hs.grid.set(v, hs.geometry(1,0,1,2), secondScreen)
         hs.application.launchOrFocus("IntelliJ IDEA")
      end

      --      hs.application.launchOrFocus("IntelliJ IDEA CE")
      -- os.execute("sleep .2")
      -- hs.grid.set(hs.window.focusedWindow(), hs.geometry(1,0,1,2), secondScreen)

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,2,2), mainScreen)
   else
      hs.application.launchOrFocus("iTerm")
      os.execute("sleep .2")
      hs.grid.pushWindowLeftHalf()

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.pushWindowRightHalf()
   end
end

function myLayoutBackEndDevelopment()
   local mainScreen = hs.screen.allScreens()[1]
   local secondScreen = hs.screen.allScreens()[2]

   if secondScreen then
      hs.application.launchOrFocus("Emacs")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,1,2), secondScreen)

      hs.application.launchOrFocus("iTerm")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(1,0,1,2), secondScreen)

      intellijWindows = hs.application.allWindows(hs.application("Intellij IDEA"))
      for k, v in pairs(intellijWindows) do
         os.execute("sleep .2")
         hs.grid.set(v, hs.geometry(0,0,2,2), mainScreen)
         hs.application.launchOrFocus("IntelliJ IDEA CE")
      end
   else
      hs.application.launchOrFocus("iTerm")
      os.execute("sleep .2")
      hs.grid.pushWindowLeftHalf()

      hs.application.launchOrFocus("IntelliJ IDEA CE")
      os.execute("sleep .2")
      hs.grid.pushWindowRightHalf()
   end

   hs.execute('/usr/local/bin/emacsclient -e "(progn (delete-other-windows) (switch-to-buffer \\\"*scratch*\\\"))"')
end

function myLayoutGeneralTesting()
   local mainScreen = hs.screen.allScreens()[1]
   local secondScreen = hs.screen.allScreens()[2]

   if secondScreen then
      hs.application.launchOrFocus("Iterm")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,1,2), secondScreen)

      intellijWindows = hs.application.allWindows(hs.application("Intellij IDEA"))
      for k, v in pairs(intellijWindows) do
         os.execute("sleep .2")
         hs.grid.set(v, hs.geometry(1,0,1,2), secondScreen)
         hs.application.launchOrFocus("IntelliJ IDEA CE")
      end

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,2,2), mainScreen)
   else
      intellijWindows = hs.application.allWindows(hs.application("Intellij IDEA"))
      for k, v in pairs(intellijWindows) do
         os.execute("sleep .2")
         hs.grid.set(v, hs.geometry(1,0,1,2), secondScreen)
         hs.application.launchOrFocus("IntelliJ IDEA CE")
      end

      hs.application.launchOrFocus("Google Chrome")
      os.execute("sleep .2")
      hs.grid.pushWindowRightHalf()
   end
end

function myLayoutZoomNotes()
   hs.application.launchOrFocus("zoom.us")
   os.execute("sleep .2")
   hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,12,2))

   hs.application.launchOrFocus("Google Chrome")
   os.execute("sleep .2")
   hs.grid.set(hs.window.focusedWindow(), hs.geometry(0,0,4,2))
end


function myZoomLayoutTesting(app)
   local mainScreen = hs.screen.allScreens()[1]
   local secondScreen = hs.screen.allScreens()[2]
   local screen = mainScreen
   
   if secondScreen then
      screen = secondScreen
   end
   if not app then
      app = hs.application.launchOrFocus("zoom.us")
      os.execute("sleep .2")
   end
   zoomWindows = app:allWindows()
   for k, v in pairs(zoomWindows) do
      log.i("moving zoom window")
      os.execute("sleep .2")
      hs.grid.set(v, hs.geometry(0,0,2,2), screen)
   end
end


-- function appEventHandler(appName, eventType, application)
--    
--    if appName == "zoom.us" then 
--       log.i("app launch handler " .. appName .. " event " .. eventType)
--       log.i("activated=" .. hs.application.watcher.activated .. " deactivated=" .. hs.application.watcher.deactivated .. " hidden=" .. hs.application.watcher.hidden ..  " launched=" .. hs.application.watcher.launched .. " launching=" ..  hs.application.watcher.launching .. " terminated=" .. hs.application.watcher.terminated .. " unhidden=" .. hs.application.watcher.unhidden)
--       if eventType == hs.application.watcher.activated then
--          log.i("handling zoom event")
--          myZoomLayoutTesting(application)
--       end
--    end
-- end

-- hs.hotkey.bind(minimash, 'D', defaultBigDisplaySetup)
-- hs.hotkey.bind(minimash, 'F', myLayoutFrontEndDevelopment)
-- hs.hotkey.bind(minimash, 'C', myLayoutComms)
-- hs.hotkey.bind(minimash, 'V', myLayoutBackEndDevelopment)
-- hs.hotkey.bind(minimash, 'D', myLayoutDebugging)
-- hs.hotkey.bind(minimash, 'T', myLayoutGeneralTesting)
-- hs.hotkey.bind(minimash, 'Z', myZoomLayoutTesting)
-- hs.hotkey.bind(mashshift, 'Z', myLayoutZoomNotes)


-- hs.application.watcher.new(appEventHandler):start()

--------------------------------------------------------------
---
--- Expose
---
-------------------------------------------------------------- 
-- set up your instance(s)
-- expose = hs.expose.new(nil,{showThumbnails=true}) -- default windowfilter, no thumbnails
-- expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application
-- expose_browsers = hs.expose.new{'Safari','Google Chrome', 'Firefox'} -- specialized expose using a custom windowfilter

-- for your dozens of browser windows :)

-- then bind to a hotkey
-- hs.hotkey.bind('ctrl-cmd-shift','e','Expose',function()expose:toggleShow()end)
--------------------------------------------------------------
---
--- SPOOOOOOOOOOOOOONS
---
-------------------------------------------------------------- 

-- Cycle appearance: dark → light → auto → dark ...
hs.hotkey.bind(mash, 'D', function()
   local auto = hs.execute("defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null"):gsub("%s+", "")
   local current = hs.execute("defaults read -g AppleInterfaceStyle 2>/dev/null"):gsub("%s+", "")

   if auto == "1" then
      -- auto → dark
      hs.execute("defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool false")
      hs.osascript.applescript('tell application "System Events" to tell appearance preferences to set dark mode to true')
      hs.alert.show("Dark Mode")
   elseif current == "Dark" then
       -- dark → light
       hs.execute("defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool false")
       hs.osascript.applescript('tell application "System Events" to tell appearance preferences to set dark mode to false')
       hs.alert.show("Light Mode")
   else
      -- light → auto
      hs.execute("defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool true")
      hs.alert.show("Auto Mode")
   end
end)

-- hs.loadSpoon("CircleClock")
  
