--!strict
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local lib = {}
lib.__index = lib

local function new(instance: Model, tweenInfo: {time: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection}, targetCFrame: CFrame)
    local this = setmetatable({}, lib)
    this.id = HttpService:GenerateGUID(false)
    this.alpha = 0
    this.model = instance
    this.originCFrame = this.model:GetPivot()
    this.targetCFrame = targetCFrame
    this.tweenInfo = tweenInfo
    this.Completed = signal.new()
    this.renderSteppedFn = function(deltaTime: number)
        this.alpha += (deltaTime / tweenInfo.time)
        if this.alpha >= 1 then
            this:Stop()
        end
        local alphaPrime = TweenService:GetValue(this.alpha, this.tweenInfo.easingStyle, this.tweenInfo.easingDirection)
        local computedCFrame = this.originCFrame:Lerp(this.targetCFrame, alphaPrime)

        local linearVelocity = (computedCFrame.Position - this.model:GetPivot().Position) * (1 / deltaTime)
        local angularVelocity = Vector3.new((this.model:GetPivot():ToObjectSpace(computedCFrame)):ToEulerAngles()) * (1 / deltaTime)

        for _, x in this.model:GetDescendants() do
            if x:IsA("BasePart") then
                x.AssemblyLinearVelocity = linearVelocity
                x.AssemblyAngularVelocity = angularVelocity
            end
        end

        this.model:PivotTo(computedCFrame)
    end

    return this
end

function lib:Play()
    RunService:BindToRenderStep(self.id, 99, self.renderSteppedFn)
end

function lib:Stop()
    RunService:UnbindFromRenderStep(self.id)
end

return new