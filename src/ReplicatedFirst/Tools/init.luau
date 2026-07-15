local module = {}

for _, child in script:GetDescendants() do
	if child:IsA("ModuleScript") then
		module[child.Name] = require(child)
	end
end

script.Parent = nil
script:Destroy()

return module
