local te = false
function onEndSong()
	if not allowEnd then
	songAndDiff = songName
	sickWin = getPropertyFromClass('ClientPrefs','sickWindow')
	goodWin = getPropertyFromClass('ClientPrefs','goodWindow')
	badWin = getPropertyFromClass('ClientPrefs','badWindow')
	shitWin = 166
	    if songName == 'Specialist' then
		playMusic('P4victory', 0.8, true)
		else
		playMusic('P5victory', 0.8, true)
		end

		makeLuaSprite('bg','',0,0)
		makeGraphic('bg', screenWidth, screenHeight,'000000')
		setObjectCamera('bg', 'other')
		setProperty('bg.alpha', 0)
		addLuaSprite('bg', true)

		makeLuaText('cleared','Song Cleared!',0,20,-55)
		setTextSize('cleared', 34)
		setTextBorder('cleared', 4,'000000')
		setObjectCamera('cleared','other')
		addLuaText('cleared')

		makeLuaText('playedOn',''..songAndDiff,0,20,-70)
		setTextSize('playedOn', 34)
		setTextBorder('playedOn', 4,'000000')
		setObjectCamera('playedOn','other')
		addLuaText('playedOn')

		makeLuaText('judge','Judgements:',0,20,-75)
		setTextBorder('judge', 4,'000000')
		setTextSize('judge', 28)
		setObjectCamera('judge','other')
		addLuaText('judge')

		makeLuaText('sick','Sicks - '..getProperty('sicks'),0,20, -75)
		setTextBorder('sick', 4,'000000')
		setObjectCamera('sick','other')
		setTextSize('sick', 28)
		addLuaText('sick')

		makeLuaText('good','Goods - '..getProperty('goods'),0,20, -75)
		setTextBorder('good', 4,'000000')
		setObjectCamera('good','other')
		setTextSize('good', 28)
		addLuaText('good')

		makeLuaText('bad','Bads - '..getProperty('bads'),0,20, -75)
		setTextBorder('bad', 4,'000000')
		setObjectCamera('bad','other')
		setTextSize('bad', 28)
		addLuaText('bad')

		makeLuaText('shit','Shits - '..getProperty('shits'),0,20, -75)
		setTextBorder('shit', 4,'000000')
		setObjectCamera('shit','other')
		setTextSize('shit', 28)
		addLuaText('shit')

		makeLuaText('breaks','Missed: '..misses,0, 20, -75)
		setTextSize('breaks', 28)
		setObjectCamera('breaks','other')
		setTextBorder('breaks', 4,'000000')
		addLuaText('breaks')

		makeLuaText('combo','Highest Combo: '..topCombo,0, 20, -75)
		setTextSize('combo', 28)
		setObjectCamera('combo','other')
		setTextBorder('combo', 4,'000000')
		addLuaText('combo')

		makeLuaText('combo3','Combo: '..combo,0, 20, -75)
		setTextSize('combo3', 28)
		setObjectCamera('combo3','other')
		setTextBorder('combo3', 4,'000000')
		addLuaText('combo3')

		makeLuaText('combo2','Rating: '..ratingFC,0, 20, -75)
		setTextSize('combo2', 28)
		setObjectCamera('combo2','other')
		setTextBorder('combo2', 4,'000000')
		addLuaText('combo2')

		makeLuaText('score','Score: '..score,0, 20, -75)
		setTextSize('score', 28)
		setObjectCamera('score','other')
		setTextBorder('score', 4,'000000')
		addLuaText('score')

		makeLuaText('accuracy','Accuracy: '..round(rating * 100,2)..'% ('..ratingName.. ')',0, 20, -75)
		setTextSize('accuracy', 28)
		setObjectCamera('accuracy','other')
		setTextBorder('accuracy', 4,'000000')
		addLuaText('accuracy')

