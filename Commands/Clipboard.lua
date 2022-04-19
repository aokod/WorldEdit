-- clipboard.lua
-- Implements handlers for clipboard-related commands.

function HandleCopyCommand(a_Split, a_Player)
	-- Get the player state...
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find any region to copy.")
		return true
	end

	-- Check with other plugins if the operation is okay...
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if (CallHook("OnAreaCopying", a_Player, World, SrcCuboid)) then
		return
	end

	-- Cut into the clipboard...
	local NumBlocks = State.Clipboard:Copy(World, SrcCuboid, SrcCuboid.p1 - Vector3i(a_Player:GetPosition()))

	-- Call other plugins to notify that the player has copied the region.
	CallHook("OnAreaCopied", a_Player, World, SrcCuboid)

	a_Player:SendMessage(cChatColor.LightGray .. "Copied " .. NumBlocks .. " block(s) to your clipboard.")
	-- Get a size description of the clipboard.
	a_Player:SendMessage(cChatColor.LightGray .. "Size: " .. State.Clipboard:GetSizeDesc() .. ".")
	return true
end

function HandleCutCommand(a_Split, a_Player)
	-- Get the player state...
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find any region to copy.")
		return true
	end

	-- Check with other plugins if the operation is okay...
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "cut")) then
		return
	end

	-- Push an undo snapshot...
	State.UndoStack:PushUndoFromCuboid(World, SrcCuboid, "cut")

	-- Cut into the clipboard...
	local NumBlocks = State.Clipboard:Cut(World, SrcCuboid, SrcCuboid.p1 - Vector3i(a_Player:GetPosition()))

	-- Notify the plugins that the cut was successful.
	CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "cut")

	a_Player:SendMessage(cChatColor.LightGray .. "Cut and copied " .. NumBlocks .. " block(s) to your clipboard.")
	-- Get a size description of the clipboard.
	a_Player:SendMessage(cChatColor.LightGray .. "Size: " .. State.Clipboard:GetSizeDesc() .. ".")
	return true
end

function HandlePasteCommand(a_Split, a_Player)
	-- Check if there's anything in the clipboard...
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find anything on your clipboard to paste.")
		return true
	end

	-- Check for parameters.
	local UseOffset = true

	for Idx, Parameter in ipairs(a_Split) do
		if (Parameter == "-no") then -- No offset
			UseOffset = false
		end
	end

	-- Check with other plugins if the operation is okay...
	local DstCuboid = State.Clipboard:GetPasteDestCuboid(a_Player, UseOffset)
	if (CallHook("OnAreaChanging", DstCuboid, a_Player, a_Player:GetWorld(), "paste")) then
		return
	end

	State.UndoStack:PushUndoFromCuboid(a_Player:GetWorld(), DstCuboid, "paste")
	local NumBlocks = State.Clipboard:Paste(a_Player, DstCuboid.p1)

	-- Notify other plugins that the clipboard is pasted in the world.
	CallHook("OnAreaChanged", DstCuboid, a_Player, a_Player:GetWorld(), "paste")

	if (UseOffset) then
		a_Player:SendMessage(cChatColor.LightGray .. "Pasted " .. NumBlocks .. " block(s) relative to you.")
	else
		a_Player:SendMessage(cChatColor.LightGray .. "Pasted " .. NumBlocks .. " block(s) next to you.")
	end
	return true
end

function HandleRotateCommand(a_Split, a_Player)
	-- Check if the clipboard is valid...
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find anything on your clipboard to rotate.")
		return true
	end

	-- Check if the player gave an angle...
	local Angle = tonumber(a_Split[2])
	if (Angle == nil) then
		a_Player:SendMessage(cChatColor.LightGray .. "Usage: //rotate <90 | 180 | 270 | -90 | -180 | -270>")
		return true
	end

	-- Rotate the clipboard...
	local NumRots = math.floor(Angle / 90 + 0.5)  -- round to nearest 90-degree step
	State.Clipboard:Rotate(NumRots)
	a_Player:SendMessage(cChatColor.LightGray .. "Rotated the clipboard by " .. (NumRots * 90) .. " degree(s) CCW.")
	-- Get a size description of the clipboard.
	a_Player:SendMessage(cChatColor.LightGray .. "Size: " .. State.Clipboard:GetSizeDesc() .. ".")
	return true
end
