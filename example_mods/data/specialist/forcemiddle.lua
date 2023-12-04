function onCreatePost()
    for i = 0, 3 do 
        setPropertyFromGroup("strumLineNotes", i, "x", -1000)
    end

    for i = 4, 7 do 
        if not middlescroll then
            setPropertyFromGroup("strumLineNotes", i, "x", screenWidth/2 + ((i % 4) * 112) - 230)
        end
    end
end

function onCountdownStarted()

	for i = 0, 3 do 
        setPropertyFromGroup("strumLineNotes", i, "x", -1000)
    end

    for i = 4, 7 do 
        if not middlescroll then
            setPropertyFromGroup("strumLineNotes", i, "x", screenWidth/2 + ((i % 4) * 112) - 230)
        end
    end
end