local shots = {}

local SLAPSHOT_THRESHHOLD = 0.5

local BASE_SPEED = 40
local POWER_SPEED_MULTIPLIER = 100

local BASE_SPEED_SLAPSHOT = 60
local POWER_SPEED_MULTIPLIER_SLAPSHOT = 100

function shots.apply_velocity(puck: BasePart, velocity: Vector3)
	puck.AssemblyLinearVelocity = velocity
end

function shots.apply_force(puck: BasePart, force: Vector3, time: number)
	if force then
		local VF = Instance.new("VectorForce")
		VF.Attachment0 = puck:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", puck)
		VF.Force = force
		VF.RelativeTo = Enum.ActuatorRelativeTo.World
		VF.Parent = puck
		game:GetService("Debris"):AddItem(VF, time)
	end
end

function shots.calculate_vel_and_force_slapshot(power: number, dir: Vector3)
	power = power / 100
	local power_quartic = 1 - math.pow((1 - power), 4)
	local velocity = BASE_SPEED_SLAPSHOT + power_quartic * POWER_SPEED_MULTIPLIER_SLAPSHOT

	local final_velocity = dir * velocity
	local final_force = nil
	local final_time = 0

	final_velocity += Vector3.new(0, 12 * power ^ 2, 0)
	final_force = Vector3.new(0, 650, 0)
	final_time = 0.9

	print(final_velocity)

	return final_velocity, final_force, final_time
end

function shots.calculate_vel_and_force(power: number, dir: Vector3, flags: {})
	power = power / 100
	local power_quartic = 1 - math.pow((1 - power), 4)
	local velocity = BASE_SPEED + power_quartic * POWER_SPEED_MULTIPLIER

	local final_velocity = dir * velocity
	local final_force = nil
	local final_time = 0

	if flags["chip"] and power > 0.3 then
		print("Lol")
		final_velocity *= 0.6
		final_velocity += Vector3.new(0, 14 * power ^ 2, 0)
		final_force = Vector3.new(0, 650, 0)
		final_time = 0.9
	elseif power > SLAPSHOT_THRESHHOLD then
		final_velocity += Vector3.new(0, 18 * power ^ 2, 0)
		final_force = Vector3.new(0, 650, 0)
		final_time = 0.9
	end

	return final_velocity, final_force, final_time
end

function shots.lowtip(player: Player, puck: BasePart, stick_cframe: CFrame, dir: Vector3, p_Velocity: Vector3)
	local final_velocity = dir * p_Velocity.Magnitude * 1.25
	final_velocity += Vector3.new(0, 18, 0)
	puck.AssemblyLinearVelocity = final_velocity
end

function shots.hightip(player: Player, puck: BasePart, stick_cframe: CFrame, dir: Vector3, p_Velocity: Vector3)
	local final_velocity = -dir * 110
	puck.AssemblyLinearVelocity = final_velocity
end

return shots
