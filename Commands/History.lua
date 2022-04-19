-- history.lua
-- Contains undo-redo commands.

function HandleUndoCommand(a_Split, a_Player)
	-- //undo

	local State = GetPlayerState(a_Player)
	local IsSuccess, Msg = State.UndoStack:Undo(a_Player:GetWorld())
	if (IsSuccess) then
		a_Player:SendMessage(cChatColor.LightGray .. "Reversed your previous edit.")
	else
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't undo your previous edit (" .. (Msg or "error") .. ").")
	end
	return true
end

function HandleRedoCommand(a_Split, a_Player)
	-- //redo

	local State = GetPlayerState(a_Player)
	local IsSuccess, Msg = State.UndoStack:Redo(a_Player:GetWorld())
	if (IsSuccess) then
		a_Player:SendMessage(cChatColor.LightGray .. "Restored your previous edit.")
	else
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't redo your previous edit (" .. (Msg or "error") .. ").")
	end
	return true
end
