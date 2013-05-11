function love.load()
	love.physics.setMeter(35)
	World = love.physics.newWorld(0, 0, true)
	Planets = {}
	Boxes = {}
	addPlanet(180,240,90)
	addPlanet(480,120,45)
	addPlanet(300,500,60)
	addPlanet(400,350,30)
	addBox(50, 50, 10, 10)
	
	StartPos = {x=600, y=300}
end

function addPlanet(x, y, r)
	local body = love.physics.newBody(World, x, y, "static")
	local shape = love.physics.newCircleShape(r)
	local fixture = love.physics.newFixture(body, shape, 1)
	fixture:setDensity(1)
	fixture:setRestitution(0)

	Planets[#Planets+1] = body
end

function addBox(x, y, w, h)
	local body = love.physics.newBody(World, x, y, "dynamic")
	local shape = love.physics.newRectangleShape(w, h)
	local fixture = love.physics.newFixture(body, shape, 1)
	fixture:setDensity(1)
	fixture:setFriction(1)
	fixture:setRestitution(0)

	Boxes[#Boxes+1] = body
	
	return body
end

local getDistance = function(a, b)
    local x, y = a.x-b.x, a.y-b.y;
    return math.sqrt(x*x+y*y);
end

function love.mousereleased( x, y, button )
	local body = addBox(StartPos.x, StartPos.y, 10, 10)
	body:applyForce(x-StartPos.x, y - StartPos.y, x, y)
end

function love.update(dt)
	World:update(dt)
	
	
	for index,box in pairs(Boxes) do
		local bx, by = box:getWorldCenter()
		local bpos = {}
		bpos.x = bx
		bpos.y = by
		
		for index,planet in pairs(Planets) do
			local shape = planet:getFixtureList()[1]:getShape()
			local radius = shape:getRadius()
			local px, py = planet:getWorldCenter()
			local ppos = {}
			ppos.x = px
			ppos.y = py
			
			local dx, dy = 0, 0
			local dpos = {}
			dpos.x = dx
			dpos.y = dy
			
			dpos.x = dpos.x+bpos.x
			dpos.y = dpos.y+bpos.y
			dpos.x = dpos.x - ppos.x
			dpos.y = dpos.y - ppos.y
			
			local fdist = getDistance({x = 0, y = 0},dpos)	
			if (fdist <= radius*3) then
				dpos.x = -dpos.x
				dpos.y = -dpos.y
				
				local sum = math.abs(dpos.x) + math.abs(dpos.y)
				dpos.x = dpos.x * (1/sum * radius/fdist) *2
				dpos.y = dpos.y * (1/sum * radius/fdist) *2
				box:applyForce(dpos.x, dpos.y, bpos.x, bpos.y)
			end
		end
	end
end

function love.draw()
	love.graphics.circle("line",
			StartPos.x,
			StartPos.y,
			15)
	for index,planet in pairs(Planets) do
		love.graphics.circle("fill",
			planet:getX(),
			planet:getY(),
			planet:getFixtureList()[1]:getShape():getRadius())
	end
	
	for index,box in pairs(Boxes) do
		love.graphics.polygon("fill",
			box:getWorldPoints(box:getFixtureList()[1]:getShape():getPoints()))
	end
end