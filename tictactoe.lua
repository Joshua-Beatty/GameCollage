local composer = require( "composer" )

local widget = require( "widget" )

local scene = composer.newScene()

----------------------------------------------------------------------
-- 3. Declarations --- in Corona its best practice to declare all of the variables that you will eventually use in the beggining, even if they are still nil for now
----------------------------------------------------------------------

-- Locals
local pieceSize		= 150	-- screen size in pixels
local currentTurn		= "X"   -- String variable used to track whose turn it is.  X always starts.
local theBoard			= {}	-- Table used to store the board pieces
local gameIsRunning	= true  -- Boolean variable used to track whether game is running or over.

-- Screen Centers
local centerX = display.contentWidth/2  
local centerY = display.contentHeight/2

-- Labels & Buttons
local currentTurnMsg        -- Empty variable that will be used to store the handle to a text object 

local gameStatusMsg         -- Empty variable that will be used to store the handle to a text object 

local resetGameButton       -- Empty variable that will be used to store the game reset button

local resetGameButtonText   -- Empty variable that will be used to store the handle to a text object 


-- Function Declarations
local createPiece
local createBoard             -- Function to draw the game board.

local checkForWinner        -- Function to check the board data (theBoard) grid for a winner.
local boardIsFull           -- Function to check if board is completely full (no blank spaces).  Used for stalemate testing.

-- Listener Declarations
local onTouchPiece          -- Listener to handle touches on board pieces.
local onTouchResetButton    -- Listener to handle touches on the reset button (resetGameButton).

-- Groups 
local sceneGroup
----------------------------------------------------------------------
-- 4. Definitions
----------------------------------------------------------------------

-- ==
--    createPiece() - Draws a single tic-tac-toe game tile
-- ==
createPiece = function( x , y, size )

-- Create the rectangle first (so it is displayed on the bottom)

local piece =  display.newRect( 0, 0, size, size )

-- Move the piece (The default position was <0,0>)			
piece.x = x
piece.y = y

-- Change the color of this 'piece' to be dark grey with a 2-pixel wide light grey border
piece:setFillColor( 0.125,0.125,0.125,1.0 )
piece:setStrokeColor( 0.5,0.5,0.5,1.0 )
piece.strokeWidth = 3

--Create the text object 'label' second so it is displayed on top of the rectangle
--Also make is as a sub variable of the piece object

piece.label =  display.newText( "", 0, 0, "arial.ttf", 120 ) -- Creates label empty for now, eventually will be X or O

-- Position this label over the piece.
piece.label.x = piece.x
piece.label.y = piece.y


-- Change the text color to light grey
piece.label:setFillColor(0.5)

-- Add a "touch" listener to the grid piece (rectangle object). 
piece:addEventListener( "touch", onTouchPiece )
sceneGroup:insert(piece)
sceneGroup:insert(piece.label)

return piece
end



--    createBoard() - Draws the tic-tac-toe game board.

createBoard = function()

local startX    = centerX - pieceSize  -- Column 1 starts once-piece width left of center
local startY    = centerY - pieceSize  -- Row 1 starts once-piece height above center


-- 1. Draw the board (3-by-3 grid of text objects over rectangles).

for row = 1, 3 do
	local y = startY + (row - 1) * pieceSize
	theBoard[row] = { {}, {}, {} } 

	for col = 1, 3 do
		local x = startX + (col - 1) * pieceSize

		local piece =  createPiece( x, y, pieceSize )

		-- Store this boardPiece in our generic table of pieces
		theBoard[row][col] = piece

	end
end		

----------------------------------------------------------------------
--Definitions of variable, main game objects
----------------------------------------------------------------------


--Add a current turn marker as a text object.
currentTurnMsg = display.newText( "Current Turn: " .. currentTurn , 0, 0, "arial.ttf", 80 )
currentTurnMsg.x = centerX
currentTurnMsg.y = centerY - 2 * pieceSize
currentTurnMsg:setFillColor( 1,0.5,0.5,1.0 )
sceneGroup:insert(currentTurnMsg)
--Add a winner indicator as a text object.
gameStatusMsg = display.newText( "No winner yet..." , 0, 0, "arial.ttf", 80 )
gameStatusMsg.x = centerX
gameStatusMsg.y = centerY + 2 * pieceSize -- Spaced two piece heights below center.
gameStatusMsg:setFillColor( 1)
sceneGroup:insert(gameStatusMsg)
--Create the reset button, first the rectangle
resetGameButton = display.newRect( 0, 0, currentTurnMsg.width, currentTurnMsg.height) 

-- Change the position 
resetGameButton.x = centerX
resetGameButton.y = centerY - 2 * pieceSize -- Spaced two piece heights above center.

-- Use same color scheme as the board pieces
resetGameButton:setFillColor( 0.25)
resetGameButton:setStrokeColor( 0.5,0.5,0.5,1.0 )
resetGameButton.strokeWidth = 5

-- Add a different listener to just this button 
resetGameButton:addEventListener( "touch", onTouchResetButton )

-- Hide the button (rectangle) for now.
resetGameButton.isVisible = false
sceneGroup:insert(resetGameButton)
--Create the text label second.

-- create the text object, then position it to get the results we want.
	resetGameButtonText =  display.newText( "Reset Game", 0, 0, "arial.ttf", 80 )
	resetGameButtonText.x = centerX
	resetGameButtonText.y = centerY - 2 * pieceSize -- Spaced two piece heights above center.

	resetGameButtonText:setFillColor(1)

	-- Hide the label text object
	resetGameButtonText.isVisible = false	
	sceneGroup:insert(resetGameButtonText)
