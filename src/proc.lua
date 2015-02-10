
function multiplyColor(r,g,b,m)
	local r = r*m
	local g = g*m
	local b = b*m
	if r > 255 then r = 255 end
	if g > 255 then g = 255 end
	if b > 255 then b = 255 end
	return r,g,b
end

function divideColor(r,g,b,d)
	local r = r/d
	local g = g/d
	local b = b/d
	if r < 100 then r = 100 end
	if g < 100 then g = 100 end
	if b < 100 then b = 100 end
	return r,g,b
end

function updateLoading(current,max,msg)
	local piece = 792/max
	love.graphics.setFont(mainFont)
	love.graphics.clear()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("line",desktopW/2-400-0.5,desktopH/2-20-0.5,800,40)
	if current ~= max then
		love.graphics.rectangle("fill",desktopW/2-396-0.5,desktopH/2-16-0.5,current*piece,32)
	else
		love.graphics.rectangle("fill",desktopW/2-396-0.5,desktopH/2-16-0.5,792,32)
	end
	love.graphics.printf(msg,0,desktopH/2+50,desktopW,"center")
	love.graphics.present()
end

function genTexture(w,h,a1,b1,a2,b2,r,g,b,ctype)
	local o = love.math.random(20000)
	local pi = math.pi
	local data = love.image.newImageData(w,h)
	for x=0,w-1 do
		for y=0,h-1 do
			local s=x/w
			local t=y/h
			local dx=a2-a1
			local dy=b2-b1
			local nx=a1+math.cos(s*2*pi)*dx/(2*pi)
			local ny=b1+math.cos(t*2*pi)*dy/(2*pi)
			local nz=a1+math.sin(s*2*pi)*dx/(2*pi)
			local nw=b1+math.sin(t*2*pi)*dy/(2*pi)
			c = love.math.noise(nx+o,ny+o,nz+o,nw+o)*255
			if ctype == 0 then data:setPixel(x, y, r, g, c, 255)
			elseif ctype == 1 then data:setPixel(x, y, c, g, b, 255)
			elseif ctype == 2 then data:setPixel(x, y, r, c, b, 255)
			elseif ctype == 3 then 
				data:setPixel(x, y, c, c, c, 255)
			elseif ctype == 4 then data:setPixel(x, y, c, c, c, 20) end
		end
	end
	return love.graphics.newImage(data)
end

function createSol(type)
	local curSize = 1500
	return {
		type = type,
		name = "",
		size = curSize,
		texture = genTexture(curSize,curSize,5,5,10,20,0,0,0,3),
		xrot = 0,
		yrot = 0,
		xrotspd = 0.8,
		yrotspd = 0.3
	}
end

function createStar(type)
	local color = math.random(155)+100
	return {
		type = type,
		r = color,
		g = color,
		b = color,
		x = math.random(0,desktopW),
		y = math.random(0,desktopH)
	}
end

function createBG(w,h)
	return genTexture(w/4,h/4,-1,3,-10,10,0,0,0,4)
end

function createPlanet(index,type)
	local curSize = math.random(100)+50
	local curDist,curVel
	if index == 0 then
			curDist = 540+math.random(20)+curSize
			curVel = 0.005+math.random(6)/1000+math.random(10)/10000
		else
			curDist = planets[index-1].distance+planets[index-1].size*math.random(2,3)+curSize+math.random(100)
			curVel = planets[index-1].velocity/1.4
		end
	return {
		type = type,
		name = "",
		size = curSize,
		texture = genTexture(curSize,curSize,math.random(10),math.random(10),math.random(20)+10,math.random(20)+10,math.random(200)+55,math.random(200)+55,math.random(200)+55,math.random(2)),
		x = 0,
		y = 0,
		xrot = 0,
		yrot = 0,
		xrotspd = math.random()/2,
		yrotspd = math.random()/2,
		distance = curDist,
		velocity = curVel,
		path = math.random(100)
	}
end
