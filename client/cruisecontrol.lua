class("CruiseControl")

function CruiseControl:__init()
	self.enabled = false
	self.speed = 0

	Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "InputPoll", self, self.InputPoll )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "PlayerDeath", self, self.PlayerDeath)
end

function CruiseControl:LocalPlayerChat( args )
	local msg = args.text
	local split_msg = msg:split(" ")

	if split_msg[1] == "/c" then
		local speed = tonumber( split_msg[2] )

		-- If they've specified a speed, then we want to set our 
		-- cruise control speed to that, and turn cruise control on
		if speed ~= nil then
			self.speed = speed
			self.enabled = true
		else
			-- Turn 'er off!
			self.enabled = false
		end

		if speed ~= nil and speed <= 0 then
			Chat:Print("Please use a value over 0!", Color(210, 15, 15))
			self.enabled = false
		end
	end
end

function CruiseControl:GetEnabled()
	if self.enabled == false or LocalPlayer:GetWorld() ~= DefaultWorld then
		return false
	else
		return true
	end
end

function CruiseControl:PlayerDeath()
	self.enabled = false
	print("disabled")
end

function CruiseControl:GetSpeed()
	-- This assumes that they're in a vehicle - make sure you check!
	local vehicle = LocalPlayer:GetVehicle()

	-- Multiply by 3.6 to get in km/h
	return vehicle:GetLinearVelocity():Length() * 3.6
end

function CruiseControl:Render()
	if Game:GetState() ~= GUIState.Game or not self:GetEnabled() then return end
	if not LocalPlayer:InVehicle() then return end

	local text = "Cruise Control Speed: " .. tostring( self.speed ).."km/h"
	local text_width = Render:GetTextWidth(text)

	Render:DrawText(Vector2((Render.Width - text_width)/2, 5), text, Color( 255, 255, 255 ), TextSize.Default, 1)
end

function CruiseControl:InputPoll()
	if Game:GetState() ~= GUIState.Game or not self:GetEnabled() then return end
	if not LocalPlayer:InVehicle() then return end
	local v = LocalPlayer:GetVehicle()

	if self:GetSpeed( v ) < self.speed then
		Input:SetValue( Action.Accelerate, 1.0 )
		Input:SetValue( Action.PlaneIncTrust, 1.0 )
	end

	if self:GetSpeed( v ) > self.speed then
		Input:SetValue( Action.PlaneDecTrust, 1.0 )
	end
end

function CruiseControl:ModulesLoad()
	Events:FireRegisteredEvent( "HelpAddItem",
		{
			name = "Cruise Control",
			text = 
				"Cruise Control is a script that will keep your speed " ..
				"at the number you set.\n\n" ..
				"To use it, type /c # with # being the speed you would like.\n\n" ..
				"To disable it, use /c"
		} )
end

cruisecontrol = CruiseControl()