end

-- Testing for a winner. Brute force method
checkForWinner = function( turn )

local bd = theBoard

if(bd[1][1].label.text == turn and  bd[1][2].label.text == turn and bd[1][3].label.text == turn) then -- COL 1
	return true
	
elseif(bd[2][1].label.text == turn and  bd[2][2].label.text == turn and bd[2][3].label.text == turn) then -- COL 2
	return true
	
elseif(bd[3][1].label.text == turn and  bd[3][2].label.text == turn and bd[3][3].label.text == turn) then -- COL 3
	return true

elseif(bd[1][1].label.text == turn and  bd[2][1].label.text == turn and bd[3][1].label.text == turn) then -- ROW 1
	return true
	
elseif(bd[1][2].label.text == turn and  bd[2][2].label.text == turn and bd[3][2].label.text == turn) then -- ROW 2
	return true
	
elseif(bd[1][3].label.text == turn and  bd[2][3].label.text == turn and bd[3][3].label.text == turn) then -- ROW 3
	return true

elseif(bd[1][1].label.text == turn and  bd[2][2].label.text == turn and bd[3][3].label.text == turn) then -- DIAGONAL 1 (top-to-bottom)
	return true

elseif(bd[1][3].label.text == turn and  bd[2][2].label.text == turn and bd[3][1].label.text == turn) then -- DIAGONAL 2 (bottom-to-top)
	return true
	
end 

return false
end


-- boardIsFull() - Checks to see if all grids are marked.  Returns false if one or more grids are blank. true means stalemate
boardIsFull = function( )

local bd = theBoard

for i = 1, 3 do
	for j = 1, 3 do
		-- Is the grid entry empty?
		if( bd[i][j].label.text == "" ) then 
			return false 
		end
	end
end

return true
end


--==
-- ================================= LISTENER DEFINITIONS
--==


-- ==
--    onTouchPiece() - Touch listener function.  
-- ==
onTouchPiece = function( event )

-- Grab what the touch is on, and the phase of the touch
local phase  = event.phase  
local target = event.target

-- If the game is over, then ignore this touch
	if( not gameIsRunning ) then
		return true
	end

	if( phase == "ended" ) then

		-- Is the marker for this piece empty?

		if( target.label.text == "" ) then

			-- The marker was empty, so set it to "X" or "O" (whoever's turn it is now).
			target.label.text = currentTurn

			if(currentTurn == "X") then  --set the color based on the turn
				target.label:setFillColor( 1,0.5,0.5,1.0 )
			else
				target.label:setFillColor( 0.5,0.5,1,1.0 )
			end
			--checking for winner
			if( checkForWinner( currentTurn ) ) then
				print("Winner is: " .. currentTurn )

				-- We have a winner.  Update the message, set the game as 'over', and
				-- reveal the reset button and its label.
				--
				gameStatusMsg.text = currentTurn .. " wins!"

				if(currentTurn == "X") then
					gameStatusMsg:setFillColor( 1,0.5,0.5,1.0 )
				else
					gameStatusMsg:setFillColor( 0.5,0.5,1,1.0 )
				end
				currentTurnMsg.isVisible = false
				gameIsRunning = false

				resetGameButton.isVisible = true
				resetGameButtonText.isVisible = true


			elseif( boardIsFull() ) then
				print("No winner!  We have a stalemate")

				-- We have a stalemate.  Update the message, set the game as 'over', and
				-- reveal the reset button and its label.
				--
				gameStatusMsg.text = "Stalemate!"
				gameStatusMsg:setFillColor(1)
				currentTurnMsg.isVisible = false
				gameIsRunning = false

				resetGameButton.isVisible = true
				resetGameButtonText.isVisible = true

			end

			if( currentTurn == "X" ) then  --change turn
				currentTurn = "O"
			else
				currentTurn = "X"
			end

			currentTurnMsg.text = "Current Turn: " .. currentTurn
			if(currentTurn == "X") then 
				currentTurnMsg:setFillColor( 1,0.5,0.5,1.0 )  --change current turn color based off turn
			else
				currentTurnMsg:setFillColor( 0.5,0.5,1,1.0 )
			end

		end
	end

	return true
end
--  onTouchResetButton() - Touch handler function for the reset button.
onTouchResetButton = function( event )
local phase  = event.phase
local target = event.target

-- Reset the board markers and board data
for row = 1, 3 do
	for col = 1, 3 do
		theBoard[row][col].label.text = ""
	end
end

-- Reset the current turn to "X"
currentTurn = "X"

-- Reset the messages to their initial values.
currentTurnMsg.text = "Current Turn: " .. currentTurn
currentTurnMsg.isVisible = true
gameStatusMsg.text = "No winner yet..."
gameStatusMsg:setFillColor(1)
currentTurnMsg:setFillColor( 1,0.5,0.5,1.0 )

-- Enable the game
gameIsRunning = true

-- Hide the reset button
resetGameButton.isVisible = false
resetGameButtonText.isVisible = false

return true
end
local function gotoMenu(event)
	if(event.phase == "ended") then
		composer.gotoScene( "mainmenu" )
	end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen

	createBoard( )  --create the board when the scene is created

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
	sceneGroup:insert(button1)
end


-- show()
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
