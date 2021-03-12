CK = nil
TriggerEvent('CK:GetCoreObject', function(obj) CK = obj end)

CK.Item = {}
CK.ItemFunction = {}

AddEventHandler('CK:RegisterItemFunc', function(item, func)
	CK.ItemFunction[item] = func
end)

AddEventHandler('CK:UseItem', function(CPlayer, item, count)
	if CK.ItemFunction[item] and CPlayer.GetObj("package")[item] then
		CK.ItemFunction[item](CPlayer,item,count)
	end
end)

Citizen.CreateThread(function()
	CK.InitProperty("package",{})
	CK.InitProperty("packageSave",0)
	CK.InitProperty("GetPackageItem",GetPackageItem)-- 获得物品
	CK.InitProperty("AddPackageItem",AddPackageItem)-- 添加物品
	CK.InitProperty("RmPackageItem",RmPackageItem)-- 删除物品
	
	-- CK.InitProperty("BagFuncCosItem",BagFuncCosItem)
	-- CK.InitProperty("givePrizeToPlayer",givePrizeToPlayer)

	MySQL.Async.fetchAll("SELECT * FROM ck_items", {}, function (data)
		data = tabelstringtotable(data)
		if data then
			for _,v in pairs(data) do
				CK.Item[v.name] = v
			end
		end
	end)
end)

AddEventHandler('CK:HasPlayerLoad', function(CPlayer)
	MySQL.Async.fetchAll("SELECT name,`count`,timelimit,`type`,extradata FROM ck_package WHERE identifier = @identifier", {['@identifier'] = CPlayer.identifier}, function (data)
		data = tabelstringtotable(data)
		if data then
			for _,v in pairs(data) do
				v.label = CK.Item[v.name].label
				v.usable = CK.ItemFunction[v.name] and true or false
				v.bind = CK.Item[v.name].bind
			end
			CPlayer.SetObj("package",data)
			CPlayer.PropertyChanged()
		end
	end)
end)

AddEventHandler('CK:SavePlayer', function(CPlayer)
	if CPlayer.GetObj("packageSave") == 1 then
		local rmpkg = {}
		for k in pairs(CK.Item) do
			rmpkg[k] = 1
		end
		for _,v in pairs(CPlayer.GetObj("package")) do
			MySQL.Async.execute('REPLACE INTO ck_package (identifier,name,count,timelimit,extradata) VALUES (@identifier,@name,@count,@timelimit,@extradata)', {
				['@identifier'] = CPlayer.GetObj("identifier"),
				['@name']       = v.name,
				['@count']      = v.count,
				['@timelimit']  = v.timelimit,
				['@extradata']  = v.extradata,
			}, function(rowsChanged)
			end)
			if rmpkg[v.name] then
				rmpkg[v.name] = nil
			end
		end
		for k in pairs(rmpkg) do
			MySQL.Async.execute('DELETE FROM ck_package WHERE identifier = @identifier and name = @name', {
				['@identifier'] = CPlayer.GetObj("identifier"),
				['@name']       = k
			}, function(rowsChanged)
			end)
		end
		CPlayer.SetObj("packageSave", 0)
	end
end)

function GetPackageItem(self, name, timelimit)
	for k,v in pairs(self.GetObj("package")) do
		if v.name == name and v.timelimit == (timelimit or 0) then
			return v
		end
	end
	return {}
end

function AddPackageItem(self, name, count, timelimit, extradata, strReason)
	self.SetObj("packageSave",1)
	local CItem = self.GetObj("package")
	for k,v in pairs(CItem) do
		if v.name == name and v.timelimit == (timelimit or 0) then
			v.count = v.count + count
			self.SetObj("package", CItem)
			return
		end
	end
	local NItem = {name = name,count = (count or 1), timelimit = (timelimit or 0), extradata = (extradata or {}), label = CK.Item[name].label, usable = CK.ItemFunction[name] and true or false, bind = CK.Item[name].bind}
	CItem[#CItem+1] = NItem
	self.SetObj("package", CItem)
end

function RmPackageItem(self, name, count, timelimit, strReason)
	self.SetObj("packageSave", 1)
	local isRm = 0
	for k,v in pairs(self.GetObj("package")) do
		if v.name == name and v.timelimit == (timelimit or 0) then
			v.count = (v.count - count) < 0 and 0 or (v.count - count)
			if v.count == 0 then
				isRm = k
			end
			break
		end
	end
	if isRm ~= 0 then
		table.remove(self.GetObj("package"), isRm)
	end
end

local function BagCanFuncCosItem(self, items)
	for _,v in pairs(string.split(items, ",")) do
		local j = string.split(v, ":")
		if j[1] == "money" then
			if self.GetObj("money") < tonumber(j[2]) then
				TriggerClientEvent('esx:showNotification', source, "现金不足: "..j[2])
				return false
			end
		elseif j[1] == "bank" then
			if self.GetObj("bank") < tonumber(j[2]) then
				TriggerClientEvent('esx:showNotification', source, "银行卡不足: "..j[2])
				return false
			end
		else
			local Item = self:GetPackageItem(j[1])
			if Item.count < tonumber(j[2]) then
				TriggerClientEvent('esx:showNotification', source, "物品不足：".. CK.Item[j[1]].label .." * "..(tonumber(j[2])-Item.count))
				return false
			end
		end
	end
	return true
end

local function GetItemsMsg(item)
	local CosItemMsg = ""
	for _,v in pairs(string.split(item, ",")) do
		local j = string.split(v, ":")
		if j[1] == "money" then
			CosItemMsg = CosItemMsg .. "现金 * " .. j[2] .. " ;"
		elseif j[1] == "bank" then
			CosItemMsg = CosItemMsg .. "银行卡 * " .. j[2] .. " ;"
		else
			CosItemMsg = CosItemMsg .. CK.Item[j[1]].label .. " * " .. j[2] .. " ;"
		end
	end
	return CosItemMsg
end

function BagFuncCosItem(self, items, strReason)
	if BagCanFuncCosItem(self, items) then
		for _,v in pairs(string.split(items, ",")) do
			local j = string.split(v, ":")
			if j[1] == "money" then
				self.SetObj("money", self.GetObj("money") - tonumber(j[2]))
			elseif j[1] == "bank" then
				self.SetObj("bank", self.GetObj("bank") - tonumber(j[2]))
			else
				self:RmPackageItem(j[1], j[2], 0, strReason)
			end
		end
		return true
	end
end

function givePrizeToPlayer(self, items, strReason)
	for _,v in pairs(string.split(items, ",")) do
		local j = string.split(v, ":")
		if j[1] == "money" then
			self.SetObj("money", self.GetObj("money") + tonumber(j[2]))
		elseif j[1] == "bank" then
			self.SetObj("bank", self.GetObj("bank") + tonumber(j[2]))
		else
			self:AddPackageItem(j[1], j[2], 0, {}, strReason)
		end
	end
	return true
end