local numPlanets = 9
local numStars = 0
planets = {}
stars = {}
sol = {}
offsetX,offsetY = 0.0,0.0
mouseMoving,mouseX,mouseY = false,0,0
selectedObject,followedObject = -1,-1
fullscreen = true
showHelp = false

require "proc"

function love.load()
	math.randomseed(os.time())
	if fullscreen then
		desktopW,desktopH = love.window.getDesktopDimensions(1)
		love.window.setMode(desktopW,desktopH,{fullscreen=true,fullscreentype="desktop",vsync=true,fsaa=4,display=1})
		love.window.setTitle("planets!!")
	end
	mainFont = love.graphics.newFont("fonts/xol.ttf",16)
	numStars = desktopW/5
	scale = 0.5

	local loadPieces = numPlanets + 5

	updateLoading(1,loadPieces,"creating background...")
	bg = createBG(desktopW,desktopH)

	updateLoading(2,loadPieces,"creating stars...")
	for i = 0,numStars do
		stars[i] = createStar(0)
	end

	updateLoading(3,loadPieces,"creating sol...")
	sol = createSol(math.random(4))

	updateLoading(4,loadPieces,"creating planets...")
	for i = 0,numPlanets do
		planets[i] = createPlanet(i,math.random(8))
		updateLoading(3+i,loadPieces,"creating planet "..tostring(i).."...")
	end

	updateLoading(loadPieces-1,loadPieces,"compiling shaders...")
	planetShader = love.graphics.newShader("shaders/planet.glsl")
	solShader = love.graphics.newShader("shaders/sol2.glsl")
	solShader:send('fcolorType',sol.type)
	shadersOn = true
	debugOn = false
	subpixelStars = true
	updateLoading(loadPieces,loadPieces,"launching simulation...")
end

function love.update( dt )
	if love.keyboard.isDown("left") then offsetX = offsetX + dt*500 followedObject = -1 end
	if love.keyboard.isDown("right") then offsetX = offsetX - dt*500 followedObject = -1 end
	if love.keyboard.isDown("down") then offsetY = offsetY - dt*500 followedObject = -1 end
	if love.keyboard.isDown("up") then offsetY = offsetY + dt*500 followedObject = -1 end
	if mouseMoving then
		followedObject = -1
		offsetX = offsetX + (mouseX - love.mouse.getX())*-1
		offsetY = offsetY + (mouseY - love.mouse.getY())*-1
		mouseX = love.mouse.getX()
		mouseY = love.mouse.getY()
	end
	for i = 0,numStars do
		if math.random(1000) == 1000 then
			stars[i].r,stars[i].g,stars[i].b = multiplyColor(stars[i].r,stars[i].g,stars[i].b,1.5)
		elseif math.random(1000) == 1000 then
			stars[i].r,stars[i].g,stars[i].b = divideColor(stars[i].r,stars[i].g,stars[i].b,1.5)
		end
	end
	for i = 0,numPlanets do
		planets[i].path = planets[i].path + planets[i].velocity + dt/1000
		x = planets[i].distance*math.cos(planets[i].path)*scale
		planets[i].x = x+desktopW/2
		y = planets[i].distance*math.sin(planets[i].path)*scale
		planets[i].y = y+desktopH/2
		planets[i].xrot = planets[i].xrot + dt * planets[i].xrotspd
		planets[i].yrot = planets[i].yrot + dt * planets[i].yrotspd
	end
	if followedObject >= 0 then
		offsetX = (planets[followedObject].x-desktopW/2)*-1
		offsetY = (planets[followedObject].y-desktopH/2)*-1
	end
	sol.cor = sol.cor + dt * sol.corspd
	sol.rot = sol.rot + (dt * sol.rotspd)/10
end

