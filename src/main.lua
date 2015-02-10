local numPlanets = 9
local numStars = 0
planets = {}
stars = {}
local sol

require "proc"

function love.load()
	desktopW,desktopH = love.window.getDesktopDimensions(1)
	love.window.setMode(desktopW,desktopH,{fullscreen=true,fullscreentype="desktop",vsync=true,fsaa=4,display=1})
	love.window.setTitle("planets!!")
	scale = 0.5

	numStars = desktopW/5
	for i = 0,numStars do
		stars[i] = createStar(0)
	end
	for i = 0,numPlanets do
		planets[i] = createPlanet(i,math.random(8))
	end
	sol = createSol(0)

	planetShader = love.graphics.newShader("shaders/planet.glsl")
	solShader = love.graphics.newShader("shaders/sol2.glsl")
	solShader:send('fcolorType',math.random(0,4))
	shadersOn = true
end

function love.update( dt )
	--sh.time  = sh.time + dt * sh.speed
	--sh.xtime = -sh.time
	--sh.ytime = -sh.time
	--if love.keyboard.isDown( 'up')		then sh.y = sh.y + 1 end
	--if love.keyboard.isDown( 'down' )	then sh.y = sh.y - 1 end
	--if love.keyboard.isDown( 'right' )	then sh.x = sh.x - 1 end
	--if love.keyboard.isDown( 'left') 	then sh.x = sh.x + 1 end
	--if love.keyboard.isDown( 'z' ) then sh.size = sh.size - dt end
	--if love.keyboard.isDown( 'a' ) then sh.size = sh.size + dt end
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
	sol.yrot = sol.yrot + dt * sol.yrotspd
end

function love.draw()
	love.graphics.setColor( 255, 255, 255 )
	if shadersOn then love.graphics.setShader(solShader) end
	--planetShader:send('xrot',sol.xrot)
	--planetShader:send('yrot',sol.yrot)
	solShader:send('exttime',sol.xrot)
	--solShader:send('freq1',math.random(1,4)/100)
	--solShader:send('freq2',math.random(1,4)/100)
	--solShader:send('freq1',1)
	--solShader:send('freq2',1)
	love.graphics.draw(sol.texture,desktopW/2,desktopH/2,0,scale,scale,sol.texture:getWidth()/2,sol.texture:getHeight()/2)
	love.graphics.setShader()
	for i = 0,numStars do
		love.graphics.point(stars[i].x,stars[i].y)
	end
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
	--if key == ' '	then sh.image = love.graphics.newImage(genTexture(0)) 	end
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
