-- ENUM 
-- 0 GAME OVER
-- 1 RUN THE GAME
-- 2 YOU WIN
game_state = 1

player = { }

bullets = { }
abullets = { }
bullet = {x = 0, y = 0, v = 0, sprite = 3}

function bullet:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 64
  self.y = y or 64
  self.vx = vx or 0
  self.vy = vy or 0
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
  return o
end

function alien:fire(self)
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
  
function _init()
  game_state = 1
  
  player = spaceship:new{x = 64, y = 96, sprite = 2}
  
  bullets = { }
  abullets = { }
  
  timer = 5
  timer_direction = 1
  y_direction = 0
  
  for i=1, 10 do
    for j=1, 5 do
	  r = rnd(15) * 10 + 30
	  a = alien:new{x = 10 * i + timer, y = 10 * j, sprite = 1, cc = r, cooldown = r}
      add(aliens, a)
    end
  end
end

function _update()
  if count(aliens) == 0 then 
    game_state = 2
    -- restart the game
    if (btn(4)) then _init() end
  else
  
    if player.cooldown > 0 then
      player.cooldown = player.cooldown - 1
    end
  
    -- player inputs
    if (btn(0)) then player.x = player.x - 1 end
    if (btn(1)) then player.x = player.x + 1 end
    --if (btn(2)) then player.y = player.y - 1 end
    --if (btn(3)) then player.y = player.y + 1 end
    
    if (btn(5)) then player:fire() end
    
    --alien timer movement
    if timer >= 50 or timer <= -50 then 
      timer_direction  = timer_direction * -1
      y_direction = 1
    else
      y_direction = 0
    end
    timer = timer + timer_direction
    
    if timer % 10 == 0 then
      move = (timer % 10) + timer_direction
    else
      move = 0
    end
    -- monsters move about
    for a in all(aliens) do 
      a.x = a.x + move
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
      if (player.y + 3) >= b.y and (player.y) <= b.y and (player.x - 1) <= b.x and (player.x + 3) >= b.x then
        game_state = 0
      end
    end

    for i,a in pairs(aliens) do 
      --DEAD??
      if (a.y + 3) >= (player.y) and (a.x - 1) <= player.x and (a.x + 6) >= player.x then 
        game_state = 0
      end

      -- bullet collision
      for j,b in pairs(bullets) do
        if (a.y + 3) >= b.y and (a.y) <= b.y and (a.x - 1) <= b.x and (a.x + 3) >= b.x then
          deli(aliens, i)
          deli(bullets, j)
        else
          a:fire(a)
        end
      end
      if count(bullets) == 0 then
        a:fire(a)
      end
	  a.cooldown = a.cooldown - 1
    end
  end
end

function _draw()
  -- clear screen
  cls(1)
  
  if game_state == 0 then
    print('GAME OVER', 48, 58, 7)
  elseif game_state == 2 then
    print('CONGRATS!', 48, 58, 7)
    print('YOU WIN!!', 48, 64, 7)
  elseif game_state == 1 then
	  -- draw spaceship
	  spr(player.sprite, player.x, player.y)
	  
	  -- draw aliens  
	  for a in all(aliens) do 
        spr(1, a.x, a.y) 
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
