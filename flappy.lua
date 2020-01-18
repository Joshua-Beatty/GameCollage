local composer = require( "composer" )
local widget = require( "widget" )
local physics = require( "physics" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--Declerations--------

physics.start()
physics.setGravity( 0, 60 )

--Variables
local sceneGroup
local bird
local pipes = {}
local killZone
local gameState = 0
local restartButton
local score = 0
local scoreText
--Functions-----------
local function gotoMenu(event)
    if(event.phase == "ended") then
        composer.gotoScene( "mainmenu" )
        print("clicked")
    end
end

local function tapped(event)
    if(gameState == 1 and event.phase == "ended") then
        bird:setLinearVelocity(-0 , -670)
    end

end

local function deadCollision(self, event)
    if(event.phase == "began" and event.other == bird) then
        gameState = 2;
        local vx, vy = bird:getLinearVelocity()
        if(vy < 0) then
            bird:setLinearVelocity(0 , -100)
        end
    end

end

local function groundCollision(self, event)
    if(event.phase == "began" ) then
        gameState = 0;

        bird:setLinearVelocity(-0 , -0)
    end

end
local function scoreUp(self, event) 
    if(event.phase == "began" and event.other == bird) then
        score = score + 1
        scoreText.text = score
    end
end
local function createPipes()
    local pipe1
    local pipe2
    local pipeInsert
    local distance = 150
    local speed = -200
    pipe1 = display.newRect(sceneGroup, display.contentCenterX * 2 + 110, display.contentHeight + distance  , 100,  display.contentHeight)
    pipe1:setFillColor(0, 0, 0.8)
    pipe1.strokeWidth = 10
    pipe1:setStrokeColor( 0, 0, 0.5 )

    pipe2 = display.newRect(sceneGroup, display.contentCenterX * 2  + 110, -distance , 100,  display.contentHeight)
    pipe2:setFillColor(0, 0, 0.8)
    pipe2.strokeWidth = 10
    pipe2:setStrokeColor( 0, 0, 0.5 )

    pipeInsert = display.newRect(sceneGroup, display.contentCenterX * 2  + 110, display.contentCenterY, 7,  distance*2)
    pipeInsert:setFillColor(0, 0, 0.8 , 0)

    local offset =  math.random (-250, 250)
    pipe1.y = pipe1.y + offset
    pipe2.y = pipe2.y + offset
    pipeInsert.y = pipeInsert.y + offset


    physics.addBody( pipe1, "kinematic", { isSensor=true} )
    pipe1:setLinearVelocity(speed , 0)

    physics.addBody( pipe2, "kinematic", { isSensor=true } )
    pipe2:setLinearVelocity(speed , 0)

    physics.addBody( pipeInsert, "kinematic", { isSensor=true } )
    pipeInsert:setLinearVelocity(speed , 0)

    pipe1.collision = deadCollision
    pipe1:addEventListener( "collision" )

    pipe2.collision = deadCollision
    pipe2:addEventListener( "collision" )

    pipeInsert.collision = scoreUp
    pipeInsert:addEventListener( "collision" )

    
    pipeInsert:toBack()
    pipe1:toBack()
    pipe2:toBack()
    tapper:toBack()

    table.insert(pipes, pipe1)
    table.insert(pipes, pipe2)
    table.insert(pipes, pipeInsert)

end

local function killZoneCollision(self, event)
    event.other:removeSelf()
    table.remove (pipes, 1)

end
local function createScene()
    tapper = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth,  display.actualContentHeight)
    tapper:addEventListener("touch", tapped)
    tapper:setFillColor(0.5, 0.5, 0.9)

    bird = display.newCircle(sceneGroup, display.contentCenterX - 100, display.contentCenterY, 40)
    bird:setFillColor(0.8, 0, 0)
    bird.strokeWidth = 10
    bird:setStrokeColor( 0.5, 0, 0 )
    physics.addBody( bird, {  radius=45, density=1.0, friction=0.3, bounce=0 } )

    local ground
    ground = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight - display.screenOriginY - 17.5, display.actualContentWidth + 10,  40)
    ground:setFillColor(0, 0.8, 0)
    ground.strokeWidth = 10
    ground:setStrokeColor( 0, 0.5, 0 )
    physics.addBody( ground, "static",{ friction=0.3, bounce=0.2 } )

    ground.collision = groundCollision
    ground:addEventListener( "collision" )

    local ceiling
    ceiling = display.newRect(sceneGroup, display.contentCenterX, display.screenOriginY-25, display.actualContentWidth + 15,  40)
    ceiling:setFillColor(0, 0.8, 0)
    ceiling.strokeWidth = 10
    ceiling:setStrokeColor( 0, 0.5, 0 )
    physics.addBody( ceiling, "static",{ friction=0.3, bounce=0 } )

    killZone = display.newRect(sceneGroup, display.screenOriginX - 10 -110, display.contentCenterY, 20, display.actualContentHeight * .9)
    physics.addBody( killZone, { friction=0.3, bounce=0 } )
    killZone.gravityScale = 0
    killZone.collision = killZoneCollision
    killZone:addEventListener( "collision" )   


    scoreText = display.newText(sceneGroup, score, display.contentCenterX, 100, native.systemFont, 150 )
    scoreText:setFillColor( 1 )
end

local counterLimit = 120
local counter = 0
local function gameLoop(event)
    if(gameState == 0) then
        physics.pause()

        restartButton.isVisible = true
    end
    if(gameState == 2 or gameState == 0) then
        for key, i in ipairs(pipes) do
            i:setLinearVelocity(0,0)
        end
    end

    if(gameState == 1) then
        counter = counter + 1
        if(counter == counterLimit) then
            createPipes()
            counter = 0
        end
    end
end

local function restart(event)
    bird.x = display.contentCenterX - 100
    bird.y = display.contentCenterY 
    gameState = 1
    physics.start()

    
    counter = 0

    for key, i in ipairs(pipes) do
        i:removeSelf()
    end
    pipes = {}

    createPipes()
    restartButton.isVisible = false
    score = 0
    scoreText.text = score
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local button1 = widget.newButton(
    {
        label = "button",
        onEvent = gotoMenu,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 50,
        height = 50,
        cornerRadius = 18,
        fillColor = { default={0.2}, over={0.3} },
        strokeColor = { default={0.5}, over={0.8} },
        strokeWidth = 6,
        fontSize = 40,
        font = "arial.ttf",
        labelColor = { default={ 1, 1, 1 }, over={ 0.9 } }
    }
    )

    -- Center the button
    button1.x = 50
    button1.y = display.contentCenterY

    -- Change the button's label text
    button1:setLabel( "⇦" )

    restartButton = widget.newButton(
    {
        label = "button",
        onRelease = restart,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 250,
        height = 250,
        cornerRadius = 50,
        fillColor = { default={0.2}, over={0.3} },
        strokeColor = { default={0.5}, over={0.8} },
        strokeWidth = 6,
        fontSize = 200,
        font = "arial.ttf",
        labelColor = { default={ 1, 1, 1 }, over={ 0.9 } }
    }
    )

    -- Center the button
    restartButton.x = display.contentCenterX
    restartButton.y = display.contentCenterY
    restartButton:setLabel("↻")
    sceneGroup:insert(restartButton)
    restartButton.isVisible = false


    sceneGroup:insert(button1)
    createScene()
    restart()

    Runtime:addEventListener( "enterFrame", gameLoop )
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        restart()

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