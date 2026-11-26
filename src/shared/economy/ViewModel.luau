--!nonstrict
-- Pure presentation helpers: no pricing or authorization logic.
local M={}
local Sets=require(script.Parent.ArmorSets)
local Specials=require(script.Parent.SpecialEffects)
local aliases={wood="Madeira",metal="Metal",stone="Pedra / cristal",leather="Couro",sword="Espada de uma mão",greatsword="Espada de duas mãos",shortkatana="Katana curta",longkatana="Katana longa",knife="Faca",dagger="Adaga",smallshield="Escudo pequeno",largeshield="Escudo grande",staff="Cajado",wand="Varinha",axe="Machado de uma mão",greataxe="Machado de duas mãos",mace="Maça",warhammer="Martelo de guerra",spear="Lança",halberd="Alabarda",cloth="Tecido",armor_head="Cabeça",armor_torso="Torso",armor_legs="Calça",armor_feet="Pés"}
function M.category(id) return aliases[id] or id end
function M.profileTabs(studio)
    local tabs={"Status","Inventário","Equipamentos","Conjuntos","Maestria","Catálogo"}
    if studio then table.insert(tabs,"Teste Studio") end
    return tabs
end
function M.serviceTabs(view)
    if view.shop then
        local tabs={"Comprar"}
        if view.shop.canSell then table.insert(tabs,"Vender") end
        return tabs
    end
    local groups,seen={},{}
    for _,row in ipairs(view.actions) do
        if row.group~="Equipar" and row.group~="Teste Studio" and not seen[row.group] then
            seen[row.group]=true;table.insert(groups,row.group)
        end
    end
    return groups
end
function M.matchesProduct(row,tab,kind)
    local p=row.product
    if not p then return false end
    return p.side==(tab=="Comprar" and "buy" or "sell") and (kind=="all" or p.kind==kind or (kind=="armor" and p.kind=="equipment" and p.armorSlot~=nil) or (kind=="weapon" and p.kind=="equipment" and p.armorSlot==nil))
end
function M.productCards(rows,tab,kind,accept)
    local cards,byKey={},{}
    for _,row in ipairs(rows) do
        if M.matchesProduct(row,tab,kind) and accept(row.product) then
            local p=row.product
            -- Equipment instances are unique; material sizes share one product card.
            local key=p.kind=="equipment" and p.uid or string.match(row.id,"^[^:]+:([^:]+):")
            key=p.kind..":"..(key or row.id)
            local card=byKey[key]
            if not card then
                card={product=p,actions={}}
                byKey[key]=card;table.insert(cards,card)
            end
            table.insert(card.actions,row)
        end
    end
    return cards
end
local damageLabels={slash="Corte",pierce="Perfuração",blunt="Impacto",arcane="Arcano",none="Defensivo"}
function M.attackText(a)
    if a.hits==0 then return "Defensivo: sem ataque básico" end
    local hitStrings={}
    for _,d in ipairs(a.hitDamage) do table.insert(hitStrings,tostring(d)) end
    local text=a.hits.." golpe(s) no alvo principal: "..table.concat(hitStrings," + ").." = "..a.primaryDamage.." por ação"
    if a.targets>1 then
        text..=" | Área: até "..a.targets.." alvos, "..a.secondaryDamage.." por alvo adicional ("..a.splashPct.."%) | Total máximo: "..a.maxActionDamage
    else text..=" | Alvo único" end
    return text
end
function M.effectText(e)
    if e.kind=="lifesteal" then return "Roubo de vida: "..e.percent.."% do dano efetivo ("..(e.scope=="physicalBasic" and "ataques físicos básicos" or "ataque básico da arma de origem")..")."
    elseif e.kind=="followup" then return "Eco: "..e.chancePct.."% de chance de um golpe adicional ("..e.damagePct.."% do primeiro golpe), uma vez por ação."
    elseif e.kind=="manaArmor" then return "Armadura de mana: barreira inicial de "..e.percent.."% da mana máxima."
    elseif e.kind=="spell" then
        local spell=e.spell or assert(Specials.spell(e.spellId))
        return "Feitiço: "..spell.name.." | "..spell.manaCost.." mana | recarga "..spell.cooldown.." turnos | "..(spell.kind=="heal" and "cura" or "dano").." base "..spell.base.." | até "..spell.targets.." alvos"
    elseif e.kind=="firstSpellDiscount" then return "Primeiro feitiço do combate: "..e.percent.."% de desconto de mana."
    elseif e.kind=="fatalSurvival" then return "Sobrevive a golpe fatal com 1 PV, uma vez por combate."..(e.healPct>0 and (" Recupera "..e.healPct.."% da vida máxima.") or "")
    elseif e.kind=="openingReduction" then return "Reduz dano recebido em "..e.percent.."% até o fim de "..e.turns.." turnos próprios."
    elseif e.kind=="firstHitDodge" then return e.chancePct.."% de chance de evitar o primeiro golpe de ação inimiga; até uma ativação por rodada."
    elseif e.kind=="killHeal" then return "Ao derrotar inimigo: recupera "..e.percent.."% da vida máxima, uma vez por ação."
    end
    return e.kind
