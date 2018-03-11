if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/icon_eagleflightgun.png")
end

if CLIENT then
	SWEP.Icon = "VGUI/ttt/icon_eagleflightgun.png"
	SWEP.PrintName = "Eagleflight Gun"
	SWEP.Slot = 6
	SWEP.EquipMenuData = {
	type = "Weapon",
	desc = "Shoot to fling yourself.\nIf you fall on a player, he will die!\nIf not, press left mousebutton again to explode."
	}
end

SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "pistol"

SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.DefaultClip = 1

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = Model( "models/weapons/cstrike/c_pist_deagle.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_pist_deagle.mdl" )
SWEP.UseHands = true

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = false


function SWEP:PrimaryAttack()

	if (GetRoundState() != 3) then return end

	if ( !self:CanPrimaryAttack() ) then return end
	sound.Play( "ambient/creatures/town_child_scream1.wav", self.Owner:GetPos())

	if ( CLIENT ) then return end


	self:TakePrimaryAmmo(1)

	local p = self.Owner

	p:SelectWeapon( "weapon_ttt_unarmed" )
	p:StripWeapon( "ttt_weapon_eagleflightgun" )

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll:SetSolid(SOLID_VPHYSICS)
	ragdoll:PhysicsInit( SOLID_VPHYSICS )

	ragdoll:SetPos( p:GetPos() )
	local velocity = p:GetAimVector() * 100000000
	ragdoll:SetAngles( p:GetAngles() )
	ragdoll:SetModel( p:GetModel() )
	ragdoll:Spawn()
	ragdoll:Activate()
	p:SetParent( ragdoll )
	local j = 1
	while true do
		local phys_obj = ragdoll:GetPhysicsObjectNum( j )
		if phys_obj then
			phys_obj:SetVelocity( velocity )
			--phys_obj:EnableGravity(false)
			phys_obj:SetMass(10)
			j = j + 1
		else
			break
		end
	end
	p:Spectate( OBS_MODE_CHASE )
	p:SpectateEntity( ragdoll )
	p.ragdoll = ragdoll
	ragdoll:DisallowDeleting( true, function( old, new )
		if p:IsValid() then p.ragdoll = new end
	end )

	ragdoll.hp = p:Health()
	ragdoll.c = p:GetCredits()
	ragdoll.Owner = p

	ragdoll.explode = function()

		local p = ragdoll.Owner
		local pos = ragdoll:GetPos()
		local ent = ents.Create( "env_explosion" )
		ent:SetPos( ragdoll:GetPos() )
		ent:SetOwner( p )
		ent:SetPhysicsAttacker( ragdoll )
		ent:Spawn()
		ent:SetKeyValue( "iMagnitude", "0" )
		ent:Fire( "Explode", 0, 0 )

		util.BlastDamage( ragdoll, p, ragdoll:GetPos(), 200,200 )


		p:SetPos(pos)
		ragdoll:unragdoll()
		ragdoll:Remove()
		p:SetHealth(ragdoll.hp)
		p:SetCredits(ragdoll.c)
	end


	ragdoll.unragdoll = function()
		local p = ragdoll.Owner
		p:SetParent()
		p.ragdoll = nil
		local pos = ragdoll:GetPos()
		p:Spawn()
		p:SetPos( pos )
		local yaw = ragdoll:GetAngles().yaw
		p:SetAngles( Angle( 0, yaw, 0 ) )
		ragdoll:DisallowDeleting( false )
		ragdoll:Remove()
	end



	table.insert(efrn,ragdoll)

	timer.Simple( 15, function()
		if (IsValid(ragdoll)) then
			ragdoll.explode(ragdoll)
		end
	end )

end
