local player = game.Players.LocalPlayer
local notifier = player.PlayerGui.Main.Radar

-- Displays text on the same label that we use to locate fruits (notifier)
local function showText(text, time)
	notifier.Text = text
	notifier.Visible = true

	task.wait(time)

	notifier.Visible = false
end

-- Plays sound (like when a fruit spawn)
local function playDing()
	local sound = Instance.new("Sound", workspace)
	sound.SoundId = "rbxassetid://3997124966"
	sound.Volume = 1
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Little colored dot (green = on / red = off)
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

	-- The Blox Fruits settings image button at the right
	local settings = player.PlayerGui.Main.Settings

	-- Creates the notifier switch by making a copy of an existent Blox Fruits switch
	switch = settings.DmgCounterButton:Clone()
	switch.Notify.Text = "Mostra a localizacao das frutas spawnadas"
	switch.Position = UDim2.new(-1.2, 0, -4.03, 0) -- Above counter switch
	switch.Size = UDim2.new(5, 0, 0.8, 0) -- Similar size to other switchs
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

-- To store the connection, so after we can disconnect on switch click (also used to check switch state)
local workspaceConnection

-- To be called when a fruit spawns
local function enableNotifier(fruit)
	local fruitName = "Uma fruta"

	-- Fruit hasn't a position but it's children has
	local fruitChild = fruit:WaitForChild("Handle")

	-- The MeshPart is a children of the fruit and the name is like Meshes/fruitsname_34 so we need to extract only the name
	for __, descendant in ipairs(fruit:GetChildren()) do -- Iterates over fruit's children
		if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then -- Spawned fruits have their name on a MeshPart
			local i, j = string.find(descendant.Name, '_') -- Gets the index of '_'

			fruitName = string.sub(descendant.Name, 8, i - 1) -- Keep the fruit name after "Meshes/" and before '_'

			-- Fixing some names
			if string.lower(fruitName) == "magu" then
				fruitName = "Magma"
			elseif string.lower(fruitName) == "smouke" then
				fruitName = "Smoke"
			elseif string.lower(fruitName) == "quaketest" then
				fruitName = "Quake"
			end

			fruitName = "Fruta " .. fruitName:gsub("^%l", string.upper)
			fruitName = fruitName:gsub("%d+", '') -- Removes numbers from string

			break
		end
	end

	playDing()
	notifier.Visible = true
	local fruitAlive = true

	-- Keeps updating the distance if fruit is alive and switch is on
	while fruitAlive and workspaceConnection do
		notifier.Text = fruitName .. " encontrada a: " .. math.floor((player.Character:WaitForChild("UpperTorso").Position - fruitChild.Position).Magnitude * 0.15) .. 'm'

		task.wait(0.2)

		fruitAlive = workspace:FindFirstChild(fruit.Name)
	end

	if not fruitAlive then
		showText("Fruta despawnada/coletada", 4)
	end
end

local led = createLed()
local switch = createSwitch()

local function onSwitchClick()
	-- Enables/disables the workspace connection listening for children added 
	if workspaceConnection then -- check if we are connected
		switch.TextLabel.Text = "Notificador (DESATIVADO)"
		led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		
		workspaceConnection:Disconnect() -- disconnect the event and stop the listening
		workspaceConnection = nil -- clear the variable

		showText("Notificador desligado com sucesso", 4)

	else -- if the connection does not exist
		switch.TextLabel.Text = "Notificador (ATIVADO)"
		led.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		
		showText("Notificador ativado com sucesso", 4)

		-- Connect the event and start the listening
		workspaceConnection = workspace.ChildAdded:Connect (function(child)
			-- If the added child is a fruit enables the notifier
			if child.Name == "Fruit " then -- Intended space
				enableNotifier(child)
			end
		end)

		-- Looks for an already spawned fruit and enable notifier if there's one
		local fruit = workspace:FindFirstChild("Fruit ") -- Intended space

		if fruit then
			enableNotifier(fruit)
		end
	end
end

showText("Script ativado com sucesso", 4)

-- Enables the notifier on startup by simulating a switch click
onSwitchClick()

-- Enables/disables the notifier when notifier switch is clicked
switch.Activated:Connect(onSwitchClick)

-- euyogi
