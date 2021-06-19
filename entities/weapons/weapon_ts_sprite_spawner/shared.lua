if SERVER then
    AddCSLuaFile( "shared.lua" )
    SWEP.Weight = 1
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
end

if CLIENT then
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false

    SWEP.PrintName = "Stalker Sprite Spawner"
    SWEP.Slot = 2
    SWEP.Slotpos = 0

    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.IconLetter = "Q"
end

SWEP.Base = "ts_base"
SWEP.HoldType = "knife"
SWEP.UseHands = true

SWEP.ViewModel			= "models/zed/weapons/v_banshee.mdl"
SWEP.WorldModel			= "models/weapons/w_bugbait.mdl"

SWEP.Primary.Plant          = Sound( "npc/fast_zombie/claw_strike3.wav" )
SWEP.Secondary.Miss         = Sound( "ambient/atmosphere/cave_hit2.wav" )
SWEP.Primary.Delay			= 0.500
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false
SWEP.Mana                   = GetConVar("sv_ts_stalker_sprite_drain"):GetInt()
SWEP.MaxSpawnDist           = 800

SWEP.BaseColor = Color(0,0,0,100)

function SWEP:ReleaseGhost()
    if IsValid( self.GhostEntity ) then
        self.GhostEntity:Remove()
        self.GhostEntity = nil
    end
end

function SWEP:MakeGhost( pos, angle )

    self.GhostEntity = ents.CreateClientProp( "models/manhack.mdl" )
    self.GhostEntity:SetPos( pos )
    self.GhostEntity:SetAngles( angle )
    //self.GhostEntity:SetModelScale(self.ModelScale)
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

    local trlength = self:GetOwner():GetPos() - tr.HitPos
    trlength = trlength:Length()
    if trlength < self.MaxSpawnDist and tr.HitWorld then
        self.GhostEntity:SetColor( Color( 255, 255, 255, 200 ) )
    else
        self.GhostEntity:SetColor( Color( 255, 50, 50, 200 ) )
    end
    self:SetCreatedEntityPos(self.GhostEntity, tr)
end

function SWEP:SetCreatedEntityPos(entity, tr)
    entity:SetPos(tr.HitPos + tr.HitNormal * 20)
    entity:SetAngles(tr.HitNormal:Angle() + Angle(90, 0, 0))
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
    if (game.SinglePlayer()) then self:CallOnClient("PrimaryAttack") end

    //if self.NoPlace then return end
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    if CLIENT then return end

    if self:GetOwner():GetInt("Mana") < self.Mana then
        self:GetOwner():EmitSound(self.Secondary.Miss, 40, 250)
        return
    end

    self:GetOwner():AddInt("Mana", -self.Mana)
    self:SpawnSprite()

end

function SWEP:SpawnSprite()
    local trace = util.GetPlayerTrace( self:GetOwner() )
    local tr = util.TraceLine( trace )
    local length = ( self:GetOwner():GetPos() - tr.HitPos ):Length()
    if SERVER and tr.HitWorld and length < self.MaxSpawnDist then
        self:EmitSound( self.Primary.Plant )
        local ent = ents.Create( "npc_manhack" )
        if not IsValid(ent) then return end

        self:SetCreatedEntityPos(ent, tr)
        // make sprite like stalker and hate players
        ent:SetColor(self.BaseColor)
        ent:SetRenderFX(kRenderFxPulseSlowWide)
        ent:Spawn()
        ent:AddEntityRelationship(self:GetOwner(), D_LI, 99)
    end

    if tr.HitWorld and length < self.MaxSpawnDist then
        self:EmitSound( self.Primary.Plant )
    end
end

function SWEP:ConfigVarThink()
    self.Mana = GetConVar("sv_ts_stalker_sprite_drain"):GetInt()
    self:SetNWInt("Mana_Sprite", self.Mana)
end

function SWEP:Think()
    self:ConfigVarThink()

    if CLIENT then
        if not IsValid( self.GhostEntity ) then
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
