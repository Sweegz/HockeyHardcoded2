local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PuckCollisionService = {}

function PuckCollisionService:Start()
	RunService.Heartbeat:Connect(function()
		local puck = Workspace.Pucks:FindFirstChild("Puck")
		if not puck then
			return
		end

		if puck.AssemblyLinearVelocity.Magnitude > 10 then
			PhysicsService:CollisionGroupSetCollidable("Puck", "Character", true)
			PhysicsService:CollisionGroupSetCollidable("Puck", "Legs", true)
			PhysicsService:CollisionGroupSetCollidable("Puck", "Stick", true)
			PhysicsService:CollisionGroupSetCollidable("Puck", "Blade", true)
		else
			PhysicsService:CollisionGroupSetCollidable("Puck", "Character", false)
			PhysicsService:CollisionGroupSetCollidable("Puck", "Legs", false)
			PhysicsService:CollisionGroupSetCollidable("Puck", "Stick", false)
			PhysicsService:CollisionGroupSetCollidable("Puck", "Blade", false)
		end
	end)
end

return PuckCollisionService
