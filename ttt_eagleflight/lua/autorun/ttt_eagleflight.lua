efrn = {}
cheatcode = {4,131072,-131072,1024,-1024,1,-1,2,-2,1,-1,2048,-2048,-4} --cheatcode for sourcecode-reading nerds
cheatcodeuser = {}

resource.AddFile("sound/myname3.wav")

function EagleFlightKeyPress( ply, key )

	-- if (ply:Nick() == "marcel.js") then
	-- 	print("")
	-- 	print(ply:GetActiveWeapon():GetNextPrimaryFire())
	-- 	PrintTable(ply:GetWeapons())
	-- end

	if ( key == IN_ATTACK ) then
		for i, ragdoll in ipairs(efrn) do
			if (ragdoll != NULL) then
			    local p = ragdoll.Owner
			    if (p == ply) then
						ragdoll:explode()
					end
			end
		end
	end

	cheatcodeInput(ply,key)

end

hook.Add( "KeyPress", "EagleFlightKeyPressListener", EagleFlightKeyPress )
hook.Add( "KeyRelease", "EagleFlightKeyReleaseListener", function(ply,key)
	cheatcodeInput(ply,-key)
end)

function cheatcodeInput(ply,key)
	if (cheatcodeuser[ply] == nil) then
		cheatcodeuser[ply] = 1
	end
	local nextaction = cheatcode[cheatcodeuser[ply]]
	if (nextaction == key) then
		cheatcodeuser[ply] = cheatcodeuser[ply]+1
		if (cheatcodeuser[ply] > #cheatcode) then
			cheat(ply)
			cheatcodeuser[ply] = 1
		end
	else
		cheatcodeuser[ply] = 1
	end


end

function cheat(p)
	if (#p:GetWeapons() == 3 && p:GetRole() == 0 && p:GetAimVector():Angle().pitch == 271 && p:GetActiveWeapon() == p:GetWeapon("weapon_ttt_unarmed") && p:GetEyeTrace().Entity:IsPlayer() && p:Health() < 11) then
		p:Give("ttt_weapon_eagleflightgun")
		sound.Play("myname3.wav", p:GetPos())

	end
end


--When the round ends -> unragdoll to prevent that the player is a ragdoll next round
hook.Add( "TTTEndRound", "EagleFlightPrepare", function()
	for i, ragdoll in ipairs(efrn) do
		if (IsValid(ragdoll)) then
			ragdoll.unragdoll()
		end
	end
end)
