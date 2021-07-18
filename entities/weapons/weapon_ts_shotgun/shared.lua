if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "SPAS 12"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.IconLetter = "k"
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
	
	SWEP.SupportsLaser = true
	SWEP.LaserScale = 0.85

	SWEP.SupportsScanner = true
	
	killicon.AddFont( "weapon_ts_shotgun", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType = "shotgun"

SWEP.Base = "ts_base"

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_Shotgun.Double" )
SWEP.Primary.Pump           = Sound( "Weapon_Shotgun.Special1" )
SWEP.Primary.ReloadSound    = Sound( "Weapon_Shotgun.Reload" )
SWEP.Primary.Damage			= 13
SWEP.Primary.Force          = 2
SWEP.Primary.NumShots		= 10
SWEP.Primary.Recoil			= 9.5
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay			= 0.550

SWEP.Primary.ClipSize		= 6
SWEP.Primary.Automatic		= false

SWEP.ShellType = 4

function SWEP:Deploy()

	if CLIENT then
	
		self.LaserTime = CurTime() + 0.5
	
	end

	self:SetNWBool( "Reloading", false )
	self:SetVar( "PumpTime", 0 )
	self:SetNextPrimaryFire( CurTime() + 0.3 )

	self:SendWeaponAnim( ACT_VM_DRAW )
	self:DrawShadow( false )
	
	return true
	
end 

function SWEP:CanPrimaryAttack()
	
	if ( SERVER and self:GetOwner():GetAmmo() < 1 ) or ( CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 ) then
		
		self:EmitSound( self.Primary.Empty, 50, 120 )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		
		return false
		
	end
	
	if self:GetNWBool( "Reloading", false ) then
	
		self:SetNWBool( "Reloading", false )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		
		self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
		
		return false
	
	end

	if self:Clip1() <= 0 and not self:GetNWBool( "Reloading", false ) then
		
		self:SetNWBool( "Reloading", true )
		self:SetVar( "ReloadTimer", CurTime() + 0.5 )
		self:SendWeaponAnim( ACT_VM_RELOAD )
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self:SetClip1( self:Clip1() + 1 )
		
		return false
		
	end
	
	return true
	
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootBullets( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )
	self:TakePrimaryAmmo( 1 )
	self:SetVar( "PumpTime", CurTime() + 0.5 )
	
	self:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
	
	if SERVER then

		self:GetOwner():AddAmmo( -1 )
		
	end
	
	local scale = 0.50

	if self:GetOwner():KeyDown( IN_DUCK ) then

		scale = 0.40
		
	elseif self:GetOwner():KeyDown( IN_FORWARD ) or self:GetOwner():KeyDown( IN_BACK ) or self:GetOwner():KeyDown( IN_MOVELEFT ) or self:GetOwner():KeyDown( IN_MOVERIGHT ) then

		scale = 0.75
		
	end

	local pang, yang = math.Rand( -1 * scale, -0.2 ) * self.Primary.Recoil, math.Rand( -1 * ( scale * 0.2 ), ( scale * 0.2 ) ) * self.Primary.Recoil

	self:GetOwner():ViewPunch( Angle( pang, yang, 0 ) )
	
end

function SWEP:Reload()

	if self:GetVar( "PumpTime", 0 ) != 0 and self:GetVar( "PumpTime", 0 ) >= CurTime() then return end

	if SERVER and self:GetOwner():GetAmmo() < 1 then return end
	
	if CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 then return end

	if self:Clip1() == self.Primary.ClipSize or self:GetNWBool( "Reloading", false ) then return end
	
	self:SetNWBool( "Reloading", true )
	self:SetVar( "ReloadTimer", CurTime() + 0.5 )
	self:SendWeaponAnim( ACT_VM_RELOAD )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
end

function SWEP:PumpIt()

	self:SetNWBool( "Reloading", false )
	self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
	self:EmitSound( self.Primary.Pump )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	//if CLIENT then return end
	
	//timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self:GetOwner():GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ) ) end end )
	
end

function SWEP:Think()

	self:ConfigVarThink()

	if self:GetVar( "PumpTime", 0 ) != 0 and self:GetVar( "PumpTime", 0 ) < CurTime() then
	
		self:SetVar( "PumpTime", 0 )
		self:PumpIt()
		
	end

	if self:GetNWBool( "Reloading", false )  and self:GetVar( "ReloadTimer", 0 ) < CurTime() then
	
		if self:Clip1() >= self.Primary.ClipSize then
		
			self:SetNWBool( "Reloading", false )
			self:SetNextPrimaryFire( CurTime() + 0.5 )
			self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
			
			return
			
		end
		
		// Next cycle
		self:SetVar( "ReloadTimer", CurTime() + 0.75 )
		self:SendWeaponAnim( ACT_VM_RELOAD )
		self:SetClip1( self:Clip1() + 1 )
		self:EmitSound( self.Primary.ReloadSound, 100, math.random(90,110) )
		
	end
	
end

function SWEP:ShootBullets( damage, numbullets, aimcone )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		
	self:GetOwner():MuzzleFlash()								
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	local scale = aimcone
	
	if self:GetOwner():KeyDown( IN_FORWARD ) or self:GetOwner():KeyDown( IN_BACK ) or self:GetOwner():KeyDown( IN_MOVELEFT ) or self:GetOwner():KeyDown( IN_MOVERIGHT ) then
	
		scale = aimcone * 1.10
		
	elseif self:GetOwner():KeyDown( IN_DUCK ) then
	
		scale = aimcone * 0.90
		
	end
	
	self:CreateBullets( scale, damage, numbullets )
	
end

