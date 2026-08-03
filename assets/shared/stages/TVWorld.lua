makeLuaSprite('fog', 'persona/stages/tv-world/fog', -600)
setScrollFactor('fog', 0.7, 0.7)
setProperty('fog.antialiasing', antialiasing)
addLuaSprite('fog')

makeLuaSprite('ladder', 'persona/stages/tv-world/ladder', -600)
setProperty('ladder.antialiasing', antialiasing)
addLuaSprite('ladder')

makeLuaSprite('floor', 'persona/stages/tv-world/floor', -600)
addLuaSprite('floor')

if not lowQuality then
	makeLuaSprite('lights', 'persona/stages/tv-world/lights', -600)
	setScrollFactor('lights', 0.9, 0.9)
	setProperty('lights.antialiasing', antialiasing)
	addLuaSprite('lights')
end

makeLuaSprite('platforms', 'persona/stages/tv-world/platforms', -600)
setProperty('platforms.antialiasing', antialiasing)
addLuaSprite('platforms')

if not lowQuality then
	makeLuaSprite('light', 'persona/stages/tv-world/light', -600)
	addLuaSprite('light', true)
end