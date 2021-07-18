if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then

	SWEP.ViewModelFOV = 70
	
	SWEP.PrintName = "SG 552"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.IconLetter = "A"
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	
	SWEP.SupportsLaser = true
	SWEP.LaserOffset = Angle( 90, 0.1, 0 )
	SWEP.LaserScale = 0.35

	SWEP.SupportsScanner = true
	
	killicon.AddFont( "weapon_ts_sg552", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.Base = "ts_base"

SWEP.HoldType = "ar2"

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/cstrike/c_rif_sg552.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_sg552.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_SG552.Single" )
SWEP.Primary.Zoom           = Sound( "weapons/sniper/sniper_zoomout.wav" )
SWEP.Primary.Damage			= 57
SWEP.Primary.Force          = 8
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 5.5
SWEP.Primary.Cone			= 0.005
SWEP.Primary.Delay			= 0.200

SWEP.Primary.ClipSize		= 20
SWEP.Primary.Automatic		= true

SWEP.ShellType = 3

SWEP.ZoomFOV = 55
SWEP.Zoom = false

function SWEP:Reload()
	
	if SERVER and self:GetOwner():GetAmmo() < 1 then return end
	
	if CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 then return end
	
	if self:Clip1() == self.Primary.ClipSize then return end

	self:DoReload()
	
	if SERVER and self.Zoom then
	
			self:GetOwner():SetFOV( 0, 0.3 )
			self.Zoom = false
				
	end
	
end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire( CurTime() + 0.5 )
	
	if SERVER then
	
		self.Zoom = !self.Zoom
		
		if not self.Zoom then
		
			self:GetOwner():SetFOV( 0, 0.3 )
			self:GetOwner():EmitSound( self.Primary.Zoom, 100, 150 )
			
		else
		
			self:GetOwner():SetFOV( self.ZoomFOV, 0.3 )
			self:GetOwner():EmitSound( self.Primary.Zoom )
			
		end
		
	end

end