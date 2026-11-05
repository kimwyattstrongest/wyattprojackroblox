-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Local Player & Camera
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration
local LOCKED_PART = "Head" -- ส่วนที่ต้องการล็อก เช่น "Head" (หัว) หรือ "HumanoidRootPart" (ลำตัว)
local isLocked = false

-- ฟังก์ชันค้นหาผู้เล่นที่ใกล้เคียงกับตำแหน่งเมาส์มากที่สุดภายในระยะ FOV
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			local targetPart = player.Character:FindFirstChild(LOCKED_PART)
			if targetPart then
				-- เช็คว่าตัวละครเป้าหมายมองเห็นได้ (ไม่อยู่หลังกำแพงทึบเกินไป หรือเช็คระยะหน้าจอ)
				local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
					-- กำหนดระยะห่างสูงสุดจากเมาส์ (เช่น รัศมี 200 พิกเซล) เพื่อป้องกันการล็อกมั่ว
					if distance < 200 and distance < shortestDistance then
						shortestDistance = distance
						closestPlayer = player
					end
				end
			end
		end
	end

	return closestPlayer
end

-- ตรวจจับการกดคลิกขวา (MouseButton2)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isLocked = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isLocked = false
	end
end)

-- ลูปการทำงานหลักในการหันมุมกล้องไปที่เป้าหมาย
RunService.RenderStepped:Connect(function()
	if isLocked then
		local targetPlayer = getClosestPlayer()
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild(LOCKED_PART) then
			local targetPart = targetPlayer.Character[LOCKED_PART]
			-- บังคับให้กล้องหันไปที่ตำแหน่งเป้าหมายทันที
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
		end
	end
end)
