if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "Portable Sensor"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
	
	SWEP.IconLetter = "Q"

end

SWEP.Base = "ts_base"

SWEP.HoldType = "slam"

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_slam.mdl"

SWEP.Primary.Plant          = Sound( "npc/turret_floor/click1.wav" )
SWEP.Primary.Delay			= 0.500
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false

function SWEP:ReleaseGhost()

	if IsValid( self.GhostEntity ) then

		self.GhostEntity:Remove()
		self.GhostEntity = nil
		
	end
	
end

function SWEP:MakeGhost( pos, angle )

	self.GhostEntity = ents.CreateClientProp( model )
	self.GhostEntity:SetModel( "models/weapons/w_slam.mdl" )
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn()
	
	self.GhostEntity:SetSolid( SOLID_VPHYSICS )
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true )
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.GhostEntity:SetColor( Color( 255, 255, 255, 200 ) )
	
end

function SWEP:UpdateGhost()

	if not IsValid( self.GhostEntity ) then return end
	
	local trace = util.GetPlayerTrace( self:GetOwner() )
	local tr = util.TraceLine( trace )
	
	if not tr.Hit then return end
	
	local ang = ( tr.HitNormal * -1 ):Angle() + Angle( 0, 0, math.NormalizeAngle( 90 + self:GetNWInt( "BuildAng", 0 ) ) )
	local pos = tr.HitPos + tr.HitNormal
	
	local trlength = self:GetOwner():GetPos() - tr.HitPos
	trlength = trlength:Length() 
	
	if trlength < 80 and tr.HitWorld then
	
		self.GhostEntity:SetColor( Color( 255, 255, 255, 200 ) )
		
	else
	
		self.GhostEntity:SetColor( Color( 255, 50, 50, 200 ) )
		
	end
	
	self.GhostEntity:SetPos( tr.HitPos + tr.HitNormal * 2 )
	self.GhostEntity:SetAngles( tr.HitNormal:Angle() + Angle(90,0,0) )
	
end

function SWEP:OnRemove()

	if CLIENT then
	
		self:ReleaseGhost()
	
	end

end

function SWEP:Holster()

	if CLIENT then
	
		self:ReleaseGhost()
	
	end
	
	return true

end

function SWEP:Deploy()

	if CLIENT then
	
		self:ReleaseGhost()
	
	end

	self:SendWeaponAnim( ACT_SLAM_TRIPMINE_DRAW )
	self:DrawShadow( false )
	
	return true
	
end  

function SWEP:PrimaryAttack()

	if self.NoPlace then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:PlaceMine()
	
end

function SWEP:PlaceMine()

	local trace = util.GetPlayerTrace( self:GetOwner() )
	local tr = util.TraceLine( trace )
	local length = ( self:GetOwner():GetPos() - tr.HitPos ):Length()

	if CLIENT and tr.HitWorld and length < 80 then 
	
		self:EmitSound( self.Primary.Plant )
		self:ReleaseGhost()
		self.Removing = true
	
		return 
		
	end
	
	if tr.HitWorld and length < 80 then
		
		local ent = ents.Create( "sent_tripmine" )
		ent:SetPos( tr.HitPos + tr.HitNormal * 2 )
		ent:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
		ent:SetPlayer( self:GetOwner() )
		ent:Spawn()
		
		self:EmitSound( self.Primary.Plant )
		
		self:GetOwner():StripWeapon( "weapon_ts_tripmine" )
		
	end

end

function SWEP:Think()	
	self:ConfigVarThink()
	if CLIENT then

		if not IsValid( self.GhostEntity ) and not self.Removing then
				
			self:MakeGhost( self:GetOwner():GetPos() + Vector(0,0,100), Angle(0,0,0))
				
		else
				
			self:UpdateGhost()
				
		end
	
	end

end

function SWEP:Reload()
	
end

function SWEP:OnRemove()

	if SERVER then return end
	
	self:ReleaseGhost()

end
