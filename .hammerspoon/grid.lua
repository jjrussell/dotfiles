-- add some new functions to hs.grid
-- assumes a grid 12 units wide 2 units high

function hs.grid.pushToSreenOne()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 0
         f.w = 6
         f.h = 2
   end)
end


function hs.grid.resizeWindowHalf()
   hs.grid.adjustWindow(function(f)
         f.w = 6
         f.h = 2
   end)
end
function hs.grid.resizeWindowVerticalHalf()
   hs.grid.adjustWindow(function(f)
         f.w = 12
         f.h = 1
   end)
end

function hs.grid.pushWindowLeftAndResize()
   hs.grid.pushWindowLeft()
   hs.grid.resizeWindowHalf()
end

function hs.grid.pushWindowRightAndResize()
   hs.grid.pushWindowRight()
   hs.grid.resizeWindowHalf()
end


function hs.grid.pushWindowLeftHalf()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 0
         f.w = 6
         f.h = 2
   end)
end

function hs.grid.pushWindowRightHalf()
   hs.grid.adjustWindow(function(f)
         f.x = 6
         f.y = 0
         f.w = 6
         f.h = 2
   end)
end

function hs.grid.pushWindowLeftThird()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 0
         f.w = 4
         f.h = 2
   end)
end

function hs.grid.pushWindowMiddleThird()
   hs.grid.adjustWindow(function(f)
         f.x = 4
	 f.y = 0
         f.w = 4
         f.h = 2
   end)
end

function hs.grid.pushWindowRightThird()
   hs.grid.adjustWindow(function(f)
         f.x = 8
	 f.y = 0
         f.w = 4
         f.h = 2
   end)
end


function hs.grid.pushWindowRightTwoThirds()
   hs.grid.adjustWindow(function(f)
         f.x = 4
         f.y = 0
         f.w = 8
         f.h = 2
   end)
end

function hs.grid.pushWindowTopLeft()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 0
         f.w = 6
         f.h = 1
   end)
end

function hs.grid.pushWindowTopRight()
   hs.grid.adjustWindow(function(f)
         f.x = 6
         f.y = 0
         f.w = 6
         f.h = 1
   end)
end

function hs.grid.pushWindowBottomLeft()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 1
         f.w = 6
         f.h = 1
   end)
end
function hs.grid.pushWindowBottomRight()
   hs.grid.adjustWindow(function(f)
         f.x = 6
         f.y = 1
         f.w = 6
         f.h = 1
   end)
end

function hs.grid.pushWindowBottomHalf()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 1
         f.w = 12
         f.h = 1
   end)
end
function hs.grid.pushWindowTopHalf()
   hs.grid.adjustWindow(function(f)
         f.x = 0
         f.y = 0
         f.w = 12
         f.h = 1
   end)
end
