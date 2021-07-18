
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Beep = Sound( "weapons/bugbait/bugbait_squeeze1.wav" )
ENT.Beep2 = Sound( "weapons/bugbait/bugbait_squeeze2.wav" )
ENT.Click = Sound( "weapons/bugbait/bugbait_squeeze3.wav" )
ENT.Damaged = { Sound( "weapons/bugbait/bugbait_impact1.wav" ), Sound( "weapons/bugbait/bugbait_impact3.wav" ) }
ENT.ModelScale = 2.5
ENT.Range = GetConVar("sv_ts_stalker_mine_active_range"):GetFloat()
ENT.PingRange = GetConVar("sv_ts_stalker_mine_warn_range"):GetFloat()
ENT.MaxHealth = GetConVar("sv_ts_stalker_mine_health"):GetInt()
ENT.TimeToExplode = GetConVar("sv_ts_stalker_mine_active_time"):GetFloat()
ENT.ExplosionMagnitude = GetConVar("sv_ts_stalker_mine_exp_magnitude"):GetInt()
ENT.IgniteTime = GetConVar("sv_ts_stalker_mine_ignite_time"):GetFloat()
ENT.ExplodeTimer = nil
ENT.MalfunctionTime = 1.0
ENT.PingTimer = nil 
ENT.MaxPingDelta = 3.0
ENT.MinPingDelta = 0.1
ENT.Player = nil
ENT.ParentWeapon = nil
ENT.IsActive = false
ENT.ActivateTime = nil
ENT.HasTriggered = false

function ENT:ConfigVarThink()
	self.Range = GetConVar("sv_ts_stalker_mine_active_range"):GetFloat()
	self.PingRange = GetConVar("sv_ts_stalker_mine_warn_range"):GetFloat()
	self.MaxHealth = GetConVar("sv_ts_stalker_mine_health"):GetInt()
	self.TimeToExplode = GetConVar("sv_ts_stalker_mine_active_time"):GetFloat()
	self.ExplosionMagnitude = GetConVar("sv_ts_stalker_mine_exp_magnitude"):GetInt()
	self.IgniteTime = GetConVar("sv_ts_stalker_mine_ignite_time"):GetFloat()
end

function ENT:Initialize()

	self:SetModel( "models/weapons/w_bugbait.mdl" )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetModelScale(self.ModelScale, 0)
	
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:DrawShadow( true )

	self:SetUseType(SIMPLE_USE)
	self:SetMaxHealth(self.MaxHealth)
	
	self.ActivateTime = CurTime() + 5
	
end

function ENT:Think()

	if self.ActivateTime and self.ActivateTime < CurTime() then
		self.ActivateTime = nil
		self:StartUp()
	end

	if self.IsActive then
	
		if self.PingTimer and self.PingTimer < CurTime() then
			self.PingTimer = nil
		end
		
		local active_targets = nil
		local ping_speed = nil
		if self.BrokenTimer == nil then
			ping_speed, active_targets = self:GetLocalTargets()
			if ping_speed < self.MaxPingDelta then
				self:SendWarning(ping_speed)
			end
			if #active_targets > 0 and self.ExplodeTimer == nil then
				self.ExplodeTimer = CurTime() + self.TimeToExplode
			end
			if #active_targets == 0 and self.ExplodeTimer != nil then
				self.ExplodeTimer = nil
			end
		end
		if self.ExplodeTimer and self.ExplodeTimer < CurTime() then
			self:Explode(active_targets)
		end
	end

	if self.BrokenTimer and self.BrokenTimer < CurTime() then
		self.BrokenTimer = nil
	end

end

function ENT:GetLocalTargets()
	local active_targets = {}
	local range_sqr = self.Range * self.Range
	local ping_sqr = self.PingRange * self.PingRange
	local ping_speed = 100
	for pidx, ply in pairs(ents.GetAll()) do
		if IsValid(ply) and ply != self.Player then
			local dist_to_ent_sqr = self:GetPos():DistToSqr(ply:GetPos())
			if dist_to_ent_sqr < ping_sqr then
				ping_speed = math.min(ping_speed, (self.MaxPingDelta - self.MinPingDelta) * dist_to_ent_sqr / ping_sqr + self.MinPingDelta)
			end
			if dist_to_ent_sqr < range_sqr then
				active_targets[#active_targets + 1] = ply
			end
		end
	end
	// For testing in singleplayer ONLY
	if game.SinglePlayer() then
		for pidx, ply in pairs(ents.GetAll()) do
			if IsValid(ply) and ply.IsNPC() then
				local dist_to_ent_sqr = self:GetPos():DistToSqr(ply:GetPos())
				if dist_to_ent_sqr < ping_sqr then
					ping_speed = math.min(ping_speed, (self.MaxPingDelta - self.MinPingDelta) * dist_to_ent_sqr / ping_sqr + self.MinPingDelta)
				end
				if dist_to_ent_sqr < range_sqr then
					active_targets[#active_targets + 1] = ply
				end
			end
		end
	end

	return ping_speed, active_targets
end

function ENT:SetPlayer( ply )
	self.Player = ply
end

function ENT:SetParentWeapon(wep)
	self.ParentWeapon = wep
end

function ENT:DoUse( ply, caller )
	self:Use( ply, caller, SIMPLE_USE, 1 )
end

function ENT:SendWarning(ping_delta)
	if self.PingTimer then return end
	self:EmitSound( self.Beep2, 60 )
	self.PingTimer = CurTime() + ping_delta
end

function ENT:Use( ply, caller )

	if IsValid( self.Player ) and self.Player == ply and not self.Removed then
		self.Removed = true
		ply:Give( "weapon_ts_mine" )
		self:EmitSound( self.Click, 50, math.random( 90, 110 ) )
		self:Remove()
	end

end

function ENT:StartUp()
	if self.BrokenTimer then return end
	self:EmitSound( self.Beep, 80, 250 )
	self.IsActive = true
end

function ENT:Malfunction() 
	self.BrokenTimer = CurTime() + self.MalfunctionTime
	self:EmitSound( table.Random( self.Damaged ), 100, math.random( 90, 110 ) )
end

function ENT:OnTakeDamage(damage)
	self:Malfunction()
	if self:Health() <= 0 and not self.HasTriggered then
		local active_targets = nil
		ping_speed, active_targets = self:GetLocalTargets()
		self:Explode(active_targets)
	end
end

function ENT:Explode(active_targets)
	self.HasTriggered = true
	local explo = ents.Create("env_explosion")
	explo:SetPos(self:GetPos())
	explo:Spawn()
	explo:Fire("Explode")
	explo:SetKeyValue("IMagnitude", self.ExplosionMagnitude)
	for tidx, target in pairs(active_targets) do
		target:Ignite(self.IgniteTime)
	end
	if IsValid(self.ParentWeapon) then
		self.ParentWeapon:RemoveMine()
	end
	self:Remove()
end