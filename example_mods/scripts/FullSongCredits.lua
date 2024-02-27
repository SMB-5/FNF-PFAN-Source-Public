-- Script is from Super Funkin' Galaxy (https://gamebanana.com/mods/444759)
local songdata = {

	['Bopeebo'] = {
	'Bopeebo', -- Song Name [1]
	'KawaiSprite', -- Composer [2]
	'Ninjamuffin', -- Coder [3]
	'69', --  Length for onscreen [4]
	'PhantomArcade, Evilsk8r', -- Artist [5]
	'NinjaMuffin', -- Charter [6]
	},

	['Fresh'] = {
	'Fresh', -- Song Name [1]
	'KawaiSprite', -- Composer [2]
	'Ninjamuffin', -- Coder [3]
	'69', --  Length for onscreen [4]
	'PhantomArcade, Evilsk8r', -- Artist [5]
	'NinjaMuffin', -- Charter [6]
	},

	['Specialist'] = {
	'Specialist', -- Song Name [1]
	'Atsushi Kitajoh', -- Composer [2]
	'???', -- Coder [3]
	'69', --  Length for onscreen [4]
	'No one', -- Artist [5]
	'???', -- Charter [6]
	},

}

local offsetX = 10
local offsetY = 540
local objWidth = 500
function onCreate()

	if downscroll then
		offsetY = 80
	end

	if songName == 'Bopeebo' then
		objWidth = 450 -- edit this to have the thing be wider for this song, to make all names fit (make the number bigger for wider)
	end
	if songName == 'Fresh' then
		objWidth = 450 -- edit this to have the thing be wider for this song, to make all names fit (make the number bigger for wider)
	end
	if songName == 'Specialist' then
		objWidth = 350 -- edit this to have the thing be wider for this song, to make all names fit (make the number bigger for wider)
	end
end


function ifExists(table, valuecheck) -- This stupid function stops your game from throwing up errors when you play a main week song thats not in the Song Data Folder
	if table[valuecheck] then
		return true
	else
		return false
	end
end

function onBeatHit()
	if songName == 'Bopeebo' then
		--if curBeat == 1 then
			--CreditsShow()
		--end
		if curBeat == 4 then
			CreditsHide()
		end
	end
	if songName == 'Fresh' then
		if curBeat == 16 then
			CreditsShow()
		end
		if curBeat == 24 then
			CreditsHide()
		end
	end
	if songName == 'Specialist' then
		--if curBeat == 16 then
			--CreditsShow()
		--end
		if curBeat == 10 then
			CreditsHide()
		end
	end

end

function CreditsShow()
songExists = ifExists(songdata, songName) -- Checks to see if song exists
	if songExists == true then
		local curSongTable = songdata[songName]
		setTextString('creditTitle', curSongTable[1]) -- Sets the actual things
		setTextString('creditComposer', "Song: "..curSongTable[2])
		setTextString('creditCode', "Code: "..curSongTable[3])
		setTextString('creditArtist', "Art: "..curSongTable[5])
		setTextString('creditCharter', "Charting: "..curSongTable[6])

		--Tweens--
		doTweenX("creditBoxTween", "creditBox", getProperty("creditBox.x") + objWidth, 1, "expoOut")
		doTweenX("creditTitleTween", "creditTitle", getProperty("creditTitle.x") + objWidth, 1, "expoOut")
		doTweenX("creditArtistTween", "creditArtist", getProperty("creditArtist.x") + objWidth, 1, "expoOut")
		doTweenX("creditCodeTween", "creditCode", getProperty("creditCode.x") + objWidth, 1, "expoOut")
		doTweenX("creditComposerTween", "creditComposer", getProperty("creditComposer.x") + objWidth, 1, "expoOut")
		doTweenX("creditCharterTween", "creditCharter", getProperty("creditCharter.x") + objWidth, 1, "expoOut")
		runTimer("creditDisplay",curSongTable[4],1)
	end
end

