Identifier  = require "engine.class.Identifier"
Vectors     = require "engine.class.Vectors"
Components  = require "engine.class.Components"
Utility     = require "engine.class.Utility"

Registry    = require "engine.class.Registry"
Input       = require "engine.class.Input"

Object      = require "engine.class.Object"
Entity      = require "engine.class.Entity"

local width, height
local score
local game_ball, game_ball_spawn_point, pin_left, pin_right

local engine = {}

function engine.load()
    math.randomseed(os.time())

    width, height = 800, 600
    score = {left = 0, right = 0}

    Identifier.setDefaultNamespace('pong')

    game_ball_spawn_point = Object.new(Identifier.new('ball_spawn_point'))
        :setRenderType('none')
        :setPos(width/2-12.5, height/2-12.5)
        :setSize(25, 25)
        :setComponents(Components.new()
            :engine_custom_data{
                game_ball_spawn_point = true
            }
            :create()
        )
    :create()

    game_ball = Object.new(Identifier.new('ball'))
        :setRenderType('fill')
        :setPos(game_ball_spawn_point.pos:copy())
        :setSize(game_ball_spawn_point.size:copy())
        :setCollision()
        :setComponents(Components.new()
            :engine_custom_data{
                game_ball = true,
                direction = Vectors.vec2(math.random() > 0.5 and -10 or 10, math.random(-5, 5)),
                speed = 20,
            }
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
            local middle = height/2-12.5
            if pin > middle then
                return 1
            elseif pin < middle then
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
        -- :setMoveInputs(nil, nil, {'w'}, {'s'})
        :setComponents(Components.new()
            :engine_custom_data{
                pin_side = 'left'
            }
            :engine_apply_vertical_movement(cpu_movement)
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
            :engine_custom_data{
                pin_side = 'right'
            }
            :engine_apply_vertical_movement(cpu_movement)
            :create()
        )
    :create()
end

function engine.update(delta)
    Registry:update(delta)
end

function engine.draw()
    Registry:draw()
end

return engine