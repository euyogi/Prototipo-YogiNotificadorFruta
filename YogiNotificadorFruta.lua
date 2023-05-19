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
        if (switch.Visible) then
            switch.Visible = false
        else
            switch.Visible = true
        end
    end)

	switch.Name = "NotifierSwitch"
	switch.TextLabel.Text = "Notificador (OFF)"

	return switch
end

-- Creates the switch to turn the ESP on/off
local switch = createSwitch()

-- Creates the notifier
local notifier = player.PlayerGui.Main.Radar

-- Variable to keep the connection, so after we can disconnect when click the switch
local workspaceConnection

-- To be called when a fruit spawns
local function enableNotifier(fruit)
	local fruitName = "Uma fruta"

	wait(1) -- Wait for children to born (I think that fixes most fruits spawning without name)

	-- The MeshPart is a children of the fruit and the name is like Meshes/fruitsname_34
	for __, descendant in ipairs(fruit:GetChildren()) do -- Iterates over fruit's children
		if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then -- Spawned fruits have their name on a MeshPart
			local i, j = string.find(descendant.Name, "_") -- Gets the index of "_"

			fruitName = string.sub(descendant.Name, 8, i - 1) -- Keep the fruit name after "Meshes/" and before "_"
			fruitName = "Fruta " .. fruitName:gsub("^%l", string.upper)

			break
		end
	end

    notifier.Visible = true

    local fruitAlive = true

    while fruitAlive and workspaceConnection do
        notifier.Text = fruitName .. " encontrada a: " .. math.floor(((workspace.Characters.LocalPlayer.UpperTorso.Position - fruit.Position).Magnitude) * 0.28) .. "m"

        wait(0.5)

        fruitAlive = workspace:FindFirstChild(fruit.Name)
    end

    if not fruitAlive then
        notifier.Text = "Fruta despawnada/coletada"
    end

    if not workspaceConnection then
        notifier.Text = "Notificador desligado com sucesso"
    end

    wait(10)

    notifier.Visible = false
end

-- Enables/disables the ESP when ESP switch is clicked
switch.Activated:Connect(function()

	-- Enables/disables the workspace connection listening for children added 
	if workspaceConnection then -- check if we are connected
		switch.TextLabel.Text = "Notificador (OFF)"

		workspaceConnection:Disconnect() -- disconnect the event and stop the listening
		workspaceConnection = nil -- clear the variable

	else -- if the connection does not exist
		switch.TextLabel.Text = "Notificador (ON)"

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