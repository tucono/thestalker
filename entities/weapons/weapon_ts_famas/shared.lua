if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.ViewModelFlip = false
	SWEP.PrintName = "FAMAS G2"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.IconLetter = "t"
	
	SWEP.ViewModelFOV = 55
	
	SWEP.SupportsLaser = true
	SWEP.LaserOffset = Angle( -90, -0.9, 0 )
	SWEP.LaserScale = 0.25

	SWEP.SupportsScanner = true
	SWEP.RenderScanner = false
	
	killicon.AddFont( "weapon_ts_famas", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.Base = "ts_base"

SWEP.HoldType = "ar2"

SWEP.UseHands = true

SWEP.ViewModel		= "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel		= "models/weapons/w_rif_famas.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_m4a1.Single" )
SWEP.Primary.Sound2			= Sound( "Weapon_galil.Single" )
SWEP.Primary.Damage			= 25
SWEP.Primary.Force          = 6
SWEP.Primary.NumShots		= 3
SWEP.Primary.Recoil			= 6.5
SWEP.Primary.Cone			= 0.045
SWEP.Primary.Delay			= 0.500
SWEP.Primary.SndDelay       = 0.030

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Automatic		= false

SWEP.ShellType = 3

SWEP.Shots = 0
SWEP.ResetNext = false

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end
	
	self.SoundTime = CurTime() + self.Primary.SndDelay
	self.SoundTime2 = CurTime() + self.Primary.SndDelay * 2
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:ShootBullets( self.Primary.Damage, self.Primary.Cone )
	self:TakePrimaryAmmo( 3 )
	
	self:EmitSound( self.Primary.Sound2, 100, math.random(95,105) )
	
	if SERVER then
		
		self:GetOwner():AddAmmo( -3 )
		timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self:GetOwner():GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ), 0.1 ) end end )
		
	end
	
	local scale = 0.50
	
	if self:GetOwner():KeyDown( IN_DUCK ) then
	
		scale = 0.25
		
	elseif self:GetOwner():KeyDown( IN_FORWARD ) or self:GetOwner():KeyDown( IN_BACK ) or self:GetOwner():KeyDown( IN_MOVELEFT ) or self:GetOwner():KeyDown( IN_MOVERIGHT ) then
	
		scale = 0.75
		
	end

	local pang, yang = math.Rand( -1 * scale, -0.1 ) * self.Primary.Recoil, math.Rand( -1 * ( scale * 0.2 ), ( scale * 0.2 ) ) * self.Primary.Recoil
	
	self:GetOwner():ViewPunch( Angle( pang, yang, 0 ) )
	
end

function SWEP:ShootBullets( damage, aimcone )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		
	self:GetOwner():MuzzleFlash()								
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	local scale = aimcone
	
	if self:GetOwner():KeyDown( IN_FORWARD ) or self:GetOwner():KeyDown( IN_BACK ) or self:GetOwner():KeyDown( IN_MOVELEFT ) or self:GetOwner():KeyDown( IN_MOVERIGHT ) then
	
		scale = aimcone * 1.25
		
	elseif self:GetOwner():KeyDown( IN_DUCK ) then
	
		scale = aimcone * 0.5
		
	end
	
	self:GetOwner():LagCompensation( true )
	
	self:CreateBullets( scale * 0.1, damage, 1 )
	self:CreateBullets( scale * 1.1, damage, 2 )
	
	self:GetOwner():LagCompensation( false )
	
end

function SWEP:Think()

	self:ReloadThink()
	self:ConfigVarThink()

	if not IsFirstTimePredicted() then return end

	if self.SoundTime and self.SoundTime < CurTime() then
	
		self.SoundTime = nil
		
		self:EmitSound( self.Primary.Sound2, 100, math.random(95,105) )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 	
		
		self:GetOwner():MuzzleFlash()
		
		if SERVER then 
		
			timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self:GetOwner():GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ), 0.5 ) end end )
			
		end
	
	end
	
	if self.SoundTime2 and self.SoundTime2 < CurTime() then
	
		self.SoundTime2 = nil
		
		self:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 	
		
		self:GetOwner():MuzzleFlash()
		
		if SERVER then
		
			timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self:GetOwner():GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ), 0.5 ) end end )
			
		end
	
	end

end

function SWEP:CanDrawScanner()
	return self.SupportsScanner and self.RenderScanner
end