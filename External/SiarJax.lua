--Special thanks to Alqohol, Maresh and Toshibiotro.
if myHero.charName ~= "Jax" then return end
PrintChat("Powered by eXternal Orbwalker - Toshibiotro")

require("DamageLib")

local _inventoryTable = {}
local _wardItems = {}
local _updateTime = 0

-- Spells
local Spells = {
		Q = {range = 700, delay = 0.25, speed = 0, width = 0},
		W = {range = 300, delay = 0.25, speed = 0, width = 0},
		E = {range = 300, delay = 0.25, speed = 1450,  width = 0},
		R = {range = 100, delay = 1.35, speed = 0, width = 0}
}

-- Menú
Menu = MenuElement({type = MENU, id = "Jax", name = "Jax", leftIcon="http://ddragon.leagueoflegends.com/cdn/3.13.6/img/champion/Jax.png"})

-- Combo
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})

-- Harass
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassE", name = "Use W", value = true})
Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Farm
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Ks
Menu:MenuElement({type = MENU, id = "Ks", name = "Ks Settings"})
Menu.Ks:MenuElement({id = "KsQ", name = "Use Q", value = true})
if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
	Menu.Ks:MenuElement({id = "KsIg", name = "Use Ignite", value = true})
end
Menu.Ks:MenuElement({id = "Recall", name = "Disable during Recall", value = true})
Menu.Ks:MenuElement({id = "Enabled", name = "Disable All", value = false})

-- WardJump
Menu:MenuElement({type = MENU, id = "Wd", name = "WardJump Settings"})
Menu.Wd:MenuElement({id = "WardJump", name = "Ward Jump", key = 71})

-- Draw
Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
Menu.Draw:MenuElement({type = MENU, name = "Draw Q Spell", id = "Q"})
Menu.Draw.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.Q:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw W Spell", id = "W"})
Menu.Draw.W:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.W:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw E Spell", id = "E"})
Menu.Draw.E:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.E:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw R Spell", id = "R"})
Menu.Draw.R:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.R:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({name = "Disable All Drawings", id = "Disabled", value = false})
Menu.Draw:MenuElement({name = "Disable On CD", id = "CD", value = false})

-- Things
Callback.Add('Tick',function()

	if (_updateTime + 5000 < GetTickCount()) then
        for j = ITEM_1, ITEM_7 do
            _inventoryTable[j] = myHero:GetItemData(j);
        end
        GetWardItems()
        _updateTime = GetTickCount()
    end

    if Menu.Wd.WardJump:Value() then
			WardJump(mousePos)
	end

	if not myHero.dead then
		KillSteal()
		if EOW:Mode() == "Combo" then
			Combo(target)
		elseif EOW:Mode() == "Harass" then
			Harass(target)
		elseif EOW:Mode() == "LaneClear" then
			Farm()
		end
	end
end)


function KillSteal()
	if (Menu.Ks.Recall:Value() and IsRecalling() or not Menu.Ks.Recall:Value()) and not Menu.Ks.Enabled:Value() then return end
	for K, Enemy in pairs(GetEnemyHeroes()) do
		if Menu.Ks.KsQ:Value() and IsReady(_Q) then
			if getdmg("Q", Enemy, myHero) > Enemy.health then
				CastQ(Enemy)
			end
		end
		if myHero:GetSpellData(5).name == "SummonerDot" and Menu.Ks.KsIg:Value() and IsReady(SUMMONER_2) then
			if IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
				Control.CastSpell(HK_SUMMONER_2, Enemy)
			end
		end
		if myHero:GetSpellData(4).name == "SummonerDot" and Menu.Ks.KsIg:Value() and IsReady(SUMMONER_1) then
			if IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
				Control.CastSpell(HK_SUMMONER_1, Enemy)
			end
		end
	end
end

