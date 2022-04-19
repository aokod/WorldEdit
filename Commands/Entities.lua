-- entities.lua
-- Contains commands that do things with entities.

-- Kill nearby entities.
function HandleButcherCommand(a_Split, a_Player)
	-- /butcher [Radius]

	local Radius;
	if (a_Split[2] == nil) then -- if the player did not give a radius then the radius is the normal radius
		Radius = g_Config.Defaults.ButcherRadius
	elseif (tonumber(a_Split[2]) == nil) then -- if the player gave a string as radius then stop
		a_Player:SendMessage(cChatColor.Rose .. 'Number expected; string "' .. a_Split[2] .. '" given')
		return true
	else -- the radius is set to the given radius
		Radius = tonumber(a_Split[2])
	end

	if ((g_Config.Limits.ButcherRadius > 0) and (Radius > g_Config.Limits.ButcherRadius)) then
		a_Player:SendMessage(cChatColor.Rose .. 'Maximum butcher radius exceeded.')
		return true
	end

	-- If this is true then the mob will be destroyed regardless of how far he is from the player.
--	local ShouldRemoveAllMobs = Radius <= 0

	-- Number of mobs that were destroyed.
	local NumDestroyedMobs = 0

	-- Loop through all the entities and destroy all/nearby mobs
	a_Player:GetWorld():ForEachEntity(
		function(a_Entity)
			if (a_Entity:IsMob()) then
--				if (ShouldRemoveAllMobs) then
--					a_Entity:Destroy()
--					NumDestroyedMobs = NumDestroyedMobs + 1
--				else
					if ((a_Player:GetPosition() - a_Entity:GetPosition()):Length() <= Radius) then -- If the mob is inside the radius then destroy it.
						a_Entity:Destroy()
						NumDestroyedMobs = NumDestroyedMobs + 1
					end
--				end
			end
		end
	)

	-- Send a message to the player.
	a_Player:SendMessage(cChatColor.LightGray .. "Marked " .. NumDestroyedMobs .. " entit(ies) for removal.")
	return true
end
