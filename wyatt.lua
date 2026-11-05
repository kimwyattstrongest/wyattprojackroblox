-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Local Player & Camera
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration
local LOCKED_PART = "HumanoidRootPart" -- เปลี่ยนเป็นล็อกลำตัวเพื่อความชัวร์ (หรือใช้ "Head")
local FOV_RADIUS = 500 -- ขยายรัศมีการค้นหาจากเมาส์ให้กว้างขึ้น
local isLocked = false

-- ฟังก์ชันค้นหาเป้าหมายที่ใกล้เมาส์ที่สุด
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, player in ipairs(Players:GetPlayers()) do
		-- ไม่ล็อกตัวเอง และตรวจสอบว่าตัวละครยังมีชีวิตอยู่
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			local targetPart = player.Character:FindFirstChild(LOCKED_PART) or player.Character:FindFirstChild("Head")
			if targetPart then
				local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
					if distance < FOV_RADIUS and distance < shortestDistance then
						shortestDistance = distance
						closestPlayer = player
					end
				end
			end
		end
	end

	return closestPlayer
end

-- ตรวจจับการกดคลิกขวา
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

-- ลูปบังคับหันกล้อง
RunService.RenderStepped:Connect(function()
	if isLocked then
		local targetPlayer = getClosestPlayer()
		if targetPlayer and targetPlayer.Character then
			local targetPart = targetPlayer.Character:FindFirstChild(LOCKED_PART) or targetPlayer.Character:FindFirstChild("Head")
			if targetPart then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
			end
		end
	end
end)
