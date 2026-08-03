-- precache video
startVideo('Persona 4 - Specialist', false, true, false, false)
setObjectCamera('videoCutscene', 'hud')

function onCountdownStarted()
	for i = 0, 3 do
		setProperty('playerStrums.members['..i..'].x', 412 + (112 * i))
		setProperty('opponentStrums.members['..i..'].x', 99999)
	end
	setProperty('dadGroup.visible', setProperty('gfGroup.visible', setProperty('boyfriendGroup.visible', setProperty('iconP1.visible', setProperty('iconP2.visible', setProperty('healthBar.visible', false)))))) -- did you guys know you can do this - melodiekit
end

function onSongStart()
	callMethod('videoCutscene.play')
end