end
function M.specialText(s)
    if not s then return "" end
    return "Relíquia | Vida máxima +"..s.health.." | Mana máxima +"..s.mana.." | Dano mágico global +"..s.magicDamagePct.."%\n"..M.effectText(s.effect)
end
local bonusKeys={{"attackPct","Ataque físico","%"},{"speedPct","Velocidade","%"},{"defensePct","Defesa física","%"},{"magicDefensePct","Defesa mágica","%"},{"slashPct","Resistência a corte","%"},{"piercePct","Resistência a perfuração","%"},{"bluntPct","Resistência a impacto","%"},{"health","Vida máxima",""},{"mana","Mana máxima",""},{"magicDamagePct","Dano mágico","%"}}
function M.bonusText(b)
    local parts={}
    for _,v in ipairs(bonusKeys) do if (b[v[1]] or 0)>0 then table.insert(parts,v[2].." +"..b[v[1]]..v[3]) end end
    for _,e in ipairs(b.effects or {}) do table.insert(parts,M.effectText(e)) end
    return table.concat(parts," | ")
end
function M.setText(id)
    local s=Sets[id]
    if not s then return "" end
    return s.name.."\n2 peças: "..M.bonusText(s.two).."\n4 peças (adicional): "..M.bonusText(s.four)
end
function M.statsText(p)
    if p.armorSlot then
        local res=p.resistances
        local text=M.category(p.category).." | "..p.rarity.."\nDefesa física: "..p.defense.." | Defesa mágica: "..p.magicDefense.."\nResistências (pontos): corte "..res.slash.." | perfuração "..res.pierce.." | impacto "..res.blunt.."\nPeso: "..p.weight.." kg | Força mínima: "..p.force
        if p.setId then text..="\n"..M.setText(p.setId) end
        if p.special then text..="\n"..M.specialText(p.special) end
        return text
    end
    local result=M.category(p.category).." | "..p.rarity.." | "..(damageLabels[p.damageType] or "—").."\n"
    result..="Dano: "..p.damage.." | Defesa: "..p.defense.." | Magia: "..p.magic.."\n"
    if p.damage>0 then result..="Dano: "..p.baseDamage.." base + "..p.damageBonus.." modelo + "..p.qualityDamageBonus.." qualidade\n" end
    if p.magic>0 then result..="Magia: "..p.baseMagic.." base + "..p.magicBonus.." modelo + "..p.qualityMagicBonus.." qualidade\n" end
    result..="Peso: "..p.weight.." kg | Força mínima: "..p.force.." | "..p.hands.." mão(s)"
    result..="\n"..M.attackText(p.attack)
    if p.special then result..="\n"..M.specialText(p.special) end
    if p.description and p.description~="" then result..="\n"..p.description end
    return result
end
function M.recipeText(recipe,materials,rules,recipeId)
    local parts={}
    local cost=0
    for id,qty in pairs(recipe.inputs) do table.insert(parts,qty.."x "..materials[id].name);cost+=qty*materials[id].price end
    table.sort(parts)
    local lines={M.category(recipe.category).." | "..recipe.weight.." kg | Força mínima: "..recipe.force.." | "..recipe.hands.." mão(s)",
        "Receita: "..table.concat(parts,", "), "Custo-base dos materiais: "..cost.." moedas (preços reais variam)"}
    if recipe.armorSlot then
        lines[1]=M.category(recipe.category).." | "..recipe.weight.." kg | Força mínima: "..recipe.force
        if recipe.setId then table.insert(lines,M.setText(recipe.setId)) end
    end
    for quality=1,3 do
        local s=rules.stats(recipe,quality,recipeId)
        if recipe.armorSlot then
            table.insert(lines,rules.rarity[quality]..": defesa física "..s.defense.." | mágica "..s.magicDefense.." | durabilidade "..s.maximum.." | resistências C/P/I "..s.resistances.slash.."/"..s.resistances.pierce.."/"..s.resistances.blunt..(s.special and ("\n"..M.specialText(s.special)) or ""))
        else
        table.insert(lines,rules.rarity[quality]..": dano "..s.damage.." | defesa "..s.defense.." | magia "..s.magic.." | durabilidade "..s.maximum.."\n"..M.attackText(s.attack)..(s.special and ("\n"..M.specialText(s.special)) or ""))
        end
    end
    if recipe.description then table.insert(lines,recipe.description) end
    return table.concat(lines,"\n")
end
function M.itemText(p)
    return M.statsText(p).."\nConservação: "..math.floor(p.current*100/p.maximum).."% ("..p.current.."/"..p.maximum..")"
end
return M