--[[ this doesn't wanna work for some reason so fuck it
		makeLuaText('rating','('..ratingFC..') '..wife3,0, 20, -75)
		setTextSize('rating', 28)
		setObjectCamera('rating','other')
		setTextBorder('rating', 4,'000000')
		setTextFont('rating','pixel.otf')
		addLuaText('rating')
--]]

		makeLuaText('continue','         Press ENTER to continue.', 0, 660, 800)
		setTextSize('continue', 24)
		setObjectCamera('continue','other')
		setTextBorder('continue', 4,'000000')
		addLuaText('continue')

		makeLuaText('timeWin','Mean: ? (SICK:'..sickWin..'ms,GOOD:'..goodWin..'ms,BAD:'..badWin..'ms,SHIT:'..shitWin..'ms)', 0, 20, 810)
		setTextSize('timeWin', 14)
		setObjectCamera('timeWin','other')
		setTextBorder('timeWin', 4,'000000')
		setTextFont('timeWin','pixel.otf')
		--addLuaText('timeWin')

		doTweenAlpha('tween','bg', 0.65, 0.5,'linear')
		doTweenY('down','cleared', 20, 1,'expoOut')
		doTweenY('down2','playedOn', 90, 1,'expoOut')
		doTweenY('down4','judge', 160, 1,'expoOut')
		doTweenY('down5','sick', 200, 1,'expoOut')
		doTweenY('down6','good', 240, 1,'expoOut')
		doTweenY('down7','bad', 280, 1,'expoOut')
		doTweenY('down13','shit', 320, 1,'expoOut')
		doTweenY('down8','breaks', 540, 1,'expoOut')
		doTweenY('down9','combo', 500, 1,'expoOut')
		doTweenY('down14','combo2', 620, 1,'expoOut')
		doTweenY('down15','combo3', 460, 1,'expoOut')
		doTweenY('down10','score', 580, 1,'expoOut')
		doTweenY('down11','accuracy', 660, 1,'expoOut')
		doTweenY('down12','rating', 560, 1,'expoOut')
		doTweenY('up','continue', 670, 1,'expoOut')
		doTweenY('up2','timeWin', 680, 1,'expoOut')
		te = true
		if songName == 'Specialist' then
			setTextFont('cleared','Fontsona4Golden.ttf')
			setTextFont('playedOn','Fontsona4Golden.ttf')
			setTextFont('judge','Fontsona4Golden.ttf')
			setTextFont('sick','Fontsona4Golden.ttf')
			setTextFont('good','Fontsona4Golden.ttf')
			setTextFont('bad','Fontsona4Golden.ttf')
			setTextFont('shit','Fontsona4Golden.ttf')
			setTextFont('breaks','Fontsona4Golden.ttf')
			setTextFont('combo','Fontsona4Golden.ttf')
			setTextFont('combo3','Fontsona4Golden.ttf')
			setTextFont('combo2','Fontsona4Golden.ttf')
			setTextFont('score','Fontsona4Golden.ttf')
			setTextFont('accuracy','Fontsona4Golden.ttf')
			setTextFont('continue','Fontsona4Golden.ttf')
		else
			setTextFont('cleared','Fontsona5Royal.ttf')
			setTextFont('playedOn','Fontsona5Royal.ttf')
			setTextFont('judge','Fontsona5Royal.ttf')
			setTextFont('sick','Fontsona5Royal.ttf')
			setTextFont('good','Fontsona5Royal.ttf')
			setTextFont('bad','Fontsona5Royal.ttf')
			setTextFont('shit','Fontsona5Royal.ttf')
			setTextFont('breaks','Fontsona5Royal.ttf')
			setTextFont('combo','Fontsona5Royal.ttf')
			setTextFont('combo3','Fontsona5Royal.ttf')
			setTextFont('combo2','Fontsona5Royal.ttf')
			setTextFont('score','Fontsona5Royal.ttf')
			setTextFont('accuracy','Fontsona5Royal.ttf')
			setTextFont('continue','Fontsona5Royal.ttf')
		end
	return Function_Stop;
end
return Function_Continue;
end

function onCreate()
	topCombo = 0
	combo = 0
end

function onUpdate()
	if topCombo < getProperty('combo') then
		topCombo = getProperty('combo')
	end
	if te then
	triggerEvent('Play Animation','hey-loop', 'bf')
	end
	combo = getProperty('combo')
	if keyboardJustPressed('ENTER') and te then
		allowEnd = true;
		setPropertyFromClass('flixel.FlxG','mouse.visible', false)
		endSong();
	end
end

function round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return  x / n
end