function love.draw()
	for i = 0,numStars do
		love.graphics.setColor(stars[i].r,stars[i].g,stars[i].b)
		if subpixelStars then
			love.graphics.setPointSize(1.5);
			love.graphics.point(stars[i].x+0.25,stars[i].y+0.25)
		else
			love.graphics.setPointSize(1);
			love.graphics.point(stars[i].x+0.5,stars[i].y+0.5)
		end
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(bg,0,0,0,4,4)
	if shadersOn then love.graphics.setShader(solShader) end
	solShader:send('exttime',sol.cor)
	solShader:send('rottime',sol.rot)
	love.graphics.draw(sol.texture,desktopW/2+offsetX,desktopH/2+offsetY,0,scale,scale,sol.texture:getWidth()/2,sol.texture:getHeight()/2)
	for i = 0,numPlanets do
		if  i == selectedObject then
			if shadersOn then love.graphics.setShader() end
			love.graphics.circle("line",desktopW/2+offsetX,desktopH/2+offsetY,planets[i].distance*scale,200)
		end
		if shadersOn then love.graphics.setShader(planetShader) end
		planetShader:send('xrot',planets[i].xrot)
		planetShader:send('yrot',planets[i].yrot)
		love.graphics.draw(planets[i].texture,planets[i].x+offsetX,planets[i].y+offsetY,0,scale,scale,planets[i].texture:getWidth()/2,planets[i].texture:getHeight()/2)
		if  i == selectedObject then
			if shadersOn then love.graphics.setShader() end
			love.graphics.circle("line",planets[i].x+offsetX,planets[i].y+offsetY,planets[i].size/2*scale-1*scale,100)
		end
	end
	love.graphics.setShader()
	if showHelp then
		local help = "Welcome to planets!"
		help = help.."\n\nUse mouse wheel to zoom in/out."
		help = help.."\nUse left mouse button to select an object."
		help = help.."\nClick again to follow it."
		help = help.."\nUse right mouse button or arrows to move the viewpoint. "
		help = help.."\nUse [ and ] to cycle through objects."
		help = help.."\nUse D to enter the debug mode."
		help = help.."\nUse Space to restart simulation."
		help = help.."\nUse F to toggle fullscreen."
		help = help.."\nUse H to show help."
		help = help.."\nUse Esc to quit."
		love.graphics.print(help,10,10)
	else
		local info = "FPS: "..tostring(love.timer.getFPS())
		info = info.."\nRes: "..tostring(desktopW).."x"..tostring(desktopH).."x"..tostring(round(scale,3))
		info = info.."\nPress H for help"
		if debugOn then
			info = info.."\n\nDebug:"
			info = info.."\nShaders (s): "..tostring(shadersOn)
			info = info.."\nSol type (1-5): "..tostring(sol.type+1)
			info = info.."\nSubpixel stars (x): "..tostring(subpixelStars)
		end
		love.graphics.print(info,10,10)
	end
end

function love.keypressed( key )
	if key == 'd' then debugOn = not debugOn end
	if key == '[' then
		if selectedObject and selectedObject-1 >= 0 then
			selectedObject = selectedObject-1
		else
			selectedObject = numPlanets
		end
		followedObject = selectedObject
	end
	if key == ']' then
		if selectedObject and selectedObject+1 <= numPlanets then
			selectedObject = selectedObject+1
		else
			selectedObject = 0
		end
		followedObject = selectedObject
	end
	if debugOn then
		if key == 's' then shadersOn = not shadersOn end
		if key == 'x' then subpixelStars = not subpixelStars end
		if key == '1' then solShader:send('fcolorType',0) sol.type = 0 end
		if key == '2' then solShader:send('fcolorType',1) sol.type = 1 end
		if key == '3' then solShader:send('fcolorType',2) sol.type = 2 end
		if key == '4' then solShader:send('fcolorType',3) sol.type = 3 end
		if key == '5' then solShader:send('fcolorType',4) sol.type = 4 end
	end
	if key == ' ' then resetGame() love.load() end
	if key == 'f' then toggleFullscreen() end
	if key == 'h' then showHelp = not showHelp end
	if key == 'escape' then love.event.quit() end
end

function love.mousepressed(x,y,button)
	local delta = 0.0
	if button == "wu" then
		if scale*1.1 <= 3.0 then
			delta = (scale*1.1) / scale
			scale = scale*1.1
		else
			delta = 3.0 / scale
			scale = 3.0
		end
	elseif button == "wd" then
		if scale*0.9 >= 0.1 then
			delta = (scale*0.9) / scale
			scale = scale*0.9
		else
			delta = 0.1 / scale
			scale = 0.1
		end
	elseif button == "r" then
		mouseMoving = true
		mouseX = love.mouse.getX()
		mouseY = love.mouse.getY()
	elseif button == "l" then
		for i = 0,numPlanets do
			if (x >= planets[i].x+offsetX-planets[i].size/2*scale) and (x <= planets[i].x+offsetX+planets[i].size/2*scale) then
				if (y >= planets[i].y+offsetY-planets[i].size/2*scale) and (y <= planets[i].y+offsetY+planets[i].size/2*scale) then
					if selectedObject == i then
						followedObject = i
					else
						selectedObject = i
					end
					break
				end
			end
			if i == numPlanets then
				selectedObject = -1
			end
		end
	end
	if delta > 0 then
		offsetX = offsetX*delta
		offsetY = offsetY*delta
	end
end

function love.mousereleased(x,y,button)
	if button == "r" then mouseMoving = false end
end
