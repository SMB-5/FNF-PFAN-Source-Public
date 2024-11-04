function onSongStart()

	startVideo('Persona 4 - Specialist')
	setProperty('inCutscene', false)
	setObjectCamera('videoCutscene', 'hud')
	setObjectOrder('videoCutscene', 0)
	setProperty('canPause', true)

end