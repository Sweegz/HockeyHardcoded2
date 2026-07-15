local STATES = {}
for _, child in script:GetChildren() do
	if child:IsA("ModuleScript") then
		STATES[child.Name] = require(child)
	end
end

local StateMachine = {}

StateMachine.__index = StateMachine

function StateMachine.New(state)
	local self = {
		state = state,
		previous_state = nil,
		time_in_state = 0,
		states = {},
	}

	for name, child in STATES do
		self.states[name] = child
	end

	setmetatable(self, StateMachine)

	return self
end

function StateMachine:ChangeState(state)
	self.state:Exit()
	if self.previous_state then
		self.previous_state:Destroy()
	end
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
