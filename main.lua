SCR_HEIGHT = love.graphics.getHeight( )
SCR_WIDTH = love.graphics.getWidth( )
GROUND_HEIGHT = 30
BALL_RADIUS = 20
SCORE_PER_TURN = 100
NEXT_LVL_SCORE_INC = 100



function reset_variables()
    zones = {bottom = 40, top = 40}
    current_zone = 1 -- top:0, bottom:1
    gamestate = "game" -- game, pause, score(game over), startscreen
    score = 0 --total score
    keypress_num = 0 -- number of keypress
    next_lvl_score = NEXT_LVL_SCORE_INC
end


function love.load()
    reset_variables()
    gamestate = "startscreen" 
    
    fonts = {}
    fonts.score = love.graphics.newFont(25)
    fonts.pause = love.graphics.newFont(50)
    fonts.game_over = love.graphics.newFont(50)
    fonts.game_caption = love.graphics.newFont(40)
    fonts.text_font = love.graphics.newFont(15)

    texts = {}
    texts.pause = "PAUSE"
    texts.score_help = "press SPACE to restart"
    texts.pause_help = "press P to continue"
    texts.game_caption = "DON'T TOUCH"
    texts.start_help = {"SPACE to start", 
                        "ESC   to exit",
                        "P     to pause" }

    love.mouse.setVisible(false)                        
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)

    objects = {}
    objects.ball = {}
    objects.ball.body = love.physics.newBody(world, SCR_WIDTH/2, SCR_HEIGHT/2, "dynamic")
    objects.ball.body:setMass(150)
    objects.ball.shape = love.physics.newCircleShape(BALL_RADIUS)
    objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1)
    objects.ball.fixture:setUserData("Ball")

    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, SCR_WIDTH/2, SCR_HEIGHT-GROUND_HEIGHT/2)
    objects.ground.shape = love.physics.newRectangleShape(SCR_WIDTH, GROUND_HEIGHT)
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
    objects.ground.fixture:setUserData("Bottom")

    objects.top_bound = {}
    objects.top_bound.body = love.physics.newBody(world, SCR_WIDTH/2, GROUND_HEIGHT/2)
    objects.top_bound.shape = love.physics.newRectangleShape(SCR_WIDTH, GROUND_HEIGHT)
    objects.top_bound.fixture = love.physics.newFixture(objects.top_bound.body, objects.top_bound.shape)
    objects.top_bound.fixture:setUserData("Top")

    world:setCallbacks(collide_handler, nil, nil, nil)

    love.graphics.setBackgroundColor(104, 136, 248)
    love.graphics.setMode(SCR_WIDTH, SCR_HEIGHT, false, true, 0)
end

function love.update(dt)
    if gamestate == "game" then
        world:update(dt)
        if love.keyboard.isDown("up") then
            objects.ball.body:applyForce(0, -400)
        end
        ball_pos = objects.ball.body:getY()
        if current_zone == 0 then --top
            if ball_pos - BALL_RADIUS < GROUND_HEIGHT+zones.top then
                current_zone = 1
                if keypress_num ~= 0 then
                    score = score + math.ceil(SCORE_PER_TURN/keypress_num)
                end
                keypress_num = 1
            end
        else
            if ball_pos + BALL_RADIUS > SCR_HEIGHT-GROUND_HEIGHT-zones.bottom then
                current_zone = 0
                if keypress_num ~= 0 then
                    score = score + math.ceil(SCORE_PER_TURN/keypress_num)
                end
                keypress_num = 1
            end        
        end
        if score > next_lvl_score and zones.bottom > 5 and zones.top > 5 then
            next_lvl_score = next_lvl_score + NEXT_LVL_SCORE_INC
            zones.bottom = zones.bottom - 5
            zones.top = zones.top - 5
        end
    end
end

function love.draw()
    --ground and top bound
    love.graphics.setColor(50, 50, 50)
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
    love.graphics.polygon("fill", objects.top_bound.body:getWorldPoints(objects.top_bound.shape:getPoints()))
    
    -- ball
    love.graphics.setColor(193, 47, 14)
    love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
    
    --bottom zone
    if current_zone == 1 then
        love.graphics.setColor(0, 255,0, 125)
    else
        love.graphics.setColor(255, 0, 0,125)
    end
    love.graphics.rectangle("fill", 0, SCR_HEIGHT-GROUND_HEIGHT-zones.bottom , SCR_WIDTH, zones.bottom)

    --top zone
    if current_zone == 0 then
        love.graphics.setColor(0, 255,0, 125)
    else
        love.graphics.setColor(255, 0, 0, 125)
    end
    love.graphics.rectangle("fill", 0, GROUND_HEIGHT , SCR_WIDTH, zones.top)

    --score
    if gamestate == "pause"  or gamestate == "game" then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(fonts.score)
        love.graphics.print(score, 1,0)
    end
    if gamestate == "pause" then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.rectangle("fill", 0, 0 , SCR_WIDTH, SCR_HEIGHT)
        love.graphics.setFont(fonts.pause)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(texts.pause,
                    SCR_WIDTH/2 - fonts.pause:getWidth(texts.pause)/2 ,
                    SCR_HEIGHT/2 - 30)
        love.graphics.setFont(fonts.text_font)
        love.graphics.print(texts.pause_help, 
                    SCR_WIDTH/2 - fonts.text_font:getWidth(texts.pause_help)/2,
                    SCR_HEIGHT/2 + 60)  
    elseif gamestate == "score" then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.rectangle("fill", 0, 0 , SCR_WIDTH, SCR_HEIGHT)
        love.graphics.setFont(fonts.game_over)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(score, 
                    SCR_WIDTH/2 - fonts.game_over:getWidth(score)/2,
                    SCR_HEIGHT/2 - 30)  
        love.graphics.setFont(fonts.text_font)
        love.graphics.print(texts.score_help, 
                    SCR_WIDTH/2 - fonts.text_font:getWidth(texts.score_help)/2,
                    SCR_HEIGHT/2 + 60)  
    elseif gamestate == "startscreen" then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.rectangle("fill", 0, 0 , SCR_WIDTH, SCR_HEIGHT)
        love.graphics.setFont(fonts.game_caption)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(texts.game_caption, 
                    SCR_WIDTH/2 - fonts.game_caption:getWidth(texts.game_caption)/2,
                    SCR_HEIGHT/2 - 60)  
        love.graphics.setFont(fonts.text_font)
        for i, s in ipairs(texts.start_help) do
            love.graphics.print(s, 
                    SCR_WIDTH/2 - fonts.text_font:getWidth(texts.start_help[1])/2,
                    SCR_HEIGHT/2 + 50 + i*25) 
        end
    end
end

function collide_handler(a, b, coll)
    gamestate = "score"
end

function love.focus(f)
    if not f then
        if gamestate == "game" then
            gamestate = "pause"
        end
    else
        if gamestate == "pause" then
            gamestate = "game"
            objects.ball.body:applyForce(0, -500)
        end
    end
end


function love.keypressed(key, unicode)
   if key == "escape" then
        love.event.push("quit")
    elseif key == "p" then
        if gamestate == "game" then
            gamestate = "pause"
        elseif gamestate == "pause" then
            gamestate = "game"
            objects.ball.body:applyForce(0, -500)
        end
    elseif key == " " then
        if gamestate == "score" then
            objects.ball.body:setPosition(SCR_WIDTH/2, SCR_HEIGHT/2)
            reset_variables()
        elseif gamestate == "startscreen" then
            gamestate = "game"
            objects.ball.body:applyForce(0, -500)
        end
    elseif key == "up" then
        keypress_num = keypress_num  + 1
   end
end