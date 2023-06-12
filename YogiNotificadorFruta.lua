local player = game.Players.LocalPlayer

local function playDing()
	local sound = Instance.new("Sound", workspace)
	sound.SoundId = "rbxassetid://3997124966"
	sound.Volume = 8
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Little colored dot
local function createLed()
	local led = Instance.new("Frame")
	
	led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	led.BackgroundTransparency = 0.3
	led.Position = UDim2.new(1.3, 0, 0.35, 0)
	led.Size = UDim2.new(0, 8, 0, 8)
	led.Name = "NotifierLed"
	
	local border = Instance.new("UICorner", led)
	border.CornerRadius = UDim.new(1)
	
	-- Shows/hides the led when twitter image button is clicked
	player.PlayerGui.Main.Code.Activated:Connect(function()
		if led.Visible then
			led.Visible = false
		else
			led.Visible = true
		end
	end)
	
	led.Parent = player.PlayerGui.Main.Code

	return led	
end

-- Switch to turn the notifier on/off
local function createSwitch()
	local switch

	-- The settings image button at the right on Blox Fruits
	local settings = player.PlayerGui.Main.Settings

	-- Creates the notifier switch by making a copy of an existent switch
	switch = settings.DmgCounterButton:Clone()
	switch.Notify.Text = "Mostra a localização das frutas spawnadas"
	switch.Position = UDim2.new(-1.2, 0, -4.03, 0) -- Above counter switch
	switch.Size = UDim2.new(5, 0, 0.8, 0) -- Similar size to the other switchs
	switch.Name = "NotifierSwitch"
	switch.TextLabel.Text = "Notificador (DESATIVADO)"
	switch.Parent = settings
	
	-- Shows/hides the switch when settings image button is clicked
	settings.Activated:Connect(function()
		if switch.Visible then
			switch.Visible = false
		else
			switch.Visible = true
		end
	end)

	return switch
end

-- Creates the led to show if notifier is on/off
local led = createLed()

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
	playDing()

	local fruitName = "Uma fruta"

	-- Fruit hasn't a position but it's children has
	local fruitChild = fruit:WaitForChild("Handle") -- Wait for children to born (I think this also fixes some fruits spawning without name)

	-- The MeshPart is a children of the fruit and the name is like Meshes/fruitsname_34
	for __, descendant in ipairs(fruit:GetChildren()) do -- Iterates over fruit's children
		if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then -- Spawned fruits have their name on a MeshPart
			local i, j = string.find(descendant.Name, "_") -- Gets the index of "_"

			fruitName = string.sub(descendant.Name, 8, i - 1) -- Keep the fruit name after "Meshes/" and before "_"

			if string.lower(fruitName) == "magu" then
				fruitName = "Magma"
			elseif string.lower(fruitName) == "smouke" then
				fruitName = "Smoke"
			elseif string.lower(fruitName) == "quaketest" then
				fruitName = "Quake"
			end

			fruitName = "Fruta " .. fruitName:gsub("^%l", string.upper)
			fruitName = fruitName:gsub("%d+", "")

			break
		end
	end

	notifier.Visible = true

	local fruitAlive = true

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
		switch.TextLabel.Text = "Notificador (DESATIVADO)"
		led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		
		workspaceConnection:Disconnect() -- disconnect the event and stop the listening
		workspaceConnection = nil -- clear the variable

		textToNotifier("Notificador desligado com sucesso", 5)

	else -- if the connection does not exist
		switch.TextLabel.Text = "Notificador (ATIVADO)"
		led.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		
		textToNotifier("Notificador ativado com sucesso", 5)

		-- Connect the event and start the listening
		workspaceConnection = workspace.ChildAdded:Connect (function(child)
			-- If the added child is a fruit enables the notifier
			if child.Name == "Fruit " then
				enableNotifier(child)
			end
		end)

		-- Gets a fruit and enable notifier if it already spawned
		local fruit = workspace:FindFirstChild("Fruit ")

		if fruit then
			enableNotifier(fruit)
		end
	end
end)

textToNotifier("Script ativado com sucesso", 4)
textToNotifier("Ative o notificador no menu engrenagem", 4)
