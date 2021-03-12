
TriggerEvent('CK:RegisterItemFunc', "water", function(CPlayer, item, count)

end)

AddEventHandler('CK:RemovePackage', function(CPlayer, item, count)
	if CPlayer.GetObj("package")[item] then
		
	end
end)

AddEventHandler('CK:GiveItem', function(CPlayer, item, count, serverid)
	if CPlayer.GetObj("package")[item] then
		
	end
end)

Citizen.CreateThread(function()
	Wait(5000)
	local CPlayer = CK.GetPlayerFromId(1)
	CPlayer:AddPackageItem("hamburger",2)
	CPlayer.PropertyChanged()
	CPlayer:AddPackageItem("water",2)
end)