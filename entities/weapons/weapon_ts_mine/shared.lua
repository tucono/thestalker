if SERVER then

    AddCSLuaFile( "shared.lua" )

    SWEP.Weight = 1
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false

end

if CLIENT then

    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false

    SWEP.PrintName = "Stalker Bugmine"
    SWEP.Slot = 1
    SWEP.Slotpos = 0

    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.IconLetter = "Q"

end

SWEP.Base = "ts_base"

SWEP.HoldType = "slam"

SWEP.UseHands = true

SWEP.ViewModel			= "models/zed/weapons/v_banshee.mdl"
SWEP.WorldModel			= "models/weapons/w_bugbait.mdl"
SWEP.ModelScale         = 2.5

SWEP.Primary.Plant          = Sound( "nuke/gore/blood03.wav" )
SWEP.Secondary.Miss         = Sound( "ambient/atmosphere/cave_hit2.wav" )
SWEP.Primary.Delay			= 0.500
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false
SWEP.Mana                   = GetConVar("sv_ts_stalker_mine_drain"):GetInt()
SWEP.MaxMines               = GetConVar("sv_ts_stalker_mine_max"):GetInt()

// For testing in Sandbox
// SWEP.Category = "Misc"
// SWEP.PrintName = "ts_bugmine"
// SWEP.Spawnable = true

function SWEP:ReleaseGhost()
    if IsValid( self.GhostEntity ) then

        self.GhostEntity:Remove()
        self.GhostEntity = nil

    end

end

function SWEP:MakeGhost( pos, angle )

    self.GhostEntity = ents.CreateClientProp( model )
    self.GhostEntity:SetModel( "models/weapons/w_bugbait.mdl" )
    self.GhostEntity:SetPos( pos )
    self.GhostEntity:SetAngles( angle )
    self.GhostEntity:SetModelScale(self.ModelScale)
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

    //local ang = ( tr.HitNormal * -1 ):Angle() + Angle( 0, 0, math.NormalizeAngle( 90 + self:GetNWInt( "BuildAng", 0 ) ) )
    //local pos = tr.HitPos + tr.HitNormal

    local trlength = self:GetOwner():GetPos() - tr.HitPos
    trlength = trlength:Length()

    if trlength < 80 and tr.HitWorld then

        self.GhostEntity:SetColor( Color( 255, 255, 255, 200 ) )

    else

        self.GhostEntity:SetColor( Color( 255, 50, 50, 200 ) )

    end

    self:SetCreatedEntityPos(self.GhostEntity, tr)

end

function SWEP:SetCreatedEntityPos(entity, tr)
    entity:SetPos(tr.HitPos + tr.HitNormal * 2)
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
    if self:GetNWInt("MineCount") >= self.MaxMines then return end
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    if CLIENT then return end

    if self:GetOwner():GetInt("Mana") < self.Mana then
        self:GetOwner():EmitSound(self.Secondary.Miss, 40, 250)
        return
    end

    self:GetOwner():AddInt("Mana", -self.Mana)
    self:PlaceMine()

end



function SWEP:PlaceMine()
    local trace = util.GetPlayerTrace( self:GetOwner() )
    local tr = util.TraceLine( trace )
    local length = ( self:GetOwner():GetPos() - tr.HitPos ):Length()
    if SERVER and tr.HitWorld and length < 80 then
        self:EmitSound( self.Primary.Plant )
        local ent = ents.Create( "sent_bugmine" )
        if not IsValid(ent) then return end
        self:SetCreatedEntityPos(ent, tr)
        ent:SetPlayer( self:GetOwner() )
        ent:SetParentWeapon(self)
        ent:Spawn()
    end

    if tr.HitWorld and length < 80 then
        self:EmitSound( self.Primary.Plant )
        self:SetNWInt("MineCount", self:GetNWInt("MineCount") + 1)
    end
end

function SWEP:ConfigVarThink()
    self.Mana = GetConVar("sv_ts_stalker_mine_drain"):GetInt()
    self:SetNWInt("Mana_Mine", self.Mana)
    self.MaxMines = GetConVar("sv_ts_stalker_mine_max"):GetInt()
end

function SWEP:Think()
    self:ConfigVarThink()

    if self:GetNWInt("MineCount", -1) < 0 then
        self:SetNWInt("MineCount", 0)
    end

    if CLIENT then
        if not IsValid( self.GhostEntity ) and not self.Removing and self:GetNWInt("MineCount") < self.MaxMines then
            self:MakeGhost( self:GetOwner():GetPos() + Vector(0,0,100), Angle(0,0,0))
        elseif IsValid(self.GhostEntity) and self:GetNWInt("MineCount") >= self.MaxMines then
            self:ReleaseGhost()
        else
            self:UpdateGhost()
        end
    end

end

function SWEP:RemoveMine()
    self:SetNWInt("MineCount", self:GetNWInt("MineCount") - 1)
end

function SWEP:Reload()
end

function SWEP:OnRemove()
    if SERVER then return end
    self:ReleaseGhost()
end
