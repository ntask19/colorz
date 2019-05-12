require 'config.config'
pcall( function()
    require 'config.app_config'
end )
local widget = require 'widget'

local ROWS_NUM = 3
local PANNEL_NUM = ROWS_NUM^2
local PANNEL_SIZE = 100
local LEVELS = {
    { level = 'easy', value = 0.5 },
    { level = 'normal', value = 0.3 },
    { level = 'hard', value = 0.1 },
    { level = 'SuperHard', value = 0.01 },
}

local gameLayer = display.newGroup()

local bgLayer = display.newGroup()
gameLayer:insert( bgLayer )

display.newText{
    parent = gameLayer,
    text = '色相パズル',
    x = CENTER_X,
    y = 200,
    fontSize = 40,
}

local function createBgPannel( y )
    local pannel = display.newRect( bgLayer, CENTER_X, y or _H+150, _W, 300 )
    pannel:setFillColor( math.random(), math.random(), math.random() )
    transition.to( pannel, { time = 6000, y = pannel.y-_H*1.5, onComplete = function()
        display.remove( pannel )
    end } )
end

for i = 1, 6 do
    print( (i-1)*300+150 )
    createBgPannel( (i-1)*300+150 )
end
timer.performWithDelay( 1000, function()
    createBgPannel( 1350 )
end, -1 )

local pannelLayer

local function createPannels( level )
    if pannelLayer then
        display.remove( pannelLayer )
    end
    pannelLayer = display.newGroup()
    gameLayer:insert( pannelLayer )

    local bg = display.newRect( pannelLayer, CENTER_X, CENTER_Y, _W, _H*1.5 )
    bg:setFillColor( 0.5 )
    bg:addEventListener( 'tap', function() return true end )
    bg:addEventListener( 'touch', function() return true end )

    local resultText = display.newText{
        parent = pannelLayer,
        text = '',
        x = CENTER_X,
        y = 100,
        font = nil,
        fontSize = 40
    }

    -- パネルを設置している
    local pannels = {}
    for i = 1, PANNEL_NUM do
        local posX, posY = (i%ROWS_NUM) == 0 and _W*0.25*ROWS_NUM or _W*0.25*(i%ROWS_NUM), 100+150*math.ceil(i/ROWS_NUM)
        local pannel = display.newRect( pannelLayer, posX, posY, PANNEL_SIZE, PANNEL_SIZE )
        pannel:setFillColor( 1, 0, 0 )

        function pannel:tap( event )
            if self.isCorrect then
                resultText.text = '正解です'
                resultText:setFillColor( 1, 0, 0 )
            else
                resultText.text = '不正解です'
                resultText:setFillColor( 0, 0, 1 )
            end
        end
        pannel:addEventListener( 'tap' )
        pannels[#pannels+1] = pannel
    end

    local answerIndex = math.random( 1, PANNEL_NUM )

    pannels[answerIndex].isCorrect = true
    pannels[answerIndex]:setFillColor( 1-level.value, 0, 0 )

    display.newText{
        parent = pannelLayer,
        text = '一色だけ色が違うパネルを選びましょう。',
        x = CENTER_X,
        y = 800,
        font = nil,
        fontSize = 24,
    }

    local close = widget.newButton{
        shape = 'rect',
        x = CENTER_X,
        y = _H-200,
        label = 'BACK',
        width = 200,
        height = 80,
        fontSize = 38,
        fillColor = { default={ 0.3, 0.3, 0.3, 1}, over={ 0.3, 0.3, 0.3, 1 } },
        onRelease = function()
            display.remove( pannelLayer )
        end
    }
    pannelLayer:insert( close )

end


local i = 1
for _, level in pairs( LEVELS ) do
    local button = widget.newButton{
        shape = 'rect',
        x = CENTER_X,
        y = i*100+300,
        label = level.level,
        width = 200,
        height = 80,
        fontSize = 38,
        fillColor = { default={ 0.3, 0.3, 0.3,1}, over={ 0.3, 0.3, 0.3, 1 } },
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        onRelease = function()
            timer.performWithDelay( 200, function()
                createPannels( level )
            end )
        end
    }
    gameLayer:insert( button )
    i = i + 1
end

local admob = require( "plugin.admob" )

-- AdMob listener function
local function adListener( event )

    if event.phase == "init" then
        -- Load an AdMob interstitial ad
        admob.load( "interstitial", { adUnitId = ADMOB_INTERSTIAL_ID } )
        admob.load( "banner", { adUnitId = ADMOB_BANNER_ID } )
    elseif event.phase == "loaded" then
        if event.type == 'banner' then
            admob.show( event.type, { y = 'bottom' } )
        end
    end
end

admob.init( adListener, { appId = ADMOB_APP_ID, testMode = true } )
if system.getInfo( 'environment' ) == 'simulator' then
    display.newRect( CENTER_X, _H-50, _W, 100 ):setFillColor( 1, 0, 0 )
    display.newText{
        text = 'A D',
        x = CENTER_X,
        y = _H-50,
        font = nil,
        fontSize = 30
    }
end
