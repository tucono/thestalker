if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "NV Range Scanner"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
	
	SWEP.IconLetter = "Q"

end

SWEP.Base = "ts_base"

SWEP.HoldType = "slam"

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.Primary.Deny           = Sound( "HL1/fvox/buzz.wav" )
SWEP.Primary.Sound          = Sound( "NPC_CombineGunship.PatrolPing" )
SWEP.Primary.Deploy         = Sound( "buttons/button19.wav" )
SWEP.Primary.Blip           = Sound( "buttons.snd15" )
SWEP.Primary.Holster        = Sound( "buttons/combine_button3.wav" )
SWEP.Primary.Delay			= GetConVar("sv_ts_unit8_scanner_firedelay"):GetFloat()
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.BatteryUse     = GetConVar("sv_ts_unit8_scanner_drain"):GetFloat()

function SWEP:ConfigVarThink()
self.Primary.Delay = GetConVar("sv_ts_unit8_scanner_firedelay"):GetFloat()
	self.Primary.BatteryUse = GetConVar("sv_ts_unit8_scanner_drain"):GetFloat()
end

function SWEP:Deploy()

	if SERVER then
	
		self:GetOwner():AddInt( "Battery", -5 )
	
	end

	self:EmitSound( self.Primary.Deploy, 100, math.random( 90, 110 ) )
	self:SendWeaponAnim( ACT_SLAM_DETONATOR_DRAW )
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:DrawShadow( false )
	
	return true
	
end  

function SWEP:Holster()

	if CLIENT then

		self:GetOwner():EmitSound( self.Primary.Holster, 50, math.random( 100, 120 ) )
		
	end

	return true

end

function SWEP:PrimaryAttack()
	
	if ( SERVER and self:GetOwner():GetInt( "Battery" ) < self.Primary.BatteryUse ) or ( CLIENT and GAMEMODE:GetInt( "Battery" ) < self.Primary.BatteryUse ) then 
	
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		
		if SERVER then
		
			self:GetOwner():EmitSound( self.Primary.Deny, 40 )
			
		end
	
		return 
		
	end
	
	self:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if SERVER then
	
		self:GetOwner():EmitSound( self.Primary.Blip, 100, math.random( 90, 110 ) )
		self:GetOwner():EmitSound( self.Primary.Sound, 100, math.random( 90, 110 ) )
		self:GetOwner():AddInt( "Battery", -1 * self.Primary.BatteryUse )
		
		net.Start( "Scanner" )
		net.Send( self:GetOwner() )
	
	end
	
end

//function SWEP:Think()	
//
//end

function SWEP:Reload()
	
end

function SWEP:OnRemove()

end
