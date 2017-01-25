if myHero.charName ~= "Gragas" then return end

require ("DamageLib")

-- Spells
local Spells = {
		Q = {range = 850, delay = 0.25, speed = 1000, width = 110},
		W = {range = 850, delay = 1, speed = 828},
		E = {range = 600, delay = 0.25, speed = 500, width = 50},
		R = {range = 1000, delay = 0.25, speed = 200, width = 120},
}

-- Menú
Menu = MenuElement({type = MENU, id = "Siar - Gragas", name = "Siar - Gragas", leftIcon="http://2.bp.blogspot.com/-IZcNPdC8bWg/VEllEofRtjI/AAAAAAAAbWw/B9qPy88Islg/s1600/Gragas_Square_0.png"})

-- Combo
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
Menu.Combo:MenuElement({id = "REnemy", name = "Min. Enemies to cast R", value = 2, min  = 1, max = 5})

-- Harass
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Farm
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings - WORK IN PROGRESS"})
Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Ks
Menu:MenuElement({type = MENU, id = "Ks", name = "KillSteal Settings"})
Menu.Ks:MenuElement({id = "KsQ", name = "Use Q", value = true})
Menu.Ks:MenuElement({id = "Recall", name = "Don't Ks during Recall", value = true})
Menu.Ks:MenuElement({id = "Disabled", name = "Don't Ks", value = false})

-- Tick | KillSteal | Cast
Callback.Add('Tick', function()
	if not myHero.dead then
		KillSteal()
		if EOW:Mode() == "Combo" then
			Combo()
		end
		if EOW:Mode() == "Harass" then
			Harass()
		end
	end
end)

function KillSteal()
	if Menu.Ks.Disabled:Value() or (IsRecalling() and Menu.Ks.Recall:Value()) then return end
	for K, Enemy in pairs(GetEnemyHeroes()) do
		if Menu.Ks.KsQ:Value() and IsReady(_Q) then
			local qPos = Enemy:GetPrediction(Spells.Q.Speed, Spells.Q.Delay)
			if getdmg("Q", Enemy, myHero) > Enemy.health and IsValidTarget(myHero, Spells.Q.Range, false, qPos) then
				CastQ(qPos)
			end
		end
	end
end

function CastQ(qPos)
	local target = GetTarget(Spells.Q.Range)
	if target ~= nil then
		local qPos = target:GetPrediction(Spells.Q.Speed, Spells.Q.Delay)
		if IsReady(_Q) and IsValidTarget(target, Spells.Q.Range, false, myHero.pos, Target) then
			Control.CastSpell(HK_Q, qPos)
		end
	end
end

function CastW(target)
	if target and IsReady(_W) and IsValidTarget(target, Spells.W.range, false, myHero.pos, Target) then
		local wPos = target:GetPrediction(Spells.W.Speed, Spells.W.Delay)
		Control.CastSpell(HK_W, wPos)
	end
end

function CastE(ePos)
	local target = GetTarget(Spells.E.Range)
	if target ~= nil then
		local ePos = target:GetPrediction(Spells.E.Speed, Spells.E.Delay)
		if IsReady(_E) and IsValidTarget(target, Spells.E.Range, false, myHero.pos, Target) then
			Control.CastSpell(HK_E, ePos)
		end
	end
end

function CastR(rPos)
	local target = GetTarget(Spells.R.Range)
	if target ~= nil then
		local rPos = target:GetPrediction(Spells.R.Speed, Spells.R.Delay)
		if IsReady(_Q) and IsValidTarget(target, Spells.R.Range, false, myHero.pos, Target) then
			Control.CastSpell(HK_R, rPos)
		end
	end
end

-- Combo | Harass | Farm

function Combo()
	if Menu.Combo.ComboW:Value() then
		CastW(myHero)
	end

	if Menu.Combo.ComboQ:Value() then
		CastQ(qPos)
	end

	if Menu.Combo.ComboR:Value() and GetEnemyCount() >= Menu.Combo.REnemy:Value() and IsReady(_R) then
		CastR(rpos)
	end

	if Menu.Combo.ComboE:Value() then
		CastE(ePos)
	end
end

function Harass()
	if (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value() / 100) then
		if Menu.Harass.HarassQ:Value() then
			CastQ(qPos)
		end
		if Menu.Harass.HarassE:Value() then
			CastE(ePos)
		end
	end
end

-- Things
function GetTarget(range)
  local target = nil
  local lessCast = 0
  local GetEnemyHeroes = GetEnemyHeroes()
  for i = 1, #GetEnemyHeroes do
  	local Enemy = GetEnemyHeroes[i]
    if IsValidTarget(Enemy, range, false, myHero.pos) then
      local Armor = (100 + Enemy.magicResist) / 100
      local Killable = Armor * Enemy.health
      if Killable <= lessCast or lessCast == 0 then
        target = Enemy
        lessCast = Killable
      end
    end
  end
  return target
end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function IsBuffed(target, BuffName)
	for K, Buff in pairs(GetBuffs(target)) do
		if Buff.name == BuffName then
			return true
		end
	end
	return false
end

function GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function GetEnemyCount(range)
	local count = 0
	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			count = count + 1
		end
	end
	return count
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

function GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
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
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" or Buff.name == "zhonyasringshield" then 
            return true
        end
	end
	return false
end

function IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from) < range 
end

function IsReady(slot)
	assert(type(slot) == "number", "IsReady > invalid argument: expected number got " ..type(slot))
	return (myHero:GetSpellData(slot).level >= 1 and myHero:GetSpellData(slot).currentCd == 0 and myHero:GetSpellData(slot).mana <= myHero.mana)
end