function WardJump(position)
	local unit = GetJumpUnit(150)
	if unit and myHero:GetSpellData(_Q) then
		CastQ(unit)
	end
	if not unit and IsReady(_Q) and myHero:GetSpellData(_Q) then
		if _wardItems[12] ~= nil and myHero:GetSpellData(ITEM_7).ammo > 0 then
			if _wardItems [12].itemID == 3340 and _wardItems[12].stacks > 0 then
				local ward = position
				Control.CastSpell(HK_ITEM_7, ward)
				DelayAction(function()
					CastQ(ward)
				end, 0.1)
			end
		end
		if myHero:GetSpellData(ITEM_7).ammo == 0 then
			for i=ITEM_1,ITEM_6 do
				if _wardItems[i] ~= nil then
					if i == 6 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 700 then
							local ward = position
							Control.CastSpell(HK_ITEM_1, ward)
							DelayAction(function()
								CastQ(ward)
							end, 0.1)
						end
				elseif i == 7 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(postiion) < 700 then
							local ward = position
							Control.CastSpell(HK_ITEM_2, ward)
							DelayAction(function()
								CastQ(ward)
							end, 0.1)
						end
				elseif i == 8 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 700 then
							local ward = position
							Control.CastSpell(HK_ITEM_3, ward)
							DelayAction(function()
								CastQ(ward)
							end, 0.1)
						end
				elseif i == 9 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 700 then
							local ward = position
							Control.CastSpell(HK_ITEM_4, ward)
							DelayAction(function()
								CastQ(ward)
							end, 0.1)
						end
				elseif i == 10 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 700 then
							local ward = position
							Control.CastSpell(HK_ITEM_5, ward)
							DelayAction(function()
								CastQ(ward)
							end, 0.1)
						end
				elseif i == 11 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 700 then
							local ward = position
							Control.CastSpell(HK_ITEM_6, ward)
							DelayAction(function()
								CastQ(ward)
							end, 0.1)
						end
					end
				end
			end
		end
	end
end

function GetWardItems()
	local wardingTotem = 3340
	local sightStone = 2049
	local rubySightStone = 2045
	local trackersKnife = 3711
	local warrior = 1408
	local cinderhulk = 1409
	local bloodrazor = 1418
	local runicEchos = 1410

	for i= ITEM_1, ITEM_7 do
		if _inventoryTable[i] ~= nil and 
			(_inventoryTable[i].itemID == wardingTotem or
				_inventoryTable[i].itemID == sightStone or
				_inventoryTable[i].itemID == rubySightStone or
				_inventoryTable[i].itemID == trackersKnife or
				_inventoryTable[i].itemID == warrior or
				_inventoryTable[i].itemID == cinderhulk or
				_inventoryTable[i].itemID == bloodrazor or
				_inventoryTable[i].itemID == runicEchos) then

			_wardItems[i] = _inventoryTable[i]
		elseif _wardItems[i] ~= nil and _wardItems[i] ~= _inventoryTable[i] then
			_wardItems[i] = nil
		end
	end
end


function GetJumpUnit(range)
	local unit
	for i = 1,Game.WardCount() do
		local ward = Game.Ward(i)
		if ward.pos:DistanceTo(mousePos) <= range and ward.isTargetable and ward.valid then
			unit = ward
			break
		end
	end
	return unit
end


function GetTarget(range)
	local GetEnemyHeroes = GetEnemyHeroes()
	local Target = nil
        for i = 1, #GetEnemyHeroes do
    	local Enemy = GetEnemyHeroes[i]
        if IsValidTarget(Enemy, range, false, myHero.pos) then
            Target = Enemy
        end
    end
    return Target
end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function CastQ(target)
	if target and IsReady(_Q) and IsValidTarget(target, Spells.Q.range, false, myHero.pos, Target) then
		local castPos = target:GetPrediction(Spells.Q.speed, Spells.Q.delay)
		Control.CastSpell(HK_Q, castPos)
	end
end

function CastW(target)
	if target and IsReady(_W) and IsValidTarget(target, Spells.W.range, false, myHero.pos, Target) then
		local castPos = target:GetPrediction(Spells.W.speed, Spells.W.delay)
		Control.CastSpell(HK_W, castPos)
	end
end

function CastE(target)
	if target and IsReady(_E) and IsValidTarget(target, Spells.E.range, false, myHero.pos, Target) then
		local castPos = target:GetPrediction(Spells.E.speed, Spells.E.delay)
		Control.CastSpell(HK_E, castPos)
	end
end

function CastR(target)
	if target and IsReady(_R) and IsValidTarget(target, Spells.R.range, false, myHero.pos, Target) then
		local castPos = target:GetPrediction(Spells.R.speed, Spells.R.delay)
		Control.CastSpell(HK_R, castPos)
	end
