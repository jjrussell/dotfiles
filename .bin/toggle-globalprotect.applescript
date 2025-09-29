(*
Toggle GlobalProtect VPN with AppleScript
Tested using macOS 10.14 and GlobalProtect version 5.2.3-22
Written by Trevor Manternach, July 2021.
https://gist.github.com/tmanternach/cbd4c213eab8569e38d6cd021b6255e5
*)

tell application "System Events" to tell process "GlobalProtect"
	click menu bar item 1 of menu bar 2 -- Activates the GlobalProtect "window" in the menubar
	click button 2 of window 1 -- Clicks either Connect or Disconnect
	click menu bar item 1 of menu bar 2 -- This will close the GlobalProtect "window" after clicking Connect/Disconnect. This is optional.
end tell