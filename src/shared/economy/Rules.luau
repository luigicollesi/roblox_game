--!nonstrict
local Rules = {}
Rules.rarity = {"Comum", "Superior", "Obra-prima"}
Rules.valuePct = {60, 120, 220}
Rules.durabilityPct = {100, 135, 180}
function Rules.chances(m)
    if m < 10 then return {100, 0, 0} end
    if m < 25 then return {80, 20, 0} end
    if m < 50 then return {55, 45, 0} end
    if m < 75 then return {30, 65, 5} end
    if m < 100 then return {15, 65, 20} end
    return {10, 65, 25}
end
function Rules.roll(m, roll)
    local p = Rules.chances(m)
    if roll <= p[1] then return 1 end
    if roll <= p[1] + p[2] then return 2 end
    return 3
end
function Rules.retail(value) return math.ceil(value * 11 / 10) end
function Rules.used(value, current, maximum)
    return math.floor(value * math.clamp(current, 0, maximum) / maximum)
end
function Rules.repairUnits(original, current, maximum)
    return math.ceil(original * (maximum - current) / (2 * maximum))
end
function Rules.serviceFee(cost) return math.ceil(cost / 5) end
function Rules.stockPrice(base, stock, target)
    return math.max(1, math.floor(base * math.clamp(1.5 - stock / (2 * target), 0.5, 1.5) + 0.5))
end
function Rules.newValue(cost, rarity, stock)
    local factor = math.clamp(1.15 - stock * 0.025, 0.85, 1.05)
    return math.max(1, math.floor(cost * Rules.valuePct[rarity] / 100 * factor))
end
function Rules.learnCost(recipe, materials)
    local sum = 0
    for id, qty in pairs(recipe.inputs) do sum += materials[id].price * qty end
    return math.max(5, math.ceil(sum / 2))
end
-- Shared preview and authoritative calculation use identical arithmetic.
local defaultDamageTypes = {sword="slash",greatsword="slash",shortkatana="slash",longkatana="slash",knife="slash",dagger="pierce",smallshield="none",largeshield="none",staff="arcane",wand="arcane",axe="slash",greataxe="slash",mace="blunt",warhammer="blunt",spear="pierce",halberd="slash"}
function Rules.stats(recipe, rarity)
    local attackPct=({100,115,135})[rarity]
    local defensePct=({100,110,125})[rarity]
    local baseDamage=recipe.power
    local baseMagic=recipe.magic
    local damageBonus=recipe.damageBonus or 0
    local magicBonus=recipe.magicBonus or 0
    local damage=math.floor((baseDamage+damageBonus)*attackPct/100)
    local magic=math.floor((baseMagic+magicBonus)*attackPct/100)
    return {damage=damage,defense=math.floor(recipe.defense*defensePct/100),magic=magic,
        baseDamage=baseDamage,damageBonus=damageBonus,qualityDamageBonus=damage-baseDamage-damageBonus,
        baseMagic=baseMagic,magicBonus=magicBonus,qualityMagicBonus=magic-baseMagic-magicBonus,
        damageType=recipe.damageType or defaultDamageTypes[recipe.category] or "none",
        maximum=math.floor(recipe.durability*Rules.durabilityPct[rarity]/100)}
end
return Rules