end

function Combo(target)
	if Menu.Combo.ComboE:Value() and IsReady(_E) then
		CastE(target)
	end
	if Menu.Combo.ComboQ:Value() and IsReady(_Q) then
		CastQ(target)
	end
	if Menu.Combo.ComboW:Value() and IsReady(_W) then
		CastW(target)
	end
	if Menu.Combo.ComboR:Value() and IsReady(_R) then
		CastR(myHero)
	end
end

function Harass(target)
	if (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value() / 100) then
		if Menu.Harass.HarassE:Value() and IsReady(_E) then
			CastE(target)
		end
		if Menu.Harass.HarassQ:Value() and IsReady(_Q) then
			CastQ(target)
		end
	end
end

function Farm()
	if (myHero.mana/myHero.maxMana >= Menu.Farm.FarmMana:Value() / 100) then
		local GetEnemyMinions = GetEnemyMinions()
		local Minion = nil
        for i = 1, #GetEnemyMinions do
			local Minion = GetEnemyMinions[i]
			if Menu.Farm.FarmQ:Value() and IsReady(_Q) then 
				CastQ(Minion)
			end
			if Menu.Farm.FarmW:Value() and IsReady(_W) then 
				CastW(myHero) 
			end
			if Menu.Farm.FarmE:Value() and IsReady(_E) then 
				CastE(Minion) 
			end
		end
	end
end

function GetEnemyMinions(range)
	EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local Minion = Game.Minion(i)
		if Minion.isEnemy and IsValidTarget(Minion, range, false, myHero) then
			table.insert(EnemyMinions, Minion)
		end
	end
	return EnemyMinions
end

function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function GetBuffs(unit)
	T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(T, Buff)
		end
	end
	return T
end

function IsImmune(unit)
	for K, Buff in pairs(GetBuffs(unit)) do
		if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" or Buff.name == "zhonyasringshield" then 
            return true
        end
	end
	return false
end

function Mode()
	if Orbwalker["Combo"].__active then
		return "Combo"
	elseif Orbwalker["Farm"].__active then
		return "LaneClear" 
	elseif Orbwalker["LastHit"].__active then
		return "LastHit"
	elseif Orbwalker["Harass"].__active then
		return "Harass"
	end
	return ""
end

function IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from) < range 
end

function IsReady(slot)
	if  myHero:GetSpellData(slot).currentCd == 0 and myHero.mana > myHero:GetSpellData(slot).mana and myHero:GetSpellData(slot).level > 0 then
		return true
	end
	return false
end

function OnDraw()
	if Menu.Draw.Disabled:Value() then return end
	
	if not Menu.Draw.CD:Value() then
		if Menu.Draw.Q.Enabled:Value() then
			Draw.Circle(myHero.pos, Spells.Q.range, 1, Menu.Draw.Q.Color:Value())
		end
		if Menu.Draw.W.Enabled:Value() then
			Draw.Circle(myHero.pos, Spells.W.range, 1, Menu.Draw.W.Color:Value())
		end
		if Menu.Draw.E.Enabled:Value() then
			Draw.Circle(myHero.pos, Spells.E.range, 1, Menu.Draw.E.Color:Value())
		end
		if Menu.Draw.R.Enabled:Value() then
			Draw.Circle(myHero.pos, Spells.R.range, 1, Menu.Draw.R.Color:Value())
		end
	else
		if Menu.Draw.Q.Enabled:Value() and IsReady(_Q) then
			Draw.Circle(myHero.pos, Spells.Q.range, 1, Menu.Draw.Q.Color:Value())
		end
		if Menu.Draw.W.Enabled:Value() and IsReady(_W) then
			Draw.Circle(myHero.pos, Spells.W.range, 1, Menu.Draw.W.Color:Value())
		end
		if Menu.Draw.E.Enabled:Value() and IsReady(_E) then
			Draw.Circle(myHero.pos, Spells.E.range, 1, Menu.Draw.E.Color:Value())
		end
		if Menu.Draw.R.Enabled:Value() and IsReady(_R) then
			Draw.Circle(myHero.pos, Spells.R.range, 1, Menu.Draw.R.Color:Value())
		end
	end
end
