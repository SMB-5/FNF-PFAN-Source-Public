function onCountdownStarted()
	for i = 0, 3 do 
        setPropertyFromGroup("strumLineNotes", i, "x", -1000)
    end

    if not middlescroll then
        for i = 4, 7 do 
            setPropertyFromGroup("strumLineNotes", i, "x", screenWidth/2 + ((i % 4) * 112) - 240)
        end
    end
end