local composer = require( "composer" )   --Allow for swapping between scenes
local widget = require( "widget" )   --geneate buttons
local physics = require( "physics" )   --Physics allows for use of box2d, a physic engine

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--Declerations--------

physics.start()   --start the physics simmulation
physics.setGravity( 0, 60 )  --sets the gravity

--Variables  --generates nil variabels to be used later
local sceneGroup
local bird
local pipes = {}
local killZone
local gameState = 0  --0=game stopped --2== game stopped but bird is falling, --1=game is still goign
local restartButton
local score = 0
local scoreText
--Functions-----------
local function gotoMenu(event)   --simple goto menu function for the back button
    if(event.phase == "ended") then
        composer.gotoScene( "mainmenu" )
    end
end
  
local function tapped(event)   --this function is attached to the background so when you tap anywehre
    if(gameState == 1 and event.phase == "ended") then
        bird:setLinearVelocity(-0 , -670)  --this sets the velocity the board to go up, remebr origin is top left corner
    end

end

local function deadCollision(self, event)  --this function is attacted to the pipe
    if(event.phase == "began" and event.other == bird) then  --only do something if it colliding with the bird
        gameState = 2;  --set the game to be over, but the bird is still falling, can not use physics.pause ir physics.stop inside of a collision event
        local vx, vy = bird:getLinearVelocity()  --grabs the bird velocity
        if(vy < 0) then
            bird:setLinearVelocity(0 , -100)  --make it start falling right away if it is not fallign
        end
    end

end

local function groundCollision(self, event)  --this is attached to the ground
    if(event.phase == "began" ) then
        gameState = 0;  --end the game

        bird:setLinearVelocity(-0 , -0)  --stop the bird from moving
    end

end
local function scoreUp(self, event)   --this is attached to a invisible rectangle between the pipes
    if(event.phase == "began" and event.other == bird) then  --if hitting the bird
        score = score + 1  --increase score
        scoreText.text = score  --change score text
    end
end

local function createPipes()  --this function will randomly generate 2 pipes, and the score collider in the imddle
    --initilaizing vairables
    local pipe1
    local pipe2
    local pipeInsert

    local distance = 150  --distance between pipes
    local speed = -200  --speed at which pipes move

    pipe1 = display.newRect(sceneGroup, display.contentCenterX * 2 + 110, display.contentHeight + distance  , 100,  display.contentHeight)  --generate new pipe
    pipe1:setFillColor(0, 0, 0.8)  --set color
    pipe1.strokeWidth = 10
    pipe1:setStrokeColor( 0, 0, 0.5 )

    pipe2 = display.newRect(sceneGroup, display.contentCenterX * 2  + 110, -distance , 100,  display.contentHeight)
    pipe2:setFillColor(0, 0, 0.8)
    pipe2.strokeWidth = 10
    pipe2:setStrokeColor( 0, 0, 0.5 )

    pipeInsert = display.newRect(sceneGroup, display.contentCenterX * 2  + 110, display.contentCenterY, 7,  distance*2) --generate score collider place it between the two pipes
    pipeInsert:setFillColor(0, 0, 0.8 , 0)

    local offset =  math.random (-250, 250) --grab random offset
    --move each item according to its offset
    pipe1.y = pipe1.y + offset
    pipe2.y = pipe2.y + offset
    pipeInsert.y = pipeInsert.y + offset

    --make each object a physics object
    physics.addBody( pipe1, "kinematic", { isSensor=true} )
    pipe1:setLinearVelocity(speed , 0)

    physics.addBody( pipe2, "kinematic", { isSensor=true } )
    pipe2:setLinearVelocity(speed , 0)

    physics.addBody( pipeInsert, "kinematic", { isSensor=true } )
    pipeInsert:setLinearVelocity(speed , 0)

    ---attach collision functions to each object
    pipe1.collision = deadCollision
    pipe1:addEventListener( "collision" )

    pipe2.collision = deadCollision
    pipe2:addEventListener( "collision" )

    pipeInsert.collision = scoreUp
    pipeInsert:addEventListener( "collision" )

    --rearange viewing order of them
    pipeInsert:toBack()
    pipe1:toBack()
    pipe2:toBack()
    tapper:toBack()

    --add each object to a table to keep track of them
    table.insert(pipes, pipe1)
    table.insert(pipes, pipe2)
    table.insert(pipes, pipeInsert)

end

