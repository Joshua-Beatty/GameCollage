local composer = require( "composer" )  --compsoer allows for swapping between scenes
local widget = require( "widget" )  --widget allows easy generation of buttons

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gototictactoe(event)  --simple function that will go to the TicTacToe scene
    if(event.phase == "ended") then --wait for you to release the buton
        composer.gotoScene( "tictactoe" )
    end
end

local function gotoFlappy(event)   --simple function that will go to the Flappy scene
    if(event.phase == "ended") then  --wait for you to release the buton
        composer.gotoScene( "flappy" )
    end
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local button1 = widget.newButton(  --create new button with specific seetings visually
    {
        label = "button",
        onEvent = gototictactoe,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 400,
        height = 100,
        cornerRadius = 18,
        fillColor = { default={0.2}, over={0.3} },
        strokeColor = { default={0.5}, over={0.8} },
        strokeWidth = 6,
        fontSize = 70,
        font = "arial.ttf",
        labelColor = { default={ 1, 1, 1 }, over={ 0.9 } }
    }
    )

    -- Center the button
    button1.x = display.contentCenterX
    button1.y = display.contentCenterY - 75

    -- Change the button's label text
    button1:setLabel( "TicTacToe" )
    sceneGroup:insert(button1)

    local button2 = widget.newButton(  --create new button with specific seetings visually
    {
        label = "button",
        onEvent = gotoFlappy,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 400,
        height = 100,
        cornerRadius = 18,
        fillColor = { default={0.2}, over={0.3} },
        strokeColor = { default={0.5}, over={0.8} },
        strokeWidth = 6,
        fontSize = 70,
        font = "arial.ttf",
        labelColor = { default={ 1, 1, 1 }, over={ 0.9 } }
    }
    )

    -- Center the button 
    button2.x = display.contentCenterX
    button2.y = display.contentCenterY + 75

    -- Change the button's label text
    button2:setLabel( "Flappy Ball" )
    sceneGroup:insert(button2)

end


-- show() -ignore everything below here this is only used if you want things to change in betwwen scenes.
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene