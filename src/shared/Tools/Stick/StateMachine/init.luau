local StateMachine = {}

StateMachine.__index = StateMachine

function StateMachine.New(state)
	local self = {
		state = state,
		previous_state = nil,
		time_in_state = 0,
		states = {},
	}

	for k, v in script:GetChildren() do
		if v:IsA("ModuleScript") then
			self.states[v.Name] = require(v)
		end
	end

	setmetatable(self, StateMachine)

	return self
end

function StateMachine:ChangeState(state)
	self.state:Exit()
	self.previous_state = self.state
	self.state = state
	self.state:Enter()
end

function StateMachine:Enable(state)
	if state then
		self.state = state
	end
	self.state:Enter()
end

function StateMachine:Disable()
	self.state:Exit()
end

function StateMachine:Tick(dt: number)
	self.state:Tick(dt)
end

function StateMachine:Destroy() end

return StateMachine