local function killZoneCollision(self, event)  --this is a collider attatched to a rectangle to the left of the screen
    event.other:removeSelf()  --it will kill the pipes when the pipes collide with it
    table.remove (pipes, 1)  --and those pipes will be removed from memory

end
local function createScene()
    --generates background and sets it color 
    tapper = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth,  display.actualContentHeight)
    tapper:addEventListener("touch", tapped) --attaches taping function
    tapper:setFillColor(0.5, 0.5, 0.9)

    --creates the bird
    bird = display.newCircle(sceneGroup, display.contentCenterX - 100, display.contentCenterY, 40)
    bird:setFillColor(0.8, 0, 0)  --sets color
    bird.strokeWidth = 10
    bird:setStrokeColor( 0.5, 0, 0 )
    physics.addBody( bird, {  radius=45, density=1.0, friction=0.3, bounce=0 } ) --makes it a physics object

    local ground --generates ground
    ground = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight - display.screenOriginY - 17.5, display.actualContentWidth + 10,  40)
    ground:setFillColor(0, 0.8, 0)
    ground.strokeWidth = 10
    ground:setStrokeColor( 0, 0.5, 0 )
    physics.addBody( ground, "static",{ friction=0.3, bounce=0.2 } ) --makes it a physics object

    ground.collision = groundCollision  --attaches collision function
    ground:addEventListener( "collision" )

    local ceiling  --creates ceiling so bird can not fly away
    ceiling = display.newRect(sceneGroup, display.contentCenterX, display.screenOriginY-25, display.actualContentWidth + 15,  40)
    physics.addBody( ceiling, "static",{ friction=0.3, bounce=0 } )  --makes it a physics object

    --creates the kill zone to the left of the brid
    killZone = display.newRect(sceneGroup, display.screenOriginX - 10 -110, display.contentCenterY, 20, display.actualContentHeight * .9)
    physics.addBody( killZone, { friction=0.3, bounce=0 } )  --makes it a physic sobject
    killZone.gravityScale = 0  --makes it float
    killZone.collision = killZoneCollision  --attaches collision funcition
    killZone:addEventListener( "collision" )   


    scoreText = display.newText(sceneGroup, score, display.contentCenterX, 100, native.systemFont, 150 )  --generate text and palce it on screen
    scoreText:setFillColor( 1 )  --set text color: note (1) is equal to (1,1,1) and (1,1,1,1) brightness, rgb, and rgba respectively
end

local counterLimit = 120 --creates counter limit for pipe generation
local counter = 0  --creates counter
local function gameLoop(event) --this functino will be called every frame
    if(gameState == 0) then  --stop physics and show the restart button
        physics.pause()

        restartButton.isVisible = true
    end

    if(gameState == 2 or gameState == 0) then --if the game state is equal to 0 or 2 pause all pipes in place
        for key, i in ipairs(pipes) do --iterates through pipes
            i:setLinearVelocity(0,0)  --stops them
        end
    end

    if(gameState == 1) then  --if game is actively running increment counter
        counter = counter + 1
        if(counter == counterLimit) then
            createPipes()  --create pipes every 120 frames
            counter = 0
        end
    end
end

local function restart(event)  --restart function
    bird.x = display.contentCenterX - 100  --center bird
    bird.y = display.contentCenterY 
    gameState = 1  --set gamestate to go
    physics.start()  --start physcis

    
    counter = 0  --reset counter

    for key, i in ipairs(pipes) do  --iterate through all created pipes
        i:removeSelf()  --deleten them
    end

    pipes = {}  --then clear pipes table

    createPipes() --create one piar of pipes

    restartButton.isVisible = false --hide restart button

    score = 0  --clear score, and set score text
    scoreText.text = score
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local button1 = widget.newButton(  --creating the back button
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

    -- place the button off to the left
    button1.x = 50
    button1.y = display.contentCenterY

    -- Change the button's label text
    button1:setLabel( "⇦" )

    restartButton = widget.newButton( --create restart button
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
    restartButton.x = display.contentCenterX  --center button
    restartButton.y = display.contentCenterY
    restartButton:setLabel("↻")
    sceneGroup:insert(restartButton)
    restartButton.isVisible = false


    sceneGroup:insert(button1) --add buttons to what is called the "scceneground" this is nessecary if  you do not want the object ot persist inbetween scens
    createScene() --create the scene
    restart()  --restart

    Runtime:addEventListener( "enterFrame", gameLoop )--set the gameLoop functino to be called every frame
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        restart()  --restart scene when one is entering from another scene

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