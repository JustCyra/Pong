Identifier  = require "engine.class.identifier"
Vectors     = require "engine.class.vectors"
Components  = require "engine.class.components"
Utility     = require "engine.class.utility"

Registry    = require "engine.class.registry"
Input       = require "engine.class.input"

Object      = require "engine.class.object"
Entity      = require "engine.class.entity"

local width, height
local score
--- @type Object
local game_ball
--- @type Object
local game_ball_spawn_point
--- @type Entity
local pin_left
--- @type Entity
local pin_right

function love.load()
    love.window.setTitle('Pong')
    love.window.setMode(800, 600, {
        fullscreen = false,
        fullscreentype = 'desktop',
        vsync = false,
        msaa = 0,
        stencil = true,
        depth = 0,
        resizable = false,
        borderless = false,
        centered = true,
        display = 1,
        minwidth = 800,
        minheight = 600,
        highdpi = false,
    })

    math.randomseed(love.timer.getTime())

    width, height = love.window.getMode()
    score = {left = 0, right = 0}

    Identifier.setDefaultNamespace('pong')

    Object.new(Identifier.new('wall_top'))
        :setRenderType('fill')
        :setPos(50, 50)
        :setSize(width - 100, 1)
        :setCollision(width, 0)
    :create()
    Object.new(Identifier.new('wall_bottom'))
        :setRenderType('fill')
        :setPos(50, height - 50)
        :setSize(width - 100, 1)
        :setCollision(width, 0)
    :create()
    Object.new(Identifier.new('wall_left'))
        :setRenderType('fill')
        :setPos(50, 50)
        :setSize(1, height - 100)
        :setCollision(0, height - 100)
        :setComponents(Components.new()
            :engine_custom_data({
                game_goal = 1
            })
            :create()
        )
    :create()
    Object.new(Identifier.new('wall_right'))
        :setRenderType('fill')
        :setPos(width - 50, 50)
        :setSize(1, height - 100)
        :setCollision(0, height - 100)
        :setComponents(Components.new()
            :engine_custom_data({
                game_goal = 2
            })
            :create()
        )
    :create()

    game_ball_spawn_point = Object.new(Identifier.new('ball_spawn_point'))
        :setRenderType('none')
        :setPos(width/2-12.5, height/2-12.5)
        :setSize(25, 25)
        :setComponents(Components.new()
            :engine_custom_data({
                game_ball_spawn_point = true
            })
            :create()
        )
    :create()

    game_ball = Object.new(Identifier.new('ball'))
        :setRenderType('fill')
        :setPos(game_ball_spawn_point.pos:copy())
        :setSize(game_ball_spawn_point.size:copy())
        :setCollision()
        :setComponents(Components.new()
            :engine_custom_data({
                game_ball = true,
                direction = Vectors.vec2(math.random() > 0.5 and -10 or 10, math.random(-5, 5)),
                speed = 20,
            })
            :love_update(function (self, delta)
                local custom_data = self:getCustomData()
                local direction = custom_data.direction --[[@as Vector2]]
                local collided = false
                custom_data.speed = custom_data.speed + 1 * delta
        
                Registry:forEach(nil, function (instance)
                    if instance._type == 'entity' then
                        if self:isCollidingWith(instance, {x = direction.x * delta * custom_data.speed, y = 0}) then
                            collided = true
                            direction.x = direction.x == 10 and -10 or 10
                            direction.y = math.random(-5, 5)
                        end
                        if self:isCollidingWith(instance, {x = 0, y = direction.y * delta * custom_data.speed}) then
                            collided = true
                            direction.y = direction.y * -1
                        end
                    elseif instance._type == 'object' then
                        if instance == self or not instance.collision then
                            return
                        end
        
                        local goal_index = instance:getCustomData('game_goal')
                        if self:isCollidingWith(instance, direction * delta * custom_data.speed) then
                            collided = true
                            if goal_index then
                                self.pos:set(game_ball_spawn_point.pos:unpack())
                                direction.x = direction.x == 10 and -10 or 10
                                direction.y = math.random(-5, 5)
                                custom_data.speed = 20
                                if goal_index == 1 then
                                    score.right = score.right + 1
                                else
                                    score.left = score.left + 1
                                end
                            else
                                direction.y = direction.y * -1
                            end
                        end
                    end

                    if collided then
                        return true
                    end
                end)

                if not collided then
                    self.pos:add(direction * delta * custom_data.speed)
                end
            end)
            :create()
        )
    :create()

    --- @param self Entity
    local cpu_movement = function (self)
        local pin = self:getCenteredOriginPoint().y
        local ball = game_ball:getCenteredOriginPoint().y
        local side = self:getCustomData('pin_side')
        local ball_direction = game_ball:getCustomData('direction').x

        if
            side == 'left' and ball_direction == -10 or
            side == 'right' and ball_direction == 10
        then
            if ball < pin then
                return 1
            end
            if ball > pin then
                return -1
            end
        else
            local screen_center = height - self.size.y / 2
            local target_pos

            if ball < screen_center / 2 or ball > screen_center + screen_center / 2 then
                target_pos = screen_center
            else
                local target = Registry:getByID(
                    self.id.path == 'pin_left' and(Identifier.getDefaultNamespace() .. ':pin_right') or
                    (Identifier.getDefaultNamespace() .. ':pin_left'))
                if not target then
                    return false
                end

                target_pos = target:getCenteredOriginPoint().y
            end

            if pin > target_pos then
                return 1
            elseif pin < target_pos then
                return -1
            end
        end

        return false
    end

    pin_left = Entity.new(Identifier.new('pin_left'))
        :setRenderType('fill')
        :setPos(50, height/2 - 100/2)
        :setSize(25, 100)
        :setCollision()
        :setAcceleration(1500)
        :setMoveInputs(nil, nil, {'w'}, {'s'})
        :setComponents(Components.new()
            :engine_custom_data({
                pin_side = 'left'
            })
            -- :engine_apply_vertical_movement(cpu_movement)
            :create()
        )
    :create()

    pin_right = Entity.new(Identifier.new('pin_right'))
        :setRenderType('fill')
        :setPos(width - 75, height/2 - 100/2)
        :setSize(25, 100)
        :setCollision()
        :setAcceleration(1500)
        :setComponents(Components.new()
            :engine_custom_data({
                pin_side = 'right'
            })
            :engine_apply_vertical_movement(cpu_movement)
            :create()
        )
    :create()
end

function love.update(delta)
    Registry:update(delta)
end

function love.draw()
    Registry:draw()

    -- love.timer.step()

    love.graphics.print(string.format('FPS: %s', love.timer.getFPS()), 0, 0)
    love.graphics.print(string.format('Test: %s', pin_left.flags.is_cpu), 0, 14)
    love.graphics.print(tostring(score.left), love.math.newTransform(width/3-7, 14, 0, 2, 2))
    love.graphics.print(tostring(score.right), love.math.newTransform(width/3*2-7, 14, 0, 2, 2))
end

function love.keypressed(key, scanCode, isRepeat)
    Input:keypressed(key, scanCode, isRepeat)
end

function love.keyreleased(key)
    Input:keyreleased(key)
end