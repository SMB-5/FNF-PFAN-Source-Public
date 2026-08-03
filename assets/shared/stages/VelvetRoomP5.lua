makeLuaSprite('room', 'persona/stages/velvet-room-p5/Room', -600, -300)
setScrollFactor('room', 0.8, 0.8)
setProperty('room.antialiasing', antialiasing)
addLuaSprite('room')

if not lowQuality then
	makeLuaSprite('deskShadow', 'persona/stages/velvet-room-p5/Shadow-Desk', -600, -300)
	setScrollFactor('deskShadow', 0.9, 0.9)
	setProperty('deskShadow.antialiasing', antialiasing)
	addLuaSprite('deskShadow')
end

makeLuaSprite('desk', 'persona/stages/velvet-room-p5/Desk', -600, -300)
setScrollFactor('desk', 0.9, 0.9)
addLuaSprite('desk')

if not lowQuality then
	makeLuaSprite('overlay', 'persona/stages/velvet-room-p5/Velvet_Room_Overlay', -500, -300)
	addLuaSprite('overlay', true)

	makeLuaSprite('light', 'persona/stages/velvet-room-p5/Velvet_Room_Overlay_2', -500, -300)
	addLuaSprite('light', true)
end