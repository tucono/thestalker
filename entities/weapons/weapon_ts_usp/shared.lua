if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "USP Compact"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	SWEP.IconLetter = "c"
	
	SWEP.SupportsLaser = true
	SWEP.LaserOffset = Angle( -1.3, 0.3, 0 )
	SWEP.LaserScale = 0.35
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	
	killicon.AddFont( "weapon_ts_usp", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.Base = "ts_base"

SWEP.HoldType = "revolver"

SWEP.UseHands = true

SWEP.ViewModel	= "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_Pistol.NPC_Single" )
SWEP.Primary.Clipout        = Sound( "Weapon_deagle.clipout" )
SWEP.Primary.Clipin         = Sound( "Weapon_usp.clipin" )
SWEP.Primary.Slide          = Sound( "Weapon_usp.sliderelease" )
SWEP.Primary.Damage			= 30
SWEP.Primary.Force          = 8
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 6.5
SWEP.Primary.Cone			= 0.040
SWEP.Primary.Delay			= 0.180

SWEP.Primary.ClipSize		= 12
SWEP.Primary.Automatic		= false

function SWEP:Reload()
	
	if self:Clip1() == self.Primary.ClipSize then return end

	self:DoReload()
	
	if SERVER or self.SlideSound then return end
	
	self:GetOwner():EmitSound( self.Primary.Clipout, 100, math.random( 95, 105 ) )
	
	self.ClipSound = CurTime() + 0.6
	self.SlideSound = CurTime() + 1.1
	
end

function SWEP:CanPrimaryAttack()

	if self:Clip1() <= 0 then
	
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:Reload()
		
		return false
		
	end
	
	return true
	
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootBullets( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )
	self:TakePrimaryAmmo( 1 )
	
	if IsFirstTimePredicted() then
	
		self:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
		
		local scale = 0.50
			
		if self:GetOwner():KeyDown( IN_DUCK ) then
			
			scale = 0.25
				
		elseif self:GetOwner():KeyDown( IN_FORWARD ) or self:GetOwner():KeyDown( IN_BACK ) or self:GetOwner():KeyDown( IN_MOVELEFT ) or self:GetOwner():KeyDown( IN_MOVERIGHT ) then
			
			scale = 0.60
				
		end
			
		local pang, yang = math.Rand( -1 * scale, -0.1 ) * self.Primary.Recoil, math.Rand( -1 * ( scale * 0.2 ), ( scale * 0.2 ) ) * self.Primary.Recoil
			
		self:GetOwner():ViewPunch( Angle( pang, yang, 0 ) )
			
		timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self:GetOwner():GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ), 0.1 ) end end )
		
	end
	
end

function SWEP:Think()	

	self:ReloadThink()
	
	if SERVER then return end
	
	if self.ClipSound and self.ClipSound < CurTime() then
	
		self.ClipSound = nil
		
		self:GetOwner():EmitSound( self.Primary.Clipin, 100, math.random( 95, 105 ) )
	
	end
	
	if self.SlideSound and self.SlideSound < CurTime() then
	
		self.SlideSound = nil
		
		self:GetOwner():EmitSound( self.Primary.Slide, 100, math.random( 95, 105 ) )
	
	end

end
