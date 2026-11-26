--!nonstrict
-- Pure presentation helpers: no pricing or authorization logic.
local M={}
local aliases={wood="Madeira",metal="Metal",stone="Pedra / cristal",leather="Couro",sword="Espada de uma mão",greatsword="Espada de duas mãos",shortkatana="Katana curta",longkatana="Katana longa",knife="Faca",dagger="Adaga",smallshield="Escudo pequeno",largeshield="Escudo grande",staff="Cajado",wand="Varinha",axe="Machado de uma mão",greataxe="Machado de duas mãos",mace="Maça",warhammer="Martelo de guerra",spear="Lança",halberd="Alabarda"}
function M.category(id) return aliases[id] or id end
function M.profileTabs(studio)
    local tabs={"Status","Inventário","Equipamentos","Maestria"}
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
    return p.side==(tab=="Comprar" and "buy" or "sell") and (kind=="all" or p.kind==kind)
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
function M.statsText(p)
    local result=M.category(p.category).." | "..p.rarity.." | "..(damageLabels[p.damageType] or "—").."\n"
    result..="Dano: "..p.damage.." | Defesa: "..p.defense.." | Magia: "..p.magic.."\n"
    if p.damage>0 then result..="Dano: "..p.baseDamage.." base + "..p.damageBonus.." modelo + "..p.qualityDamageBonus.." qualidade\n" end
    if p.magic>0 then result..="Magia: "..p.baseMagic.." base + "..p.magicBonus.." modelo + "..p.qualityMagicBonus.." qualidade\n" end
    result..="Peso: "..p.weight.." kg | Força mínima: "..p.force.." | "..p.hands.." mão(s)"
    if p.description and p.description~="" then result..="\n"..p.description end
    return result
end
function M.itemText(p)
    return M.statsText(p).."\nConservação: "..math.floor(p.current*100/p.maximum).."% ("..p.current.."/"..p.maximum..")"
end
return M
