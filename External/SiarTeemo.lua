if myHero.charName ~= "Teemo" then return end

require ("DamageLib")

-- Spells
local Spells = {
		Q = {range = 680, delay = 0.25, speed = 1500, width = 0},
		W = {range = 20, delay = 0.25, speed = 944, width = 0},
		E = {range = 680, delay = 0.25, speed = 1500,  width = 0},
		R = {range = 900, delay = 0.25, speed = 1000, width = 120}
}

-- Menú
Menu = MenuElement({type = MENU, id = "Teemo", name = "Teemo", lefticon="http://www.salsalol.com/images/champions/Teemo_Square_0.png?v=61"})

-- Combo Kappa
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})

-- Harass
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})

-- LaneClear
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = false})
Menu.Farm:MenuElement({id = "FarmR", name = "Use R", value = true})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- KS
Menu:MenuElement({type = MENU, id = "Ks", name = "Ks Settings"})
Menu.Ks:MenuElement({id = "KsQ", name = "Use Q", value = true})
if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
	Menu.Ks:MenuElement({id = "UseIg", name = "Use Ignite", value = false})
end
Menu.Ks:MenuElement({id = "Recall", name = "Disable during Recall", value = true})
Menu.Ks:MenuElement({id = "Enabled", name = "Disable All", value = false})

-- Draw
Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
Menu.Draw:MenuElement({type = MENU, name = "Draw Q Spell", id = "Q"})
Menu.Draw.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.Q:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw E Spell", id = "E"})
Menu.Draw.E:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.E:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw High Priority Shrooms", id = "SH"})
Menu.Draw.SH:MenuElement({name = "Enabled", id = "Enabled", value = true})
Menu.Draw.SH:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw Medium Priority Shrooms", id = "SM"})
Menu.Draw.SM:MenuElement({name = "Enabled", id = "Enabled", value = false})
Menu.Draw.SM:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({type = MENU, name = "Draw Low Priority Shrooms - WIP", id = "SL"})
Menu.Draw.SL:MenuElement({name = "Enabled", id = "Enabled", value = false})
Menu.Draw.SL:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
Menu.Draw:MenuElement({name = "Disable All Drawings", id = "Disabled", value = false})
Menu.Draw:MenuElement({name = "Disable On CD", id = "CD", value = false})

-- Things
Callback.Add('Tick',function()
	if not myHero.dead then
		KillSteal()
		if Mode() == "LaneClear" then
			Farm()
		end
		local target = GetTarget(2000)
		if target and not IsRecalling() then
			if Mode() == "Combo" then
				Combo(target)
			elseif Mode() == "Harass" then
				Harass(target)
			end
		end
	end
end)

function KillSteal()
	if (Menu.Ks.Recall:Value() and IsRecalling() or not Menu.Ks.Recall:Value()) and not Menu.Ks.Enabled:Value() then return end
	for K, Enemy in pairs(GetEnemyHeroes()) do
		if Menu.Ks.KsQ:Value() then
			if getdmg("Q", Enemy, myHero) > Enemy.health then
				CastQ(Enemy)
				return;
			end
		end
		if myHero:GetSpellData(5).name == "SummonerDot" and Menu.Ks.UseIgn:Value() and IsReady(SUMMONER_2) then
			if IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
				Control.CastSpell(HK_SUMMONER_2, Enemy)
				return;
			end
		end
		if myHero:GetSpellData(4).name == "SummonerDot" and Menu.Ks.UseIgn:Value() and IsReady(SUMMONER_1) then
			if IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
				Control.CastSpell(HK_SUMMONER_1, Enemy)
				return;
			end
		end
	end
end

function GetTarget(range)
	local GetEnemyHeroes = GetEnemyHeroes()
	local Target = nil
        for i = 1, #GetEnemyHeroes do
    	local Enemy = GetEnemyHeroes[i]
        if IsValidTarget(Enemy, range, false, myHero.pos) then
            Target   = Enemy
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
		local castPos = myHero
		Control.CastSpell(HK_W, castPos)
	end
end

function CastR(target)
	if target and IsReady(_R) and IsValidTarget(target, Spells.R.range, false, myHero.pos, Target) then
		local castPos = target:GetPrediction(Spells.R.speed, Spells.R.delay)
		Control.CastSpell(HK_R, castPos)
	end
end

function Combo(target)
	if Menu.Combo.ComboW:Value() and IsReady(_W) then
		CastW(myHero)
	end
	if Menu.Combo.ComboQ:Value() and IsReady(_Q) then
		CastQ(target)
	end
	if Menu.Combo.ComboR:Value() and IsReady(_R) then
		CastR(target)
	end
end

function Harass(target)
	if Menu.Harass.HarassQ:Value() and IsReady(_Q) then
		CastQ(target)
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
			if Menu.Farm.FarmR:Value() and IsReady(_R) then 
				CastR(Minion) 
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

function GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
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
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" then 
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
    return unit.pos:DistanceTo(from and from or myHero) < range 
end

function IsReady(slot)
	if  myHero:GetSpellData(slot).currentCd == 0 and myHero.mana > myHero:GetSpellData(slot).mana and myHero:GetSpellData(slot).level > 0 then
		return true
	end
	return false
end

function OnDraw()
	if Menu.Draw.Disabled:Value() then return end
	if Menu.Draw.SH.Enabled:Value() then
		Draw.Circle(4304, 51.8177528381348, 11790, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(4858, -71.2406005859375, 10672, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(3838, -57.3730926513672, 9424, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(6328, -63.2296752929688, 9174, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(8506, -54.6482696533203, 5750, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(9958, 45.1527471079102, 662, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(9932, -71.2406005859375, 4782, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(11104, -44.9435348510742, 5525, 50, 1, Draw.Color(255, 0, 0, 255))
		Draw.Circle(10530, 54.0132141113281, 3012, 50, 1, Draw.Color(255, 0, 0, 255))
	end
	if Menu.Draw.SM.Enabled:Value() then
		Draw.Circle(3038, 28.5316772460938, 12158, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(3030, -71.1159133911133, 10812, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(3774, -70.8193817138672, 10906, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(4882, 37.8906860351563, 8288, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(6500, -71.1190643310547, 8308, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(8424, -71.2406005859375, 6476, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(11012, -62.1705474853516, 3844, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(11842, -69.0882415771484, 4024, 50, 1, Draw.Color(255, 255, 255, 255))
		Draw.Circle(11802, 24.8543510437012, 2708, 50, 1, Draw.Color(255, 255, 255, 255))
	end
	if not Menu.Draw.CD:Value() then
		if Menu.Draw.Q.Enabled:Value() then
			Draw.Circle(myHero.pos, Spells.Q.range, 1, Menu.Draw.Q.Color:Value())
		end
	else
		if Menu.Draw.Q.Enabled:Value() and IsReady(_Q) then
			Draw.Circle(myHero.pos, Spells.Q.range, 1, Menu.Draw.Q.Color:Value())
		end
	end
	-- body
end
