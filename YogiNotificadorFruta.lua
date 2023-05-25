local player = game.Players.LocalPlayer

-- The switch to turn the notifier on/off
local function createSwitch()
	local switch

    -- The settings image button at the right on Blox Fruits
    local settings = player.PlayerGui.Main.Settings

    -- Creates the notifier switch by making a copy of an existent switch
    switch = settings.DmgCounterButton:Clone()
    switch.Notify.Text = "Mostra a localização das frutas spawnadas"
    switch.Position = UDim2.new(-1.2, 0, -4.03, 0) -- Above counter switch
    switch.Size = UDim2.new(5, 0, 0.8, 0) -- Similar size to the other switchs
    switch.Parent = settings

    -- Shows/hide the switch when settings image button is clicked
    settings.Activated:Connect(function()
        if switch.Visible then
            switch.Visible = false
        else
            switch.Visible = true
        end
    end)

	switch.Name = "NotifierSwitch"
	switch.TextLabel.Text = "Notificador (OFF)"

	return switch
end

-- Creates the switch to turn the notifier on/off
local switch = createSwitch()

-- Creates the notifier
local notifier = player.PlayerGui.Main.Radar

-- Variable to keep the connection, so after we can disconnect when click the switch
local workspaceConnection

local function textToNotifier(text, time)
    notifier.Text = text
    notifier.Visible = true

    task.wait(time)

    notifier.Visible = false
end

-- To be called when a fruit spawns
local function enableNotifier(fruit)
	local fruitName = "Uma fruta"

	task.wait(1) -- Wait for children to born (I think that fixes most fruits spawning without name)

	-- The MeshPart is a children of the fruit and the name is like Meshes/fruitsname_34
	for __, descendant in ipairs(fruit:GetChildren()) do -- Iterates over fruit's children
		if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then -- Spawned fruits have their name on a MeshPart
			local i, j = string.find(descendant.Name, "_") -- Gets the index of "_"

			fruitName = string.sub(descendant.Name, 8, i - 1) -- Keep the fruit name after "Meshes/" and before "_"

            if fruitName == "MAGU" then
                fruitName = "Magma"
            elseif fruitName == "smouke" then
                fruitName = "Smoke"
            end

			fruitName = "Fruta " .. fruitName:gsub("^%l", string.upper)
            fruitName = fruitName:gsub("%d+", "")

			break
		end
	end

    notifier.Visible = true

    local fruitAlive = true

    -- Fruit hasn't a position but it's children has
    local fruitChild = fruit:FindFirstChildOfClass("Part")
	
    while fruitAlive and workspaceConnection do
        notifier.Text = fruitName .. " encontrada à: " .. math.floor((player.Character:WaitForChild("UpperTorso").Position - fruitChild.Position).Magnitude * 0.15) .. "m"

        task.wait(0.2)

        fruitAlive = workspace:FindFirstChild(fruit.Name)
    end
	
    if not fruitAlive then
        textToNotifier("Fruta despawnada/coletada", 5)
    end
end

-- Enables/disables the notifier when notifier switch is clicked
switch.Activated:Connect(function()
    
	-- Enables/disables the workspace connection listening for children added 
	if workspaceConnection then -- check if we are connected
		switch.TextLabel.Text = "Notificador (OFF)"

		workspaceConnection:Disconnect() -- disconnect the event and stop the listening
		workspaceConnection = nil -- clear the variable
			
		textToNotifier("Notificador desligado com sucesso", 5)

	else -- if the connection does not exist
		switch.TextLabel.Text = "Notificador (ON)"
		
		textToNotifier("Notificador ativado com sucesso", 5)
			
		-- Connect the event and start the listening
		workspaceConnection = workspace.ChildAdded:Connect (function(child)
			-- If the added child is a fruit enables the notifier
			if child.Name == "Fruit " then
				enableNotifier(child)
            end
		end)
	end

    -- Gets a fruit and enable notifier if it already spawned
    local fruit = workspace:FindFirstChild("Fruit ")

    if fruit then
        enableNotifier(fruit)
    end
end)

textToNotifier("Script ativado com sucesso", 5)
