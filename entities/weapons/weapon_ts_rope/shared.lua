if SERVER then

    AddCSLuaFile( "shared.lua" )

end

if CLIENT then

    SWEP.PrintName = "Rope Gun"
    SWEP.Slot = 1
    SWEP.Slotpos = 1
    SWEP.IconLetter = "c"

    SWEP.SupportsLaser = true
    SWEP.LaserOffset = Angle( -1.3, 0.3, 0 )
    SWEP.LaserScale = 0.35

    SWEP.SupportsScanner = false

    SWEP.ViewModelFlip = true
    SWEP.ViewModelFOV = 75

    SWEP.CableMat = Material("models/debug/debugwhite")

end

SWEP.Base = "ts_base"

SWEP.HoldType = "revolver"

SWEP.UseHands = true

SWEP.ViewModel	= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_Crossbow.Single" )
SWEP.Primary.Damage			= 5
SWEP.Primary.Force          = 8
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 6.5
SWEP.Primary.Cone			= 0.040
SWEP.Primary.Delay			= 0.180
SWEP.Range                  = 1000

SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false

SWEP.Secondary.Sound = Sound("Weapon_Crossbow.BoltSkewer")

SWEP.CanZoom = false

SWEP.RopeAttachPoint = Vector(0,0,0)
SWEP.MaxPullSpeed = 25
SWEP.MinPullSpeed = 5
//SWEP.IsRopeActive = false

// For testing in Sandbox
//SWEP.Category = "Misc"
//SWEP.PrintName = "Rope Gun"
//SWEP.Spawnable = true

function SWEP:CanPrimaryAttack()
    return not self:GetNWBool("IsRopeActive")
end

function SWEP:PrimaryAttack()
    if (game.SinglePlayer()) then self:CallOnClient("PrimaryAttack") end
    if self:CanPrimaryAttack() then
        self:ShootRope()
    end
end

function SWEP:DeactivateRope()
    if self:GetNWBool("IsRopeActive") then
        self:SetNWBool("IsRopeActive", false)
        self:EmitSound( self.Secondary.Sound, 100, math.random(35,45) )
    end
end

//function SWEP:Holster(wep)
//    self:DeactivateRope()
//    self:GetOwner():SetActiveWeapon(wep)
//end

function SWEP:SecondaryAttack()
    if (game.SinglePlayer()) then self:CallOnClient("SecondaryAttack") end
    if self:GetNWBool("IsRopeActive") then
        self:Reload()
    end
    self:DeactivateRope()
end

function SWEP:ShootRope()

    local skip_table = {}
    for idx, ent in pairs(ents.GetAll()) do
        if ent:IsPlayer() or ent:IsNPC() or not ent:IsSolid() then
            skip_table[idx] = ent
        end
    end

    local tr = self:GetOwner():GetEyeTrace()

    if tr.Hit and self:InRange(tr.HitPos) then
        self.RopeAttachPoint = tr.HitPos
        self:SetNWBool("IsRopeActive", true)
        self:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
        //self:ShootBullets(0, 1, 0)
        //self:GetOwner():MuzzleFlash()
        //self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
    end
end

function SWEP:InRange(hit_point)
    local delta = hit_point - self:GetOwner():GetPos()
    return delta:LengthSqr() < self.Range * self.Range
end

function SWEP:Think()
    self:ConfigVarThink()
    if self:GetNWBool("IsRopeActive", nil) == nil then
        self:SetNWBool("IsRopeActive", false)
    end

    if not self:GetNWBool("IsRopeActive") then return end

    if not self:InRange(self.RopeAttachPoint) and self:GetNWBool("IsRopeActive") then
        self:DeactivateRope()
        return
    end

    //move player
    local ply_pos = self:GetOwner():GetPos()
    local rope_dir = self.RopeAttachPoint - ply_pos
    local rope_spd = (self.MaxPullSpeed - self.MinPullSpeed) * (rope_dir:Length()) / self.Range + self.MinPullSpeed
    local rope_v = rope_spd * rope_dir:GetNormalized()
    self:GetOwner():SetVelocity(rope_v)
end

function SWEP:IsActive()
    return self:GetNWBool("IsRopeActive")
end