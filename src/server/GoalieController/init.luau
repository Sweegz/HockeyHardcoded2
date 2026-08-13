local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animator = require(script.Animator)
local StateMachine = require(script.StateMachine)
local Standing2 = require(script.StateMachine.Standing2)
local GoalieAnimations = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Goalie")

local Goalie = {}
Goalie.__index = Goalie

type GoalieData = {
	model: Model,
	center: BasePart,
	move: BasePart,
	primaryPart: BasePart,
	humanoid: Humanoid,
	stateMachine: any?,
	animator: any?,
	reacting: number,
}

function Goalie.New(model: Model)
	local humanoid = model:WaitForChild("Humanoid") :: Humanoid

	local self: GoalieData = {
		model = model,
		center = model.Parent:WaitForChild("Center") :: BasePart,
		move = model.Parent:WaitForChild("Move") :: BasePart,
		primaryPart = model.PrimaryPart :: BasePart,
		humanoid = humanoid,
		reacting = 0,
	}
	setmetatable(self, Goalie)

	self.animator = Animator.New(self)
	self.animator:Enable()
	self.stateMachine = StateMachine.New(Standing2.New(self))
	self.stateMachine:Enable(Standing2.New(self))

	return self
end

function Goalie:ChangeState(stateName: string)
	self.stateMachine:ChangeStateByName(stateName, self)
end

return Goalie
