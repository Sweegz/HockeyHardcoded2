local Players = game:GetService("Players")
local Momentum = {}

local LocalPlayer = Players.LocalPlayer

local dir_change = false
local is_moving = false
local extended = false

Momentum.__index = Momentum

function Momentum.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
	}

	local character = LocalPlayer.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	self.momentum = humanoidRootPart:FindFirstChild("Momentum ") or Instance.new("BodyVelocity")
	self.momentum.Parent = humanoidRootPart
	self.momentum.MaxForce = Vector3.new(25000, 0, 25000)
	self.momentum.Name = "Momentum"

	setmetatable(self, Momentum)

	return self
end

function Momentum:Enable()
	self.enabled = true

	local character = LocalPlayer.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	self.momentum.Parent = humanoidRootPart
end

local CONFIG = {
	angular_friction = 0.005,
	angular_friction_glide = 0.04,
	angular_velocity_threshhold = 10,
	glide_speed_modifier_accelerating = 0.04,
	glide_speed_modifier_resisting = 0.06064,
	velocity_damp_factor = 0.825,
	direction_lerp_factor = 0.6,
}

function Momentum:Tick(dt: number)
	if not self.enabled then
		return
	end

	extended = self.stickController.extended
	local humanoid = self.stickController.humanoid

	if humanoid.WalkSpeed > 47 then
		humanoid.WalkSpeed = 47
	elseif humanoid.WalkSpeed < 47 and humanoid.WalkSpeed > 38 then
		humanoid.WalkSpeed = 38
	end

	local momentum = self.momentum

	local character = LocalPlayer.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	task.spawn(function()
		local glide_speed_modifier = nil
		if humanoid.MoveDirection.Magnitude > 0 then
			local max_glide_velocity = 60
			if humanoid.WalkSpeed > 33 then
				max_glide_velocity = 80
			end
			if (momentum.Velocity + humanoid.MoveDirection * humanoid.WalkSpeed).Magnitude <= max_glide_velocity then
				glide_speed_modifier = CONFIG.glide_speed_modifier_accelerating
				if not dir_change then
					dir_change = true
					local velocity_reference = momentum
					velocity_reference.Velocity = velocity_reference.Velocity * CONFIG.velocity_damp_factor
				end
			else
				if momentum.Velocity.Magnitude > humanoid.WalkSpeed + 1 and not is_moving then
					local velocity_reference2 = momentum
					velocity_reference2.Velocity = velocity_reference2.Velocity * CONFIG.velocity_damp_factor
				end
				dir_change = false
				glide_speed_modifier = CONFIG.glide_speed_modifier_resisting
			end
			local _ = nil
			glide_speed_modifier = glide_speed_modifier
				+ if not extended
					then humanoidRootPart.AssemblyAngularVelocity.Magnitude / 18 * CONFIG.angular_friction
					else humanoidRootPart.AssemblyAngularVelocity.Magnitude / 18 * CONFIG.angular_friction_glide
		else
			glide_speed_modifier = 0.1
		end
		local frame_rate = 1 / 60

		if not is_moving then
			if humanoidRootPart.AssemblyAngularVelocity.Magnitude <= CONFIG.angular_velocity_threshhold then
				if momentum.Velocity.X ~= (0 / 0) then
					momentum.Velocity = humanoidRootPart.AssemblyLinearVelocity
				end
				local walk_speed = humanoid.WalkSpeed
				local alpha = 1 - (1 - glide_speed_modifier) ^ (dt / frame_rate)
				momentum.Velocity = momentum.Velocity:Lerp(humanoid.MoveDirection * walk_speed, alpha)
			else
				local desired_dir_velocity = nil
				if momentum.Velocity.Magnitude > 0 then
					desired_dir_velocity = (momentum.Velocity / momentum.Velocity.Magnitude):Lerp(
						humanoid.MoveDirection,
						CONFIG.direction_lerp_factor
					)
				else
					desired_dir_velocity = Vector3.new(0, 0, 0):Lerp(humanoid.MoveDirection, 0.6)
				end

				if desired_dir_velocity then
					local walk_speed2 = humanoid.WalkSpeed
					local alpha = 1 - (1 - glide_speed_modifier) ^ (dt / frame_rate)
					momentum.Velocity = momentum.Velocity:Lerp(desired_dir_velocity * walk_speed2, alpha)
				end
			end
		end
	end)
end

function Momentum:Disable()
	self.enabled = false
	self.momentum.Parent = nil
end

return Momentum
