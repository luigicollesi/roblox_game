--!nonstrict
-- Pure presentation helpers: no pricing or authorization logic.
local M={}
local aliases={wood="Madeira",metal="Metal",stone="Pedra / cristal",leather="Couro",sword="Espada de uma mão",greatsword="Espada de duas mãos",shortkatana="Katana curta",longkatana="Katana longa",knife="Faca",dagger="Adaga",smallshield="Escudo pequeno",largeshield="Escudo grande",staff="Cajado",wand="Varinha"}
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
function M.itemText(p)
    return M.category(p.category).." | "..p.rarity.." | Conservação: "..math.floor(p.current*100/p.maximum).."% ("..p.current.."/"..p.maximum..")\nDano: "..p.damage.." | Defesa: "..p.defense.." | Magia: "..p.magic.." | Peso: "..p.weight.." kg | Força mínima: "..p.force.." | "..p.hands.." mão(s)"
end
return M
