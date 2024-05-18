local curColor = {[0]='Purple', [1]='Blue', [2]='Green', [3]='Red'} -- fix %
local curEnd = 0
local allowOpponentSplash = false
luaDebugMode = true
local allowRGB = true
function onCreatePost()
    addHaxeLibrary('RGBShaderReference', "shaders")
end
function make()
    for i = 0, getProperty('strumLineNotes.length') - 1 do
        local color = allowRGB and 'RGB' or curColor[i % 4]
        makeAnimatedLuaSprite('hold'..i, 'holdCover'..color)
        addAnimationByPrefix('hold'..i, 'static', 'holdCoverStart'..color, 24, false)
        addAnimationByPrefix('hold'..i, 'pop', 'holdCoverStart'..color, 24, false)
        addAnimationByPrefix('hold'..i, 'hold', 'holdCover'..color, 24, true)
        setObjectCamera('hold'..i, 'hud')
        addLuaSprite('hold'..i, true)
        playAnim('hold'..i, 'pop')
        setProperty('hold'..i..'.alpha', 0.001) -- loading for ends hold
        if allowRGB then
            runHaxeCode([[
                var rgbShader:Array<RGBShaderReference> = [];
                for (i in 0...game.strumLineNotes.length) {
                    if (game.getLuaObject("hold" + i, false) != null) {
                        rgbShader[i] = new RGBShaderReference(game.getLuaObject("hold" + i, false), Note.initializeGlobalRGBShader(i % 4));
                        setVar("holdShader" + i, rgbShader[i]);
                    }
                }
            ]])
        end
    end
end
if getPropertyFromClass('backend.ClientPrefs', 'data.opponentStrums') == true then function opponentNoteHit(id, data, type, sus)holdNote(id, data, 0, sus) end end
function goodNoteHit(id, data, type, sus)holdNote(id, data, 1, sus) end
function makeHoldEnd(data, i)
    if i == nil then i = 0 end
    local int = 0
    if i == 1 then int = 4 end
    local color = allowRGB and 'RGB' or curColor[data % 4]
    makeAnimatedLuaSprite('holdEnd'..curEnd, 'holdCover'..color)
    addAnimationByPrefix('holdEnd'..curEnd, 'pop', 'holdCoverEnd'..color, 24, false)

    addLuaSprite('holdEnd'..curEnd, true)

    setProperty('holdEnd'..curEnd..'.x', getMidpointX(getProperty('strumLineNotes.members['..(data + int)..']')) - getMidpointX('holdEnd'..curEnd) - 15)

    setProperty('holdEnd'..curEnd..'.y', getMidpointY(getProperty('strumLineNotes.members['..(data + int)..']')) - getMidpointY('holdEnd'..curEnd) + 45)


    setObjectCamera('holdEnd'..curEnd, 'hud')

    if allowRGB then
       runHaxeCode([[
            var h:String = "holdEnd]]..curEnd..[[";
            if (game.getLuaObject(h, false) != null) {
                var shader:RGBShaderReference;
                shader = new RGBShaderReference(game.getLuaObject(h, false), Note.initializeGlobalRGBShader(]]..(data + int)..[[ % 4));
            }
       ]])
    end

    curEnd = curEnd + 1
    setProperty('hold'..(data + int)..'.alpha', 0)
end
function holdNote(id, data, i, s)
    if i == nil then i = 0 end
    local int = 0
    if i == 1 then int = 4 end
    if s then
        if stringEndsWith(getPropertyFromGroup('notes', id, 'animation.curAnim.name'), 'end') then
            if i == 1 then makeHoldEnd(data, 1) end
            if i == 0 and allowOpponentSplash then makeHoldEnd(data, 0) else setProperty('hold'..(data + int)..'.alpha', 0) end
        else
        if getProperty('hold'..(data + int)..'.animation.name') == 'pop' then
            playAnim('hold'..(data + int), 'hold')
        end
        if getProperty('hold'..(data + int)..'.animation.name') ~= 'hold' then
            playAnim('hold'..(data + int), 'pop', true)
        end
            setProperty('hold'..(data + int)..'.alpha', 1)
        end
    else
        --playAnim('hold'..(data + int), i == 0 and 'pop' or 'static', true)
    end
end
function onKeyRelease(i)
    if getProperty('hold'..(i + 4)..'.alpha') == 1 then
        makeHoldEnd(i, 1)
    end
end
function onUpdate()
    for i = 0, getProperty('strumLineNotes.length') - 1 do
        if luaSpriteExists('hold'..i) then
            setProperty('hold'..i..'.x', getMidpointX(getProperty('strumLineNotes.members['..i..']')) - getProperty('hold'..i..'.width')/2 - 15)
            setProperty('hold'..i..'.y', getMidpointY(getProperty('strumLineNotes.members['..i..']')) - getProperty('hold'..i..'.height')/2 + 45)
        else
            make()
        end
    end
    for i = 0, curEnd do
        if luaSpriteExists('holdEnd'..i) then
            if getProperty('holdEnd'..i..'.animation.finished') then
                removeLuaSprite('holdEnd'..i)
            end
        end
    end
end