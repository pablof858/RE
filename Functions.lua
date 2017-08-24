local lib = ...;
if lib.boom then
  return
end
lib.boom = true
const = _DevPad:FindScripts( "Constants" )
const()

delayEndTime = {}
delaySpells = {}
delayTargets = {}
globalDelayEndTime = 0
cTar = {"target","focus","mouseover","arena1","arena2","arena3","arena4","arena5"}
lib.group = {} -- dictionary key = party member name ; value = group num
lib.lowestMember = {100, 0}

lib.hardOnGroup = {} -- 2d array key = group num ; value = {total_hard, physical, magic }
local playerIndex = 1

function lib:CalculateHP(t)
  return 100 * UnitHealth(t) / UnitHealthMax(t)
end

function lib:initalizeGroup()
  local prefix = "party"
  
  if UnitInRaid("player") or IsActiveBattlefieldArena() then prefix = "raid" end
  local size = GetNumGroupMembers()
  if size == 1 or prefix == "party" then
    lib.lowestMember = {100 * UnitHealth("player") / UnitHealthMax("player"), UnitGUID("player")}
    lib.hardOnGroup[1] = {0,0,0,0,0}
    lib.group[UnitGUID("player")] = 1
    for i = 1, size - 1 do
      lib.hardOnGroup[i + 1] = {0,0,0,0,0}
      lib.group[UnitGUID(prefix..i)] = i + 1
      if lib.lowestMember[1] > 100 * UnitHealth(prefix..i) / UnitHealthMax(prefix..i) then
        lib.lowestMember = {100 * UnitHealth(prefix..i) / UnitHealthMax(prefix..i), UnitGUID(prefix..i)}
      end
    end
  else
    for i = 1, size do
      if lib.lowestMember[1] > 100 * UnitHealth(prefix..i) / UnitHealthMax(prefix..i) then
        lib.lowestMember = {100 * UnitHealth(prefix..i) / UnitHealthMax(prefix..i), UnitGUID(prefix..i)}
      end
      lib.hardOnGroup[i] = {0,0,0,0,0}
      lib.group[UnitGUID(prefix..i)] = i
      if UnitGUID(prefix .. i) == UnitGUID("player") then
        playerIndex = i
      end
    end
  end
end
lib:initalizeGroup() -- set up group for first time

function delayRotation(length)
  globalDelayEndTime = length + GetTime()
end