function onCreatePost() -- This creates all the placeholder shit B) ((THIS PART OF THE SCRIPT WAS MADE BY PIGGY))
	luaDebugMode = true

	makeLuaSprite('creditBox', 'empty', 0 - objWidth, offsetY)
	makeGraphic('creditBox', objWidth, 158, '000000')
	setObjectCamera('creditBox', 'other')
	setProperty("creditBox.alpha", 0.5)
	addLuaSprite('creditBox', true)

	makeLuaText('creditTitle', 'PlaceholderTitle', objWidth, offsetX - objWidth, offsetY+0)
	setTextSize('creditTitle', 35)
	setTextFont('creditTitle', 'vcr.ttf')
	setTextAlignment('creditTitle', 'left')
	setObjectCamera('creditTitle', 'other')
	addLuaText("creditTitle",true)

	makeLuaText('creditComposer', 'PlaceholderComposer', objWidth, offsetX - objWidth, offsetY+35)
	setTextSize('creditComposer', 25)
	setTextFont('creditComposer', 'vcr.ttf')
	setTextAlignment('creditComposer', 'left')
	setObjectCamera('creditComposer', 'other')
	addLuaText("creditComposer",true)

	makeLuaText('creditCode', 'PlaceholderCode', objWidth, offsetX - objWidth, offsetY+65)
	setTextSize('creditCode', 25)
	setTextFont('creditCode', 'vcr.ttf')
	setTextAlignment('creditCode', 'left')
	setObjectCamera('creditCode', 'other')
	addLuaText("creditCode",true)

	makeLuaText('creditArtist', 'PlaceholderArtist', objWidth, offsetX - objWidth, offsetY+95)
	setTextSize('creditArtist', 25)
	setTextFont('creditArtist', 'vcr.ttf')
	setTextAlignment('creditArtist', 'left')
	setObjectCamera('creditArtist', 'other')
	addLuaText("creditArtist",true)

	makeLuaText('creditCharter', 'PlaceholderCharter', objWidth, offsetX - objWidth, offsetY+125)
	setTextSize('creditCharter', 25)
	setTextFont('creditCharter', 'vcr.ttf')
	setTextAlignment('creditCharter', 'left')
	setObjectCamera('creditCharter', 'other')
	addLuaText("creditCharter",true)

	-- If you dont NOT want the art and charter credits (or a mix of two), the value used in the old version is:
	-- offsetY+25 for creditTitle
	-- offsetY+80 for the other credit (be it Composer, Charting, or Art)
end


function onSongStart()

	if songName == 'Fresh'
	--or songName == 'Fresh'

	then

	else
	CreditsShow()
	end
end

function onTimerCompleted(timerName)
	if timerName == "creditDisplay" then
		CreditsHide()
	end
end

function CreditsHide()
	doTweenX("creditBoxTween", "creditBox", getProperty("creditBox.x") - objWidth, 0.5, "sineIn")
	doTweenX("creditTitleTween", "creditTitle", getProperty("creditTitle.x") - objWidth, 0.5, "sineIn")
	doTweenX("creditComposerTween", "creditComposer", getProperty("creditComposer.x") - objWidth, 0.5, "sineIn")
	doTweenX("creditCodeTween", "creditCode", getProperty("creditCode.x") - objWidth, 0.5, "sineIn")
	doTweenX("creditArtistTween", "creditArtist", getProperty("creditArtist.x") - objWidth, 0.5, "sineIn")
	doTweenX("creditCharterTween", "creditCharter", getProperty("creditCharter.x") - objWidth, 0.5, "sineIn")
end

--[[
CREDITS :yippee:

omotashi: Made the script (https://twitter.com/omotashii)
legole0: Helped him make the base script when he started from scratch (https://twitter.com/legole0)
Piggyfriend1792: The OG Script from the Monday Night Monsterin' Mod that he used for making the thing show up (https://twitter.com/piggyfriend1792)
DEAD SKULLXX: Requested him to add Artist and Charter Credits 
Flez: Made the file cleaner and easier to read, and added more comments
--]]
