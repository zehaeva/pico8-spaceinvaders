-- ENUM 
-- 0 GAME OVER
-- 1 RUN THE GAME
-- 2 YOU WIN
game_state = 1
  
timer = 0
timer_direction = 1
y_direction = 0
edge = 0

alien_columns = 1 -- 10
alien_rows = 1 -- 5

blocks_columns = 5
blocks_rows = 3

player = { }

bullets = { }
abullets = { }
killed = { }
bullet = {x = 0, y = 0, v = 0, sprite = 3}

function bullet:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 64
  self.y = y or 64
  self.vx = vx or 0
  self.vy = vy or 0
  self.width = 1
  self.height = 2
  self.sprite = sprite or 3
  return o
end

aliens = { }
alien = {x = 0, y = 0 }

function alien:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 0
  self.y = y or 0
  self.sprite = sprite or 1
  self.cc = rnd(15) * 10 + 30
  self.cooldown = self.cc
  self.vx = vx or 5
  self.vy = vy or 0
  self.xmin = xmin or 0
  self.xmax = xmax or 50
  self.width = 6
  self.height = 4
  return o
end

aggressivealien = alien:new()

function aggressivealien:fire(self)
  --create bullet
  if self.cooldown <= 0 then
    add(abullets, bullet:new{x = self.x, y = self.y + 5, vx = 0, vy = 1, sprite = 3})
    self.cooldown = self.cc
  end
end

spaceship = {x = 64, y = 96, sprite = 2}

function spaceship:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 64
  self.y = y or 64
  self.width = 7
  self.height = 5
  self.sprite = sprite or 2
  self.cooldown = 0
  return o
end

function spaceship:fire()
  --create bullet
  if self.cooldown <= 0 then
    add(bullets, bullet:new{x = self.x, y = self.y, vx = 0, vy = -1, sprite = 3})
    self.cooldown = 10
  end
end
  
blocks = { }
block = {}

function block:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 64
  self.y = y or 64
  self.xsize = xsize or 4
  self.ysize = ysize or 4
  self.width = xsize or 4
  self.height = ysize or 4
  self.sprite = sprite or 0
  self.hp = hp or 2
  return o
end
  
function collision(a, b)
  if a.x <= (b.x + b.width) and (a.x + a.width) >= b.x and a.y <= (b.y + b.height) and (a.y + a.height) >= b.y then
    return true
  else
    return false
  end
end
  
function _init()
  game_state = 1
  
  player = spaceship:new{x = 64, y = 120, sprite = 2}
  
  bullets = { }
  abullets = { }
  
  timer = 1
  timer_direction = 1
  y_direction = 0
  tick_speed = 10
  
  for i=1, alien_columns do
    for j=1, alien_rows do
	  ax = 10 * i + timer
	  ay = 10 * j
	  if j == 1 then
	    r = rnd(15) * 10 + 30
	    a = aggressivealien:new{x = ax, y = ay, sprite = 0, cc = r, cooldown = r, xmin = ax - 5, xmax = ax + 20}
	  else
	    a = alien:new{x = ax, y = ay, sprite = 1, xmin = ax - 5, xmax = ax + 20}
	  end
      add(aliens, a)
    end
  end
  
  for i=1, blocks_columns do
    for j=1, blocks_rows do
	  add(blocks, block:new{x = 20 * i, y = 90 + 5 * j})
	  add(blocks, block:new{x = 20 * i + 5, y = 90 + 5 * j})
	  add(blocks, block:new{x = 20 * i + 10, y = 90 + 5 * j})
	end
  end  
end