function addDelay(spell, length , target)
  delayEndTime[#delayEndTime + 1] = length + GetTime()
  delaySpells[#delaySpells + 1] = spell
  delayTargets[#delayTargets + 1] = target
end

function lib:phycicalImmunity(UnitID)
  return lib:haveBuff(UnitID, const.immunePhysical)
end

function lib:magicImmunity(UnitID)
  return lib:haveBuff(UnitID, const.immuneSpell)
end
function lib:goingHard(UnitID)
  return lib:haveBuff(UnitID, const.attentionBuffs)
end



lib.hardOnMe = lib.hardOnGroup[playerIndex]

function lib:updateDeathThreats()
  lib:initalizeGroup()
  for i=1,#cTar do
    if UnitExists(cTar[i]) then -- sort death threats for each group member by {total, physical, magic}
      if UnitExists(cTar[i].."target") and lib:goingHard(cTar[i]) then
        
        if lib.group[UnitGUID(cTar[i].."target")] ~= nil then
          local index = lib.group[UnitGUID(cTar[i].."target")]
          if UnitPower(cTar[i].."target", 0) > 60000 then
            lib.hardOnGroup[index][3] = lib.hardOnGroup[index][3] + 1
          else
            lib.hardOnGroup[index][2] = lib.hardOnGroup[index][2] + 1
          end
          lib.hardOnGroup[index][1] = lib.hardOnGroup[index][1] + 1
        end
      elseif UnitExists(cTar[i].."target") and lib.group[UnitGUID(cTar[i].."target")] ~= nil then
        local index = lib.group[UnitGUID(cTar[i].."target")]
        if UnitPower(cTar[i].."target", 0) > 60000 then
          lib.hardOnGroup[index][5] = lib.hardOnGroup[index][5] + 1
        else
          lib.hardOnGroup[index][4] = lib.hardOnGroup[index][4] + 1
        end
      end
    end
  end
  lib.hardOnMe = lib.hardOnGroup[playerIndex]
end


function lib:spellCheck(spell, target)
  if     UnitExists(target) 
  and lib:oSpellAvailable(spell)
  and IsSpellInRange(GetSpellInfo(spell), target) == 1
  and UnitCanAttack("player", target) == 1  
  --    and not TargetImmune(target)
  and not UnitIsDeadOrGhost(target)
  and olos(target) == 0
  then
    return true
  else
    return false
  end
end

function lib:spellCheckFriendly(spell, target)
  if     UnitExists(target) 
  and lib:oSpellAvailable(spell)
  and IsSpellInRange(GetSpellInfo(spell), target) == 1
  and UnitCanAttack("player", target) ~= 1  
  --    and not TargetImmune(target)
  and not UnitIsDeadOrGhost(target)
  and olos(target) == 0
  then
    return true
  else
    return false
  end
end

function lib:unitDebuffID(UnitID, SpellID, Filter)
  local spell, rank = GetSpellInfo(SpellID)
  local a,b,c,d,e,f,g,h,i,j,k = UnitDebuff(UnitID,spell, rank, Filter)
  return a,b,c,d,e,f,g,h,i,j,k
end

function lib:unitBuffID(UnitID, SpellID, Filter)
  local spell, rank = GetSpellInfo(SpellID)
  local a,b,c,d,e,f,g,h,i,j,k =  UnitBuff(UnitID,spell, rank, Filter)
  return a,b,c,d,e,f,g,h,i,j,k
end


function lib:haveBuff(UnitID,SpellID,TimeLeft,Filter) 
  if not TimeLeft then TimeLeft = 0 end
  if type(SpellID) == "number" then SpellID = { SpellID } end 
  for i=1,#SpellID do 
    local spell, rank = GetSpellInfo(SpellID[i])
    if spell then
      local buff = select(7,UnitBuff(UnitID,spell,rank,Filter)) 
      if buff and ( buff == 0 or buff - GetTime() > TimeLeft ) then return true end
    end
  end
  return false
end

function lib:haveDebuff(UnitID,SpellID,TimeLeft,Filter) 
  if not TimeLeft then TimeLeft = 0 end
  if type(SpellID) == "number" then SpellID = { SpellID } end 
  for i=1,#SpellID do 
    local spell, rank = GetSpellInfo(SpellID[i])
    if spell then
      local debuff = select(7,UnitDebuff(UnitID,spell,rank,Filter)) 
      if debuff and ( debuff == 0 or debuff - GetTime() > TimeLeft ) then return true end
    end
  end
  return false
end

function lib:oCastSpellByID(spell, UnitID)
  if globalDelayEndTime > GetTime() then return end
  oexecute("CastSpellByID(" .. spell .. "," .. "'" .. UnitID .. "'" .. ")")
end

function lib:oCastSpellByName(spell, UnitID)
  if globalDelayEndTime > GetTime() then return end
  oexecute("CastSpellByName(" .."'" .. spell .."'" .. "," .. "'" .. UnitID .. "'" .. ")")
end

function lib:oCastSpellByIDWithDelay(spell, UnitID, delay) -- delay is how long before next possible recast
  if globalDelayEndTime > GetTime() then return end
  local inDelay = false
  local tempDelayEndTime = {} -- for garbage collection
  local tempDelaySpells = {}
  local tempDelayTargets = {}
  for i = 1, #delaySpells do
    if delayEndTime[i] > GetTime() then
      local newIndex = #tempDelayEndTime + 1 -- shift over other delays deleting expired ones
      tempDelayEndTime[newIndex] = delayEndTime[i]
      tempDelaySpells[newIndex] = delaySpells[i]
      tempDelayTargets[newIndex] = delayTargets[i]
      if spell == tempDelaySpells[newIndex] and UnitID == tempDelayTargets[newIndex] then
        inDelay = true
      end
    end
  end
  delayEndTime = tempDelayEndTime
  delaySpells = tempDelaySpells
  delayTargets = tempDelayTargets
  if not inDelay then
    addDelay(spell,delay,UnitID)
    oexecute("CastSpellByID(" .. spell .. "," .. "'" .. UnitID .. "'" .. ")")
    return true
  end
  return false
end

function lib:dist(Unit1, Unit2)
  if UnitExists(Unit1) and UnitExists(Unit2) then
    local x1, y1, z1 = oinfo(Unit1)
    local x2, y2, z2 = oinfo(Unit2)
    return sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)  
  end  
  return 0  
end  

function lib:stealthFinder(spell)
  for _,v in pairs(cTar) do
    if lib:haveBuff(v, {1856, 1784, 5215, 66, 58984})  -- vanish, stealth, powl, invis, shadowmeld
    and lib:spellCheck(v, spell) then
      lib:oCastSpellByID(spell, v)
      return true
    end
    return false
  end
end




GCDSpellID = nil
function GCDSpellID()
  
  local _, playerClass = UnitClass("player")
  
  if playerClass == "DEATHKNIGHT" then
    return 52375
  elseif playerClass == "DRUID" then
    return 774
  elseif playerClass == "HUNTER" then
    return 56641
  elseif playerClass == "MAGE" then
    return 1459
  elseif playerClass == "PALADIN" then
    return 85256
  elseif playerClass == "PRIEST" then
    return 2050
  elseif playerClass == "ROGUE" then
    return 1752
  elseif playerClass == "SHAMAN" then
    return 45284
  elseif playerClass == "WARLOCK" then
    return 980
  elseif playerClass == "WARRIOR" then
    return 1715
  elseif playerClass == "MONK" then
    return 100780
  else
    return 0
  end
  
end

PQR_SpellAvailable = nil
function lib:oSpellAvailable(spellID)
  
  if not IsSpellKnown(spellID) then return false end
  
  local gcdSpell = GCDSpellID()
  local gcdStartTime, gcdDuration = GetSpellCooldown(gcdSpell)
  local spellStartTime, spellDuration = GetSpellCooldown(spellID)
  local spellUsable = IsUsableSpell(spellID)
  local spellAvailable = false
  local SpellAvailableTime = 0.01
  
  if spellUsable then
    if spellStartTime ~= nil and gcdStartTime ~= nil then
      local spellTimeLeft = spellStartTime + spellDuration - GetTime()
      local gcdTimeLeft = gcdStartTime + gcdDuration - GetTime()
      if gcdTimeLeft <= 0 then
        --Our GCD spell is not on CD.
        if spellTimeLeft <= SpellAvailableTime then
          --spell will be off CD within 50ms.
          spellAvailable = true
        end
      else
        --Our GCD spell is on CD.
        if spellTimeLeft <= gcdTimeLeft + SpellAvailableTime then
          --spell time left is less than GCD time left + 50ms.
          spellAvailable = true
        end
      end
    end
  end
  
  return spellAvailable
end

function lib:interuptProtection()
  SIN_InterruptFrame = SIN_InterruptFrame or CreateFrame("FRAME", nil, UIParent)
  function SIN_Interrupt_OnEvent(self, event, ...)
    local flag = { "Alliance Flag", "Horde Flag", "Netherstorm Flag" }
    for _,v in ipairs(flag) do oexecute("InteractUnit('" .. v.. "')") end -- auto return flag
    local type, _, sourceGUID, _, _, _, destGUID = select(2, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
      if type == "SPELL_CAST_SUCCESS" then
        if destGUID == UnitGUID("player") and (UnitCastingInfo("player") or UnitChannelInfo("player")) then
          local spellId = select(12, ...)
          for i = 1, #const.interruptId do
            if spellId == const.interruptId[i] then
              oexecute("SpellStopCasting()")
              print("Juked " ..GetSpellInfo(spellId))
              delayRotation(.5)
            end
          end
        end
      end
    end
  end
  
  SIN_InterruptFrame:SetScript("OnEvent", SIN_Interrupt_OnEvent)
  SIN_InterruptFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end
lib:interuptProtection()

local percentinterupt = 50

function lib:interrupt(SpellID, healingonly)
  if type(SpellID) == "number" then SpellID = { SpellID } end 
  local interrupt = const.interruptSpells
  if healingonly then
    interrupt = const.healingInterrupt
  end
  
  for j=1, #SpellID do 
    for i=1, #cTar do
      if UnitExists(cTar[i]) then
        local castName, _, _, _, castStartTime, castEndTime, _, _, castInterruptable =
        UnitCastingInfo(cTar[i])
        
        for _, v in ipairs(interrupt) do
          if GetSpellInfo(v) == castName and castInterruptable == false then
            local timeSinceStart = (GetTime() * 1000 - castStartTime) / 1000
            local timeLeft = ((GetTime() * 1000 - castEndTime) * -1) / 1000
            local castTime = castEndTime - castStartTime
            local currentPercent = timeSinceStart / castTime * 100000
            if (currentPercent > percentinterupt or timeLeft < .5)
            and UnitCanAttack("player", cTar[i]) ~= nil
            and not IsStealthed()
            and lib:oSpellAvailable(SpellID[j]) 
            then
              lib:oCastSpellByName(GetSpellInfo(SpellID[j]),cTar[i])
              oclick(cTar[i])
              return true
            end
          end
        end
      end
    end
    
    
    ---------------------InterruptChannel------------------------
    
    interrupt = const.interruptChannel
    if healingonly then
      interrupt = const.healingChannel
    end
    
    for i=1, #cTar do
      if UnitExists(cTar[i]) then
        local spellName, _, _, _, _, endCast, _, canInterrupt = UnitChannelInfo(cTar[i])
        for _, v in ipairs(interrupt) do
          if GetSpellInfo(v) == spellName and canInterrupt == false then
            if ((endCast/1000) - GetTime()) < 10.5 
            and not IsStealthed()
            and lib:oSpellAvailable(SpellID[j])
            then
              lib:oCastSpellByName(GetSpellInfo(SpellID[j]),cTar[i])
              oclick(cTar[i])
              return true
            end
          end
        end
      end
    end
  end
  return false
end
