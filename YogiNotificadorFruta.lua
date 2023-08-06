local local_player = game.Players.LocalPlayer
local notifier = local_player.PlayerGui:WaitForChild("Main"):WaitForChild("Radar")

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
	sound.PlaybackSpeed = 4
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Little colored dot (green = on / red = off)
local function createLed()
	-- The Blox Fruits twitter image button at the right
	local twitter_button = local_player.PlayerGui.Main.Code
	if twitter_button:FindFirstChild("NotifierLed") then
		twitter_button.NotifierLed:Destroy()
	end
	
	local led = Instance.new("Frame")
	led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	led.BackgroundTransparency = 0.3
	led.Position = UDim2.new(1.3, 0, 0.35, 0)
	led.Size = UDim2.new(0, 8, 0, 8)
	led.Name = "NotifierLed"
	led.Parent = twitter_button

	local border = Instance.new("UICorner", led)
	border.CornerRadius = UDim.new(1)
	
	-- Shows/hides the led when twitter image button is clicked
	twitter_button.Activated:Connect(function()
		if led.Visible then
			led.Visible = false
		else
			led.Visible = true
		end
	end)

	return led	
end

local lang = game:GetService("LocalizationService").RobloxLocaleId

-- Switch to turn the notifier on/off
local function createSwitch()
	-- The Blox Fruits settings image button at the right
	local settings_button = local_player.PlayerGui.Main.Settings
	if settings_button:FindFirstChild("NotifierSwitch") then
		settings_button.NotifierSwitch:Destroy()
	end
	
	-- Creates the notifier switch by making a copy of an existent Blox Fruits switch
	local switch = settings_button.DmgCounterButton:Clone()
	if (lang == "pt-br") then
		switch.Notify.Text = "Mostra a localizacao das frutas spawnadas"
		switch.TextLabel.Text = "Notificador (DESATIVADO)"
	else
		switch.Notify.Text = "Shows spawned fruits localization"
		switch.TextLabel.Text = "Notifier (OFF)"
	end
	switch.Position = UDim2.new(-1.2, 0, -4.03, 0) -- Above counter switch
	switch.Size = UDim2.new(5, 0, 0.8, 0) -- Similar size to other switchs
	switch.Name = "NotifierSwitch"
	
	switch.Parent = settings_button
	
	-- Shows/hides the switch when settings image button is clicked
	settings_button.Activated:Connect(function()
		if switch.Visible then
			switch.Visible = false
		else
			switch.Visible = true
		end
	end)

	return switch
end

-- To store the connection, so after we can disconnect on switch click (also used to check switch state)
local workspace_connection

-- To be called when a fruit spawns
local function enableNotifier(fruit)
	local fruit_name
	if (lang == "pt-br") then
		fruit_name = "Uma fruta"
	else
		fruit_name = "A fruit"
	end

	-- Fruit hasn't a position but it's children has
	local fruit_child = fruit:WaitForChild("Handle")

	-- The MeshPart is a children of the fruit and the name is like Meshes/fruitsname_34 so we need to extract only the name
	for __, descendant in ipairs(fruit:GetChildren()) do -- Iterates over fruit's children
		if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then -- Spawned fruits have their name on a MeshPart
			local i, j = string.find(descendant.Name, '_') -- Gets the index of '_'

			fruit_name = string.sub(descendant.Name, 8, i - 1) -- Keep the fruit name after "Meshes/" and before '_'

			-- Fixing some names
			if string.lower(fruit_name) == "magu" then
				fruit_name = "Magma"
			elseif string.lower(fruit_name) == "smouke" then
				fruit_name = "Smoke"
			elseif string.lower(fruit_name) == "quaketest" then
				fruit_name = "Quake"
			end

			if (lang == "pt-br") then
				fruit_name = "Fruta " .. fruit_name:gsub("^%l", string.upper)
			else 
				fruit_name = fruit_name:gsub("^%l", string.upper) .. " fruit"
			end
			
			fruit_name = fruit_name:gsub("%d+", '') -- Removes numbers from string

			break
		end
	end

	playDing()
	notifier.Visible = true
	local fruit_alive = true

	-- Keeps updating the distance if fruit is alive and switch is on
	while fruit_alive and workspace_connection do
		if (lang == "pt-br") then
			notifier.Text = fruit_name .. " encontrada a: " .. math.floor((local_player.Character:WaitForChild("UpperTorso").Position - fruit_child.Position).Magnitude * 0.15) .. 'm'
		else 
			notifier.Text = fruit_name .. " found at: " .. math.floor((local_player.Character:WaitForChild("UpperTorso").Position - fruit_child.Position).Magnitude * 0.15) .. "m away"
		end

		task.wait(0.2)

		fruit_alive = workspace:FindFirstChild(fruit.Name)
	end

	if not fruit_alive then
		if (lang == "pt-br") then
			showText("Fruta despawnada/coletada", 3)
		else 
			showText("Fruit despawned/colected", 3)
		end
	end
end

local led = createLed()
local switch = createSwitch()

local function onSwitchClick()
	-- Enables/disables the workspace connection listening for children added 
	if workspace_connection then -- check if we are connected
		workspace_connection:Disconnect() -- disconnect the event and stop the listening
		workspace_connection = nil -- clear the variable
		
		led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

		if (lang == "pt-br") then
			switch.TextLabel.Text = "Notificador (DESATIVADO)"
			showText("Notificador desativado com sucesso", 2)
		else
			switch.TextLabel.Text = "Notifier (OFF)"
			showText("Notifier disabled successfully", 2)
		end
	else -- if the connection does not exist
		led.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		
		if (lang == "pt-br") then
			switch.TextLabel.Text = "Notificador (ATIVADO)"
			showText("Notificador ativado com sucesso", 2)
		else
			switch.TextLabel.Text = "Notifier (ON)"
			showText("Notifier enabled successfully", 2)
		end

		-- Connect the event and start the listening
		workspace_connection = workspace.ChildAdded:Connect(function(child)
			-- If the added child is a fruit enables the notifier
			if child.Name == "Fruit " then -- Intended space
				task.spawn(enableNotifier, child)
			end
		end)

		-- Looks for an already spawned fruit and enable notifier if there's one
		local fruit = workspace:FindFirstChild("Fruit ") -- Intended space

		if fruit then
			task.spawn(enableNotifier, fruit)
		end
	end
end

if (lang == "pt-br") then
	showText("Script ativado com sucesso", 3)
else
	showText("Script enabled successfully", 3)
end

-- Enables the notifier on startup by simulating a switch click
onSwitchClick()

-- Enables/disables the notifier when notifier switch is clicked
switch.Activated:Connect(onSwitchClick)

-- euyogi
