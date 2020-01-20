--default main scene that jsut goes to menu

local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator, this used to ensure randomness with the random funcion
math.randomseed( os.time() )
io.output():setvbuf("no") -- Don't use buffer for console messages

-- Go to the menu screen
composer.gotoScene( "mainmenu" )
