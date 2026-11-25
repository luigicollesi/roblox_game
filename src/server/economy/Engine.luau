--!nonstrict
-- Session economy. All mutations are synchronous; no callbacks yield.
local Engine = {}
local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)
    return keys
end
local function copy(t)
    local result = {}
    for k,v in pairs(t) do result[k] = v end
    return result
end
function Engine.new(C, R, clock, random)
    local E = { stock = {}, marketItems = {}, budget = 100000, revision = 0, profiles = {}, serial = 0 }
    local function touch(p) p.revision += 1 end
    local function marketTouch() E.revision += 1 end
    local function target(id) return C.materials[id].raw and 120 or 60 end
    for id in pairs(C.materials) do E.stock[id] = target(id) end
    local function newItem(id, rarity)
        E.serial += 1
        local max = math.floor(C.recipes[id].durability * R.durabilityPct[rarity] / 100)
        return {uid = "item_" .. E.serial, recipe = id, rarity = rarity, current = max, maximum = max}
    end
    for _,id in ipairs(sortedKeys(C.recipes)) do
        for rarity = 1, 2 do
            local item = newItem(id, rarity)
            E.marketItems[item.uid] = item
        end
    end
    function E.profile(userId)
        if not E.profiles[userId] then
            E.profiles[userId] = {coins = 1200, strength = 10, materials = {}, items = {}, mastery = {}, rentals = {}, job = nil, revision = 0, main = nil, off = nil}
        end
        return E.profiles[userId]
    end
    local function materialPrice(id, stock)
        return R.stockPrice(C.materials[id].price, stock or E.stock[id], target(id))
    end
    local function sumCost(inputs)
        local cost = 0
        for id,q in pairs(inputs) do cost += materialPrice(id) * q end
        return cost
    end
    local function marketCount(recipe, rarity)
        local count = 0
        for _,item in pairs(E.marketItems) do
            if item.recipe == recipe and item.rarity == rarity then count += 1 end
        end
        return count
    end
    local function itemPrice(item, count)
        local value = R.newValue(sumCost(C.recipes[item.recipe].inputs), item.rarity, count)
        return R.used(value, item.current, item.maximum)
    end
    local function has(p, inputs)
        for id,q in pairs(inputs) do if (p.materials[id] or 0) < q then return false end end
        return true
    end
    local function consume(p, inputs)
        for id,q in pairs(inputs) do p.materials[id] -= q end
    end
    local function grant(p, id, q) p.materials[id] = (p.materials[id] or 0) + q end
    local function inventoryCount(p)
        local count = 0
        for _ in pairs(p.items) do count += 1 end
        return count
    end
    local function scaled(inputs, qty)
        local result = {}
        for id,q in pairs(inputs) do result[id] = q * qty end
        return result
    end
    local function materialsText(inputs)
        local parts = {}
        for _,id in ipairs(sortedKeys(inputs)) do table.insert(parts, inputs[id] .. "x " .. C.materials[id].name) end
        return table.concat(parts, ", ")
    end
    local function itemName(item)
        return C.recipes[item.recipe].name .. " / " .. R.rarity[item.rarity] .. " / " .. math.floor(item.current * 100 / item.maximum) .. "%"
    end
    local function matchShop(shop, recipe)
        local shield = recipe.category == "smallshield" or recipe.category == "largeshield"
        local magic = recipe.category == "staff" or recipe.category == "wand"
        return shop.equipment == "all" or (shop.equipment == "shield" and shield)
            or (shop.equipment == "magic" and magic) or (shop.equipment == "physical" and not shield and not magic)
    end
    local function isRented(p, station, now) return (p.rentals[station] or 0) > now end
    -- Jobs are reserved upfront and finalized once; a move or rental expiration cannot cancel them.
    function E.finish(p)
        local job = p.job
        if not job or clock() < job.ends then return end
        p.job = nil
        if job.kind == "process" then
            grant(p, job.id, job.qty)
        else
            for _ = 1, job.qty do
                local m = p.mastery[job.id]
                local rarity = R.roll(m, random(1, 100))
                local item = newItem(job.id, rarity)
                p.items[item.uid] = item
                p.mastery[job.id] = math.min(100, m + 5)
            end
        end
        touch(p)
    end
    function E.view(p, location, studio)
        E.finish(p)
        local now = clock()
        local rows, handlers = {}, {}
        local function add(id, group, title, enabled, fn)
            assert(not handlers[id], "Duplicate action " .. id)
            table.insert(rows, {id=id, group=group, title=title, enabled=enabled})
            handlers[id] = {enabled=enabled, apply=fn, title=title}
        end
        local shop = C.shops[location]
        if shop then
            for _,id in ipairs(sortedKeys(C.materials)) do
                local def = C.materials[id]
                if shop.material == "all" or shop.material == def.category then
                    local stock = E.stock[id]
                    -- Marginal pricing: the reverse transaction cannot create money.
                    local bid = materialPrice(id, stock)
                    local askBase = materialPrice(id, math.max(0, stock - 1))
                    local ask = shop.market and askBase or R.retail(askBase)
                    add("buy:"..id, def.raw and "Brutos" or "Processados", "Comprar "..def.name.." | "..ask.." moedas | estoque "..stock,
                        stock>0 and p.coins>=ask, function()
                        p.coins -= ask; E.budget += ask; E.stock[id] -= 1; grant(p,id,1); marketTouch()
                    end)
                    if shop.market and (p.materials[id] or 0)>0 then
                        add("sell:"..id,"Vender materiais","Vender "..def.name.." | "..bid.." moedas | possui "..p.materials[id],
                            E.budget>=bid and stock<target(id)*3, function()
                            consume(p,{[id]=1}); p.coins += bid; E.budget -= bid; E.stock[id] += 1; marketTouch()
                        end)
                    end
                end
            end
            for _,uid in ipairs(sortedKeys(E.marketItems)) do
                local item = E.marketItems[uid]
                if matchShop(shop,C.recipes[item.recipe]) then
                    local base = itemPrice(item, marketCount(item.recipe,item.rarity)-1)
                    local ask = shop.market and base or R.retail(base)
                    add("buyitem:"..uid,"Comprar equipamentos","Comprar "..itemName(item).." | "..ask.." moedas",
                        p.coins>=ask and inventoryCount(p)+(p.job and p.job.kind=="craft" and p.job.qty or 0)<100, function()
                        p.coins -= ask; E.budget += ask; E.marketItems[uid] = nil; p.items[uid] = item; marketTouch()
                    end)
                end
            end
            if shop.market then
                for _,uid in ipairs(sortedKeys(p.items)) do
                    local item = p.items[uid]
                    local count = marketCount(item.recipe,item.rarity)
                    local price = itemPrice(item,count)
                    add("sellitem:"..uid,"Vender equipamentos","Vender "..itemName(item).." | "..price.." moedas",
                        count<12 and E.budget>=price and p.main~=uid and p.off~=uid, function()
                        p.items[uid]=nil; E.marketItems[uid]=item; p.coins+=price; E.budget-=price; marketTouch()
                    end)
                end
            end
        end
        if location == C.learnLocation then
            for _,id in ipairs(sortedKeys(C.recipes)) do
                local recipe = C.recipes[id]
                if p.mastery[id] == nil then
                    local fee = R.learnCost(recipe,C.materials)
                    add("learn:"..id,"Aprender receitas",recipe.name.." | "..fee.." moedas",p.coins>=fee,function()
                        p.coins-=fee; p.mastery[id]=0
                    end)
                end
            end
        end
        for _,id in ipairs(sortedKeys(C.stations)) do
            local station = C.stations[id]
            if station.location == location then
                local rented = isRented(p,id,now)
                add("rent:"..id,"Instalações",station.name.." | "..(rented and ("ativa por "..math.ceil(p.rentals[id]-now).."s") or (station.rent.." moedas / 300s")),
                    not rented and p.coins>=station.rent,function() p.coins-=station.rent; p.rentals[id]=clock()+300 end)
                for _,output in ipairs(sortedKeys(C.processing)) do
                    local process = C.processing[output]
                    if process.station == id then
                        for _,qty in ipairs({1,5}) do
                            local inputs=scaled(process.inputs,qty)
                            add("process:"..output..":"..qty,"Processar",qty.."x "..C.materials[output].name.." | "..materialsText(inputs).." | "..process.seconds*qty.."s",
                                rented and not p.job and has(p,inputs),function()
                                consume(p,inputs); p.job={kind="process",id=output,qty=qty,ends=clock()+process.seconds*qty}
                            end)
                        end
                    end
                end
                for _,recipeId in ipairs(sortedKeys(C.recipes)) do
                    local recipe=C.recipes[recipeId]
                    local mastery=p.mastery[recipeId]
                    if recipe.station==id and mastery~=nil then
                        local chances=R.chances(mastery)
                        for _,qty in ipairs({1,5}) do
                            local inputs=scaled(recipe.inputs,qty)
                            add("craft:"..recipeId..":"..qty,"Fabricar",qty.."x "..recipe.name.." | "..materialsText(inputs).." | M"..mastery.." | "..table.concat(chances,"/").."% inicial | "..recipe.seconds*qty.."s",
                                rented and not p.job and has(p,inputs) and inventoryCount(p)+qty<=100,function()
                                consume(p,inputs); p.job={kind="craft",id=recipeId,qty=qty,ends=clock()+recipe.seconds*qty}
                            end)
                        end
                    end
                end
                for _,uid in ipairs(sortedKeys(p.items)) do
                    local item=p.items[uid]
                    local recipe=C.recipes[item.recipe]
                    if recipe.station==id and item.current<item.maximum then
                        local inputs={}
                        for m,q in pairs(recipe.repair) do inputs[m]=R.repairUnits(q,item.current,item.maximum) end
                        local cost=sumCost(inputs)
                        local fee=R.serviceFee(cost)
                        local supply=true
                        local fullCost=0
                        for m,q in pairs(inputs) do
                            if E.stock[m]<q then supply=false end
                            for i=1,q do fullCost+=materialPrice(m,math.max(0,E.stock[m]-i)) end
                        end
                        local fullFee=R.serviceFee(fullCost)
                        local desc=itemName(item).." | "..materialsText(inputs)
                        add("repair:"..uid,"Reparar","Pessoal: "..desc,rented and has(p,inputs),function()
                            consume(p,inputs); item.current=item.maximum
                        end)
                        add("service:"..uid,"Reparar","Serviço: "..desc.." + "..fee.." moedas",has(p,inputs) and p.coins>=fee,function()
                            consume(p,inputs);p.coins-=fee;item.current=item.maximum
                        end)
                        add("fullrepair:"..uid,"Reparar","Completo: "..desc.." | "..(fullCost+fullFee).." moedas",supply and p.coins>=fullCost+fullFee,function()
                            for m,q in pairs(inputs) do E.stock[m]-=q end
                            p.coins-=fullCost+fullFee;E.budget+=fullCost;item.current=item.maximum;marketTouch()
                        end)
                    end
                end
            end
        end
        if location==C.trainingLocation then
            add("train","Treinar","Treinar força (+1) | 10 moedas",p.coins>=10 and p.strength<100,function() p.coins-=10;p.strength+=1 end)
        end
        local materials={}
        for _,id in ipairs(sortedKeys(p.materials)) do
            if p.materials[id]>0 then table.insert(materials,C.materials[id].name.." x"..p.materials[id]) end
        end
        local items={}
        for _,uid in ipairs(sortedKeys(p.items)) do
            local item=p.items[uid]
            local r=C.recipes[item.recipe]
            local quality=({1,1.15,1.35})[item.rarity]
            local defense=({1,1.1,1.25})[item.rarity]
            local text=itemName(item).." | "..uid.." | força "..r.force.." | "..r.weight.."kg | dano "..math.floor(r.power*quality).." | defesa "..math.floor(r.defense*defense).." | magia "..math.floor(r.magic*quality)
            if p.main==uid then text..=" | Principal" end
            if p.off==uid then text..=" | Secundária" end
            table.insert(items,text)
            local shield=r.category=="smallshield" or r.category=="largeshield"
            local valid=p.strength>=r.force and item.current>0
            if not shield then
                add("main:"..uid,"Equipar","Principal: "..itemName(item),valid and p.main~=uid,function()
                    if p.off==uid or r.hands==2 then p.off=nil end
                    p.main=uid
                end)
            end
            local mainRecipe=p.main and C.recipes[p.items[p.main].recipe]
            if r.hands==1 then
                add("off:"..uid,"Equipar","Secundária: "..itemName(item),valid and p.off~=uid and p.main~=uid and (not mainRecipe or mainRecipe.hands==1),function() p.off=uid end)
            end
            if p.main==uid or p.off==uid then
                add("unequip:"..uid,"Equipar","Desequipar "..itemName(item),true,function()
                    if p.main==uid then p.main=nil end
                    if p.off==uid then p.off=nil end
                end)
            end
            -- Studio only; never available on published servers. No direct monetary rewards.
            if studio and item.current>0 then
                add("wear:"..uid,"Teste Studio","Simular desgaste: "..itemName(item),true,function()
                    item.current=math.max(0,item.current-math.ceil(item.maximum/4))
                    if item.current==0 then if p.main==uid then p.main=nil end;if p.off==uid then p.off=nil end end
                end)
            end
        end
        local mastery={}
        for _,id in ipairs(sortedKeys(p.mastery)) do table.insert(mastery,C.recipes[id].name.." | "..p.mastery[id].."/100") end
        return {coins=p.coins,strength=p.strength,materials=materials,items=items,mastery=mastery,actions=rows,
            revision=p.revision,marketRevision=E.revision,location=location,
            job=p.job and (p.job.kind.." | "..p.job.id.." x"..p.job.qty.." | "..math.max(0,math.ceil(p.job.ends-now)).."s") or "",
            budget=shop and shop.market and E.budget or nil},handlers
    end
    function E.execute(p, location, studio, id, revision, marketRevision, quotedTitle)
        local view,handlers=E.view(p,location,studio)
        if revision~=view.revision or marketRevision~=view.marketRevision then return false,"Estado mudou. Confira os preços e tente novamente." end
        local action=handlers[id]
        if not action or not action.enabled or action.title~=quotedTitle then return false,"Ação indisponível ou preço alterado." end
        action.apply()
        touch(p)
        return true,"Operação concluída."
    end
    return E
end
return Engine
