makeLuaSprite('buildings', 'persona/stages/tartarus-lobby/1', -740, -350)
setScrollFactor('buildings', 0.4, 0.4)
setProperty('buildings.antialiasing', antialiasing)
addLuaSprite('buildings')

makeLuaSprite('pillars', 'persona/stages/tartarus-lobby/2', -440, -450)
setScrollFactor('pillars', 0.6, 0.6);
setProperty('pillars.antialiasing', antialiasing)
addLuaSprite('pillars')

makeLuaSprite('fg', 'persona/stages/tartarus-lobby/3', -540, -350)
setProperty('fg.antialiasing', antialiasing)
addLuaSprite('fg')

function onCreatePost()
	if not lowQuality then
		makeLuaSprite('light', 'persona/stages/tartarus-lobby/5', -540, -350);
		addLuaSprite('light', true)

		makeLuaSprite('vig', 'persona/stages/tartarus-lobby/6')
		setScrollFactor('vig', 0, 0)
		setObjectCamera('vig', 'hud')
		addLuaSprite('vig', true)

		makeLuaSprite('lvig', 'persona/stages/tartarus-lobby/7')
		setScrollFactor('lvig', 0, 0)
		setObjectCamera('lvig', 'hud')
		addLuaSprite('lvig', true)
	end
end