function onCreate()
	makeLuaSprite('walls', 'persona/stages/mementos/walls', -450, -150)
	scaleObject('walls', 1.2, 1.2, false)
	setScrollFactor('walls', 0.8, 1)
	addLuaSprite('walls')

	createTrain(3000, -150, 'persona/stages/mementos/train', 'train_passes')

	makeLuaSprite('platform', 'persona/stages/mementos/platform', -450, -150)
	scaleObject('platform', 1.2, 1.2, false)
	addLuaSprite('platform')
end

function onCreatePost()
	if not lowQuality then
		makeLuaSprite('overlay', 'persona/stages/mementos/overlay', -450, -150)
		scaleObject('overlay', 1.2, 1.2, false)
		addLuaSprite('overlay', true)
	end
end

local trainSound
local createdTrain = false
function createTrain(x, y, image, sound)
	makeLuaSprite('train', image, x, y)
	setProperty('train.antialiasing', antialiasing)
	addLuaSprite('train')
	trainSound = sound
	createdTrain = true
end

local moving = false
local finishing = false
local startedMoving = false
local frameTiming = 0 -- Simulates 24fps cap

local cars = 8
local cooldown = 0

function onUpdatePost(elapsed)
	if createdTrain and moving then
		frameTiming = frameTiming + elapsed
		if frameTiming >= 1 / 24 then
			if getSoundTime('trainSound') >= 4700 then
				startedMoving = true
				if getProperty('gf') ~= nil then
					playAnim('gf', 'hairBlow')
					setProperty('gf.specialAnim', true)
				end
		
				if startedMoving then
					setProperty('train.x', getProperty('train.x') - 400)
					if getProperty('train.x') < -0 and not finishing then
						setProperty('train.x', 850)
						cars = cars - 1

						if cars <= 0 then
							finishing = true
						end
					end

					if getProperty('train.x') < -2000 and finishing then
						restart()
					end
				end
				frameTiming = 0
			end
		end
	end
end

function onBeatHit()
	if createdTrain and not moving then
		cooldown = cooldown + 1

		if curBeat % 8 == 4 and getRandomBool(30) and not moving and cooldown > 8 then
			cooldown = getRandomInt(-4, 0)
			start()
		end
	end
end
	
function start()
	if not createdTrain then return end
	moving = true
	playSound(trainSound, 1, 'trainSound')
end

function restart()
	if createdTrain and getProperty('gf') ~= nil then
		setProperty('gf.danced', false) -- Makes she bop her head to the correct side once the animation ends
		playAnim('gf', 'hairFall')
		setProperty('gf.specialAnim', true)
		setProperty('train.x', screenWidth + 1200)
		moving = false
		cars = 8
		finishing = false
		startedMoving = false
	end
end