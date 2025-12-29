local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local enabled = false
local ESPs = {}

--------------------------------------------------
-- เช็กว่าเห็นตรงหรือไม่ (Line of Sight)
--------------------------------------------------
local function hasLineOfSight(player)
	if not player.Character then return false end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local origin = Camera.CFrame.Position
	local direction = hrp.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		player.Character
	}
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, params)

	-- ถ้าไม่โดนอะไรเลย = เห็นตรง
	return result == nil
end

--------------------------------------------------
-- ใส่ ESP
--------------------------------------------------
local function addESP(player)
	if player == LocalPlayer then return end
	if not player.Character then return end

	if ESPs[player] then
		ESPs[player]:Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.FillTransparency = 0.4
	highlight.OutlineTransparency = 0
	highlight.Adornee = player.Character
	highlight.Parent = player.Character

	ESPs[player] = highlight
end

--------------------------------------------------
-- เปิด / ปิด ESP
--------------------------------------------------
local function enableESP()
	for _, player in ipairs(Players:GetPlayers()) do
		addESP(player)
	end
end

local function disableESP()
	for _, esp in pairs(ESPs) do
		if esp then esp:Destroy() end
	end
	ESPs = {}
end

--------------------------------------------------
-- รองรับ Respawn
--------------------------------------------------
local function hookCharacter(player)
	if player == LocalPlayer then return end

	player.CharacterAdded:Connect(function()
		if enabled then
			task.wait(0.2)
			addESP(player)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	hookCharacter(player)
end

Players.PlayerAdded:Connect(hookCharacter)

--------------------------------------------------
-- อัปเดตสี ESP ทุกเฟรม
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not enabled then return end

	for player, esp in pairs(ESPs) do
		if esp and player.Character then
			if hasLineOfSight(player) then
				-- เห็นตรง → สีน้ำเงิน
				esp.FillColor = Color3.fromRGB(0, 120, 255)
				esp.OutlineColor = Color3.fromRGB(0, 180, 255)
			else
				-- หลังกำแพง → สีขาว
				esp.FillColor = Color3.fromRGB(255, 255, 255)
				esp.OutlineColor = Color3.fromRGB(200, 200, 200)
			end
		end
	end
end)

--------------------------------------------------
-- กด N เปิด / ปิด ESP
--------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.R then
		enabled = not enabled
		if enabled then
			enableESP()
			print("ESP: ON")
		else
			disableESP()
			print("ESP: OFF")
		end
	end
end)