function _update()
  if count(aliens) == 0 and game_state == 1 then 
    game_state = 2
    -- restart the game
    if (btn(4)) then _init() end
  else
  
    if player.cooldown > 0 then
      player.cooldown = player.cooldown - 1
    end
  
    -- player inputs
    if btn(0) and player.x > 0 then player.x = player.x - 1 end
    if btn(1) and player.x <= 120 then player.x = player.x + 1 end
    -- player fire!
    if (btn(5)) then player:fire() end
    
    --alien timer movement
    if timer % 120 == 0 or edge == 1 then 
      timer_direction = timer_direction * -1
      y_direction = 1
	  edge = 0
    else
      y_direction = 0
    end
	
    timer = timer + timer_direction
	
	aliencount = count(aliens)
    for a in all(aliens) do 
	  if timer % (flr(aliencount / 50 * 10)) == 0 then
	    movex = (a.x + 1 * timer_direction)
	    if a.xmax <= movex and timer_direction == 1 then
	      a.x = a.xmax
		  edge = 1
	    elseif a.xmin >= movex and timer_direction == -1 then
	      a.x = a.xmin
		  edge = 1
        else
          a.x = movex
		  edge = 0
	    end
	  else
	    edge = 0
      end
      a.y = a.y + y_direction
	end
    
    -- move bullets
    for i, a in pairs(bullets) do 
      -- out of bounds check
      if a.y <= 0 or a.y >= 128 or a.x <= 0 or a.x >= 128 then
        deli(bullets, i)
      else
        a.x = a.x + a.vx
        a.y = a.y + a.vy
      end
    end
    for i, a in pairs(abullets) do 
      -- out of bounds check
      if a.y <= 0 or a.y >= 128 or a.x <= 0 or a.x >= 128 then
        deli(abullets, i)
      else
        a.x = a.x + a.vx
        a.y = a.y + a.vy
      end
    end
	
    -- check for collision
    -- bullet collision
    for j,b in pairs(abullets) do
      --if (player.y + 3) >= b.y and (player.y) <= b.y and (player.x - 1) <= b.x and (player.x + 3) >= b.x then
	  if collision(player, b) then
        game_state = 0
		add(killed, b)
		gameover()
      end
	  
	  for i,a in pairs(blocks) do
	    --if (a.x - 1) <= b.x and (a.x + a.xsize) > b.x and a.y <= b.y and (a.y + a.ysize) < b.y then
		if collision(a, b) then
		  a.hp = a.hp - 1
		  deli(abullets, j)
		  if a.hp <= 0 then
		    deli(blocks, i)
	      end
		end
	  end
    end

    for i,a in pairs(aliens) do 
      --DEAD??
      --if (a.y + 3) >= (player.y) and (a.x) <= (player.x + 6) and (a.x) >= (player.x - 1) then 
	  if collision(a, player) then
        game_state = 0
		add(killed, a)
		gameover()
      else
        -- bullet collision
        for j,b in pairs(bullets) do
          --if (a.y + 3) >= b.y and (a.y) <= b.y and (a.x - 1) <= b.x and (a.x + 3) >= b.x then
	      if collision(a, b) then
            deli(aliens, i)
            deli(bullets, j)
          elseif a.sprite == 0 then
            a:fire(a)
          end
        end
	  
        if count(bullets) == 0 and a.sprite == 0 then
          a:fire(a)
        end
	    a.cooldown = a.cooldown - min(flr(50 / aliencount), 10)
	  end
    end
  end
end

function _draw()
  -- clear screen
  cls(1)
  if game_state == 0 then
    print('GAME OVER', 48, 58, 7)
	for i, a in pairs(killed) do
	  print("("..a.x..","..a.y.."), ("..a.x + a.width..","..a.y+a.height..")")
	  print("("..player.x..","..player.y.."), ("..player.x + player.width..","..player.y+player.height..")")
	end
  elseif game_state == 2 then
    print('CONGRATS!', 48, 58, 7)
    print('YOU WIN!!', 48, 64, 7)
  elseif game_state == 1 then
	  -- draw spaceship
	  spr(player.sprite, player.x, player.y)
	  print("("..player.x..","..player.y..")")
	  -- draw aliens  
	  for a in all(aliens) do 
        spr(1, a.x, a.y) 
	  end
	  
	  -- draw blocks  
	  for a in all(blocks) do 
        spr(a.sprite, a.x, a.y) 
	  end
	  
	  -- draw bullet
	  for a in all(bullets) do
	    spr(a.sprite, a.x, a.y)
	  end
	  for a in all(abullets) do
	    spr(a.sprite, a.x, a.y)
	  end
  end
end

function gameover()
  if game_state == 0 then
    bullets = { }
    abullets = { }
	aliens = { }
  end
end