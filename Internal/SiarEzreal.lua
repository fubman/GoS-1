if GetObjectName(GetMyHero()) ~= "Ezreal" then return end

require ("DamageLib")

-- Menu
local EzrealMenu = Menu("Ezreal - Siar", "Ezreal - Siar")

-- Combo
EzrealMenu:SubMenu("Combo", "Combo Settings")
EzrealMenu.Combo:Boolean("Q", "Use Q", true)
EzrealMenu.Combo:Boolean("W", "Use W", true)
EzrealMenu.Combo:Boolean("R", "Use R - NOT AVAILABLE", false)

-- Harass
EzrealMenu:SubMenu("Harass", "Harass Settings")
EzrealMenu.Harass:Boolean("Q", "Use Q", true)
EzrealMenu.Harass:Boolean("W", "Use W", true)
EzrealMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- LaneClear
EzrealMenu:SubMenu("Farm", "Farm Settings")
EzrealMenu.Farm:Boolean("Q", "Use Q", true)
EzrealMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Ks
EzrealMenu:SubMenu("Ks", "KillSteal Settings")
EzrealMenu.Ks:Boolean("Q", "Use Q", true)
EzrealMenu.Ks:Boolean("R", "Use R", true)

-- Draw
EzrealMenu:SubMenu("Draw", "Drawing Settings")
EzrealMenu.Draw:Boolean("Q", "Draw Q", true)
EzrealMenu.Draw:Boolean("W", "Draw W", true)

-- Tick
OnTick(function()

	local target = GetCurrentTarget()
	if IOW:Mode() == "Combo" then
		-- Q
		if EzrealMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1150) then
			local targetPos = GetOrigin(target)
			CastSkillShot(_Q, targetPos)
		end
		-- W
		if EzrealMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 1000) then
			local targetPos = GetOrigin(target)
			CastSkillShot(_W, targetPos)
		end
	end

	if IOW:Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= EzrealMenu.Harass.Mana:Value() /100) then

			--Q
			if EzrealMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1150) then
				local targetPos = GetOrigin(target)
				CastSkillShot(_Q, targetPos)
			end

			--W
			if EzrealMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 1000) then
				local targetPos = GetOrigin(target)
				CastSkillShot(_W, targetPos)
			end
		end
	end

	if IOW:Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= EzrealMenu.Farm.Mana:Value() /100) then
			
			--Lane
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if EzrealMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 1150) then
						CastSkillShot(_Q, minion)
					end
				end
			end

			--Jungle
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if EzrealMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, 1150) then
						CastSkillShot(_Q, mob)
					end
				end
			end
		end
	end
	
	-- KS
	for _, enemy in pairs(GetEnemyHeroes()) do
		if EzrealMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, 1550) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				local targetPos = GetOrigin(target)
				CastSkillShot(_Q, targetPos)
			end
		end
		if EzrealMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, 3000) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
				local targetPos = GetOrigin(target)
				CastSkillShot(_R, targetPos)
			end
		end
	end
end)

-- Drawings 2
OnDraw(function (myHero)
	if EzrealMenu.Draw.Q:Value() then
		DrawCircle(GetOrigin(myHero), 1150, 0, 150, GoS.White)
	end
	if EzrealMenu.Draw.W:Value() then
		DrawCircle(GetOrigin(myHero), 1000, 0, 150, GoS.White)
	end
end)

print("Thank you for using my Ezreal script, I love you<3") 
