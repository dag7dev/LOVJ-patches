local Patch = lovjRequire("lib/patch")
local palettes = lovjRequire("lib/utils/palettes")
local kp = lovjRequire("lib/utils/keypress")
local Timer = lovjRequire("lib/timer")
local cfg_timers = lovjRequire("cfg/cfg_timers")
local cfg_screen = lovjRequire("cfg/cfg_screen")
local Lfo = lovjRequire("lib/signals/lfo")

local PALETTE
local fontMain -- Font TTF per il testo principale
local fontScrolling -- Font TTF per il testo scorrevole
local textPositionTop = 0
local textPositionBottom = 0
local textSlideShow = {
    "Hi folks, vi siete divertiti ad ascoltarci? Seguiteci su Instagram su @cyrix86mpu per tutti gli aggiornamenti sulle nostre prossime uscite e se vi va TAGGATECI NELLE VOSTRE STORIE! Grazie per il vostro supporto. * * * Ringraziamenti * * * @tucs_art: synth, Game Boy, audio ; @dag7music: Game Boy, PikOrchestra, visual ; sonno: supporto e videomaking ; davide el noisiero: supporto e feedback ; astra: la gatta di sonno ; Zona Warpa: per averci fornito la location ; e a VOI, il nostro FANTASTICO PUBBLICO * * * * * Seguiteci su Instagram se vi va su @cyrix86mpu e sui profili degli artisti @dag7music e @tucs.art. * * * * * Zona Warpa @ Milano 2024! * * * * *"
}

local patch = Patch:new()
local stars = {}
local numStars = math.random(50, 200)

-- Inizializza le stelle con posizioni e velocità casuali
local function initStars()
    for i = 1, numStars do
        stars[i] = {
            x = math.random(0, screen.InternalRes.W),
            y = math.random(0, screen.InternalRes.H),
            speed = math.random(10, 30) -- Velocità casuale per effetto parallasse
        }
    end
end

--- @private init_params initialize patch parameters
local function init_params()
    local g = patch.resources.graphics
    local p = patch.resources.parameters

    -- Inizializza scrollingSpeed con il valore predefinito
    p.scrollingSpeed = 75

    patch.resources.parameters = p
    patch.resources.graphics = g
end

function patch.patchControls()
    local p = patch.resources.parameters
    if kp.isDown("space") then
        p.scrollingSpeed = 200
    else
        p.scrollingSpeed = 75
    end
end

function patch:setCanvases()
    Patch.setCanvases(patch)  -- Call parent function
    if cfg_screen.UPSCALE_MODE == cfg_screen.LOW_RES then
        patch.canvases.balls = love.graphics.newCanvas(screen.InternalRes.W, screen.InternalRes.H)
        patch.canvases.bg = love.graphics.newCanvas(screen.InternalRes.W, screen.InternalRes.H)
    else
        patch.canvases.balls = love.graphics.newCanvas(screen.ExternalRes.W, screen.ExternalRes.H)
        patch.canvases.bg = love.graphics.newCanvas(screen.ExternalRes.W, screen.ExternalRes.H)
    end
end

--- @public init init routine
function patch.init(slot)
    Patch.init(patch, slot)
    PALETTE = palettes.PICO8
    patch:setCanvases()

    init_params()

    patch.push = Lfo:new(0.1, 0)

    patch.fontSize = 8
    -- Carica il font TTF per il testo scorrevole e il testo principale
    fontScrolling = love.graphics.newFont("data/fonts/munro.ttf", patch.fontSize * 2)
    fontMain = love.graphics.newFont("data/fonts/c64mono.ttf", patch.fontSize * 2)

    -- Inizializza il campo stellare
    initStars()
end

-- local function drawInfinitySymbol()
--     local centerX, centerY = 0, screen.InternalRes.H / 2
--     local time = cfg_timers.globalTimer.T
--     local radius = 50
--     local offset = 20 * math.sin(time)

--     love.graphics.setColor(0.25, 0.5, 0.5) -- Colore per il simbolo dell'infinito

--     -- Traccia il simbolo dell'infinito
--     love.graphics.circle("line", centerX + 10, centerY + offset, radius, 100)
--     love.graphics.circle("line", centerX - 10 + screen.InternalRes.W, centerY + offset, radius, 100)
-- end

