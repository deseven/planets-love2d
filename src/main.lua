local numPlanets = 9
local numStars = 0
planets = {}
stars = {}
local sol

require "proc"

function love.load()
	math.randomseed(os.time())
	desktopW,desktopH = love.window.getDesktopDimensions(1)
	love.window.setMode(desktopW,desktopH,{fullscreen=true,fullscreentype="desktop",vsync=true,fsaa=4,display=1})
	love.window.setTitle("planets!!")
	numStars = desktopW/5
	scale = 0.5

	local loadPieces = numPlanets + 5

	updateLoading(1,loadPieces)

	bg = createBG(desktopW,desktopH)

	updateLoading(2,loadPieces)

	for i = 0,numStars do
		stars[i] = createStar(0)
	end
	updateLoading(3,loadPieces)
	for i = 0,numPlanets do
		planets[i] = createPlanet(i,math.random(8))
		updateLoading(3+i,loadPieces)
	end
	sol = createSol(0)
	updateLoading(loadPieces-1,loadPieces)

	planetShader = love.graphics.newShader("shaders/planet.glsl")
	solShader = love.graphics.newShader("shaders/sol2.glsl")
	solShader:send('fcolorType',math.random(4))
	shadersOn = true
	updateLoading(loadPieces,loadPieces)	
end

function love.update( dt )
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
	sol.xrot = sol.xrot + dt * sol.xrotspd
end

function love.draw()
	for i = 0,numStars do
		love.graphics.setColor(stars[i].r,stars[i].g,stars[i].b)
		love.graphics.point(stars[i].x,stars[i].y)
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(bg,0,0,0,4,4)
	if shadersOn then love.graphics.setShader(solShader) end
	solShader:send('exttime',sol.xrot)
	love.graphics.draw(sol.texture,desktopW/2,desktopH/2,0,scale,scale,sol.texture:getWidth()/2,sol.texture:getHeight()/2)
	if shadersOn then love.graphics.setShader(planetShader) end
	for i = 0,numPlanets do
		planetShader:send('xrot',planets[i].xrot)
		planetShader:send('yrot',planets[i].yrot)
		love.graphics.draw(planets[i].texture,planets[i].x,planets[i].y,0,scale,scale,planets[i].texture:getWidth()/2,planets[i].texture:getHeight()/2)
	end
	love.graphics.setShader()
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()).."\nRes: "..tostring(desktopW).."x"..tostring(desktopH).."\nScale: x"..tostring(scale), 10, 10)
end

function love.keypressed( key )
	if key == 's' then shadersOn = not shadersOn end
	if key == '1' then solShader:send('fcolorType',0) end
	if key == '2' then solShader:send('fcolorType',1) end
	if key == '3' then solShader:send('fcolorType',2) end
	if key == '4' then solShader:send('fcolorType',3) end
	if key == '5' then solShader:send('fcolorType',4) end
	if key == 'escape'	then love.event.quit() 	end
end

function love.mousepressed(x,y, button)
	if button == "wu" then
		scale = scale + 0.1
	elseif button == "wd" then
		scale = scale - 0.1
	end
	if scale > 3 then scale = 3 end
	if scale < 0.1 then scale = 0.1 end
end