local function drawInfinitySymbol()
    local centerX, centerY = screen.InternalRes.W / 2, screen.InternalRes.H / 2
    local time = cfg_timers.globalTimer.T
    local radius = 50
    local offset = 20 * math.sin(time)

    love.graphics.setColor(0.25, 0.5, 0.5) -- Colore per il simbolo dell'infinito

    -- Traccia il simbolo dell'infinito
    love.graphics.circle("line", centerX + offset, centerY, radius, 100)
    love.graphics.circle("line", centerX - offset, centerY, radius, 100)
end

local function drawText(text, x, y, scale, align, font)
    love.graphics.setFont(font) -- Usa il font TTF specificato
    love.graphics.setColor(1, 1, 1) -- Bianco per il testo
    love.graphics.print(text, x, y, 0, scale, scale, 0, 0)
end

-- local function scrollText(text, y, speed)
--     local textWidth = fontScrolling:getWidth(text)
--     local time = cfg_timers.globalTimer.T
--     local offset = (time * speed) % (textWidth + screen.InternalRes.W)
    
--     love.graphics.setColor(1, 1, 1) -- Bianco per il testo scorrevole
    
--     drawText(text, screen.InternalRes.W - offset, y - 5, 1, "left", fontScrolling)

--     -- Gestisce la scomparsa e il ritorno del testo
--     if offset > textWidth then
--         -- Scompare per 1 secondo
--         if time % (textWidth + screen.InternalRes.W) < 1 then
--             love.graphics.setColor(0, 0, 0, 1) -- Imposta il colore a nero per nascondere il testo
--             drawText(text, screen.InternalRes.W - offset, y, 1, "left", fontScrolling)
--         end
--     end
-- end

local function scrollText(text, y, position)
    local textWidth = fontScrolling:getWidth(text)
    local offset = position % (textWidth + screen.InternalRes.W)

    love.graphics.setColor(1, 1, 1) -- Bianco per il testo scorrevole
    drawText(text, screen.InternalRes.W - offset, y, 1, "left", fontScrolling)
end


local function drawStars()
    -- colore magenta
    love.graphics.setColor(1, 0.8, 0.8) -- Bianco tendente al rosso
    for _, star in ipairs(stars) do
        love.graphics.points(star.x, star.y) -- Disegna ogni stella come un punto
    end
end

local function draw_scene()
    love.graphics.clear(0, 0, 0, 1)

    -- Disegna il campo stellare
    drawStars()

    -- Disegna il simbolo dell'infinito
    drawInfinitySymbol()

    -- Disegna il testo principale
    drawText("CYRIX86MPU", screen.InternalRes.W / 2 - patch.fontSize * 10, screen.InternalRes.H / 2 - patch.fontSize, 1, "center", fontMain)
    drawText("dag & tucs", screen.InternalRes.W / 2 - patch.fontSize - 27, screen.InternalRes.H / 2 + patch.fontSize, 1, "center", fontScrolling)

    -- Usa le posizioni aggiornate per il testo scorrevole
    scrollText(textSlideShow[1], screen.InternalRes.H - 24, textPositionBottom)
    scrollText(textSlideShow[1], 8, textPositionTop)
end

--- @public patch.draw draw routine
function patch.draw()
    patch:drawSetup(patch.hang)

    -- Pulisce il canvas principale
    patch.canvases.main:renderTo(function()
        love.graphics.clear(0, 0, 0, 1)
    end)

    -- Disegna la scena
    draw_scene()

    return patch:drawExec()
end

function patch.update()
    local p = patch.resources.parameters
    local deltaTime = love.timer.getDelta()
    
    -- Aggiorna la posizione del testo in base alla velocità corrente
    textPositionTop = (textPositionTop + p.scrollingSpeed * deltaTime) % (fontScrolling:getWidth(textSlideShow[1]) + screen.InternalRes.W)
    textPositionBottom = (textPositionBottom + p.scrollingSpeed * deltaTime) % (fontScrolling:getWidth(textSlideShow[1]) + screen.InternalRes.W)
    
    -- Aggiorna il campo stellare
    for i, star in ipairs(stars) do
        star.x = star.x - star.speed * deltaTime

        -- Reimposta la stella se esce dallo schermo
        if star.x < 0 then
            star.x = screen.InternalRes.W
            star.y = math.random(0, screen.InternalRes.H)
            star.speed = math.random(10, 30)
        end
    end

    patch:mainUpdate()
end

function patch.commands(s)
end

return patch
