--!nonstrict
-- Shared visual shell, distinct profile and service modes.
local Screen={}
local RS=game:GetService("ReplicatedStorage")
local remote=RS:WaitForChild("Economy")
local Registry=require(RS.Shared.world.WorldRegistry)
local Model=require(RS.Shared.economy.ViewModel)
local RunService=game:GetService("RunService")
local C={bg=Color3.fromRGB(24,24,24),card=Color3.fromRGB(39,39,39),button=Color3.fromRGB(64,64,64),selected=Color3.fromRGB(89,81,58),text=Color3.fromRGB(245,245,245),muted=Color3.fromRGB(170,170,170),buy=Color3.fromRGB(58,89,65)}
local function label(parent,text,height,size)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1;l.Size=UDim2.new(1,0,0,height)
    l.TextColor3=C.text;l.TextSize=size or 16;l.Font=Enum.Font.Gotham
    l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Text=text;l.Parent=parent
    return l
end
local function button(parent,text,enabled,fn,color)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,44);b.BackgroundColor3=color or C.button
    b.TextColor3=enabled and C.text or C.muted;b.TextSize=15;b.TextWrapped=true
    b.Font=Enum.Font.Gotham;b.Text=text;b.Parent=parent
    b.Active=enabled;b.AutoButtonColor=enabled;b.Selectable=enabled
    if enabled then b.Activated:Connect(fn) end
    return b
end
local function list(parent,padding)
    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder;l.Padding=UDim.new(0,padding);l.Parent=parent
    return l
end
local function place(obj,x,y,w,h)
    obj.Position=UDim2.new(x,0,0,y);obj.Size=UDim2.new(w,-8,0,h)
end
local function normalized(s)
    s=string.lower(s)
    for a,b in pairs({["á"]="a",["à"]="a",["ã"]="a",["â"]="a",["é"]="e",["ê"]="e",["í"]="i",["ó"]="o",["ô"]="o",["õ"]="o",["ú"]="u",["ç"]="c",["Á"]="a",["É"]="e",["Í"]="i",["Ó"]="o",["Ú"]="u",["Ç"]="c",["Ã"]="a",["Ô"]="o",["Ê"]="e",["Â"]="a",["À"]="a",["Õ"]="o"}) do s=string.gsub(s,a,b) end
    return s
end
function Screen.open(gui,root,mode)
    if gui:FindFirstChild("EconomyPanel") then return end
    local profileMode=mode=="profile"
    local panel=Instance.new("Frame")
    panel.Name="EconomyPanel";panel.Size=UDim2.fromScale(1,1);panel.BackgroundColor3=C.bg;panel.Parent=gui
    root.Visible=false
    local header=label(panel,profileMode and "Meu perfil" or "Serviços do estabelecimento",40,20)
    header.Position=UDim2.fromOffset(10,0);header.Size=UDim2.new(1,-20,0,40)
    local busy=false
    local response=nil
    local message=""
    local page=1
    local tab=nil
    local kind="all"
    local serial=0
    local request
    local function closePanel()
        if busy then return end
        root.Visible=true;panel:Destroy()
    end
    local close=button(panel,"Voltar",true,closePanel)
    place(close,0,42,.5,42);close.Position=UDim2.fromOffset(8,42)
    local refresh=button(panel,"Atualizar",true,function() request("view") end)
    place(refresh,.5,42,.5,42)
    local search=Instance.new("TextBox")
    search.Size=UDim2.new(1,-16,0,40);search.Position=UDim2.fromOffset(8,90)
    search.PlaceholderText="Buscar item, material ou categoria";search.Text=""
    search.ClearTextOnFocus=false;search.Font=Enum.Font.Gotham;search.TextSize=15
    search.BackgroundColor3=C.card;search.TextColor3=C.text;search.Parent=panel
    local scroll=Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0
    scroll.Position=UDim2.fromOffset(8,138);scroll.Size=UDim2.new(1,-16,1,-146)
    scroll.CanvasSize=UDim2.fromOffset(0,0);scroll.AutomaticCanvasSize=Enum.AutomaticSize.None
    scroll.ScrollingDirection=Enum.ScrollingDirection.Y;scroll.ScrollBarThickness=6
    scroll.VerticalScrollBarInset=Enum.ScrollBarInset.Always;scroll.Parent=panel
    local layout=list(scroll,7)
    local function resizeCanvas() scroll.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+10) end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeCanvas)
    local function top() scroll.CanvasPosition=Vector2.zero end
    local function render()
        if not panel.Parent then return end
        for _,child in ipairs(scroll:GetChildren()) do if child~=layout then child:Destroy() end end
        local order=0
        local function add(o) order+=1;o.LayoutOrder=order;return o end
        local function text(s,h,size) return add(label(scroll,s,h,size)) end
        local function action(row,parent,orderValue)
            local b=button(parent,row.title..(row.enabled and "" or " [indisponível]"),row.enabled and not busy,function() request("act",row.id) end)
            b.Size=UDim2.new(1,0,0,76)
            if orderValue then b.LayoutOrder=orderValue else add(b) end
            return b
        end
        if message~="" or busy then text(busy and "Consultando servidor..." or message,44) end
        local view=response and response.view
        if not view then
            text("Use Atualizar para carregar os dados. Se o erro continuar, confira o Output do Studio.",76)
            resizeCanvas();return
        end
        local p=view.profile
        text("Moedas: "..view.coins.." | Força: "..view.strength,38,18)
        if not profileMode then text(Registry.breadcrumb(view.location),50,14) end
        if view.budget~=nil and not profileMode then text("Orçamento do mercado: "..view.budget,32,14) end
        if view.job~="" then text("Produção: "..view.job.." | Atualize para receber",52,14) end
        local tabs=profileMode and Model.profileTabs(RunService:IsStudio()) or Model.serviceTabs(view)
        if #tabs==0 then text("Nenhum serviço disponível nesta localização. Entre na área interna correspondente.",76);resizeCanvas();return end
        if not table.find(tabs,tab) then tab=tabs[1];page=1 end
        local function choices(options,current,callback)
            local frame=Instance.new("Frame")
            frame.BackgroundTransparency=1;frame.Size=UDim2.new(1,0,0,math.ceil(#options/2)*44)
            frame.Parent=scroll;add(frame)
            local grid=Instance.new("UIGridLayout")
            grid.CellSize=UDim2.new(.5,-3,0,40);grid.CellPadding=UDim2.fromOffset(6,4)
            grid.FillDirectionMaxCells=2;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=frame
            for i,opt in ipairs(options) do
                local b=button(frame,opt.label,not busy,function() callback(opt.value);page=1;top();render() end,opt.value==current and C.selected or C.button)
                b.LayoutOrder=i
            end
        end
        local options={}
        for _,name in ipairs(tabs) do table.insert(options,{label=name,value=name}) end
        choices(options,tab,function(v) tab=v;kind="all" end)
        if not profileMode and view.shop then
            choices({{label="Todos",value="all"},{label="Matérias-primas",value="raw"},{label="Processados",value="processed"},{label="Armas e escudos",value="equipment"}},kind,function(v) kind=v end)
        end
        local query=normalized(search.Text)
        local function matches(s) return query=="" or string.find(normalized(s),query,1,true)~=nil end
        local entries={}
        local function entry(item) table.insert(entries,item) end
        local function matchesDetail(d) return matches(d.name.." "..Model.category(d.category).." "..(d.rarity or "")) end
        if profileMode and tab=="Status" then
            text(p.displayName.." (@"..p.username..")",48,21)
            text("Localização: "..Registry.breadcrumb(view.location),54)
            text("Força: "..view.strength.." | Patrimônio em moedas: "..view.coins,44)
            text("Materiais: "..p.materialUnits.." unidades | Equipamentos: "..p.equipmentCount.."/100 | Receitas: "..p.learnedCount,62)
            local main,off="Vazia","Vazia"
            for _,item in ipairs(p.equipment) do
                if item.uid==p.main then main=item.name.." / "..item.rarity;if item.hands==2 then off="Ocupada pela arma de duas mãos" end end
                if item.uid==p.off then off=item.name.." / "..item.rarity end
            end
            text("Mão principal: "..main,58);text("Mão secundária: "..off,58)
            text("Outros atributos de combate e progressão ainda não foram implementados.",62,14)
            resizeCanvas();return
        elseif profileMode and tab=="Inventário" then
            for _,m in ipairs(p.materials) do if matchesDetail(m) then entry({heading=m.name,detail=Model.category(m.category).." | "..(m.kind=="raw" and "Matéria-prima" or "Processado").." | Quantidade: "..m.quantity}) end end
        elseif profileMode and tab=="Equipamentos" then
            local actions={}
            for _,row in ipairs(view.actions) do
                if row.group=="Equipar" then
                    local uid=string.match(row.id,"^[^:]+:(.+)$")
                    if uid then actions[uid]=actions[uid] or {};table.insert(actions[uid],row) end
                end
            end
            for _,item in ipairs(p.equipment) do
                if matchesDetail(item) then entry({heading=item.name,detail=item.slot.." | "..Model.itemText(item),actions=actions[item.uid] or {}}) end
            end
        elseif profileMode and tab=="Maestria" then
            for _,s in ipairs(view.mastery) do if matches(s) then entry({heading=s,detail="Receita aprendida"}) end end
        elseif profileMode and tab=="Teste Studio" then
            for _,row in ipairs(view.actions) do if row.group=="Teste Studio" and matches(row.title) then entry({action=row}) end end
        elseif view.shop then
            for _,row in ipairs(view.actions) do
                if Model.matchesProduct(row,tab,kind) and matchesDetail(row.product) then
                    local product=row.product
                    local detail
                    if product.kind=="equipment" then detail=Model.itemText(product)
                    else detail=Model.category(product.category).." | Estoque: "..product.stock.." | Você possui: "..product.owned end
                    entry({heading=product.name,detail=detail,product=product,action=row})
                end
            end
        else
            for _,row in ipairs(view.actions) do if row.group==tab and matches(row.title) then entry({action=row}) end end
        end
        local pages=math.max(1,math.ceil(#entries/8));page=math.clamp(page,1,pages)
        text(tab.." | "..#entries.." resultados | Página "..page.."/"..pages,38,16)
        if #entries==0 then
            text(query~="" and "Nenhum resultado para esta busca." or (tab=="Fabricar" and "Aprenda uma receita na Guilda de Produtores." or "Nenhum item ou ação nesta categoria."),60)
        end
        local function pager()
            local frame=Instance.new("Frame");frame.BackgroundTransparency=1;frame.Size=UDim2.new(1,0,0,44);frame.Parent=scroll;add(frame)
            local prev=button(frame,"Anterior",page>1 and not busy,function() page-=1;top();render() end)
            place(prev,0,0,.5,42)
            local nextPage=button(frame,"Próxima",page<pages and not busy,function() page+=1;top();render() end)
            place(nextPage,.5,0,.5,42)
        end
        if pages>1 then pager() end
        for i=(page-1)*8+1,math.min(page*8,#entries) do
            local row=entries[i]
            if row.heading then
                local card=Instance.new("Frame");card.BackgroundColor3=C.card;card.Parent=scroll;add(card)
                local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8);pad.PaddingTop=UDim.new(0,6);pad.PaddingBottom=UDim.new(0,6);pad.Parent=card
                list(card,4)
                local heading=label(card,row.heading,34,18);heading.LayoutOrder=1
                local detail=label(card,row.detail,row.product and row.product.kind=="equipment" and 90 or row.actions and 100 or 48,14);detail.LayoutOrder=2
                local height=12+34+detail.Size.Y.Offset+4
                if row.product then
                    local prod=row.product
                    local price=label(card,prod.price.." moedas | "..prod.quantity.." unidade(s)",32,17);price.LayoutOrder=3
                    local b=button(card,(tab=="Comprar" and "Comprar" or "Vender").." "..prod.quantity.."x"..(row.action.enabled and "" or " — indisponível"),row.action.enabled and not busy,function() request("act",row.action.id) end,C.buy)
                    b.LayoutOrder=4;height+=32+44+8
                elseif row.actions then
                    for n,a in ipairs(row.actions) do action(a,card,2+n);height+=80 end
                end
                card.Size=UDim2.new(1,0,0,height)
            else action(row.action,scroll) end
        end
        if pages>1 then pager() end
        resizeCanvas()
    end
    request=function(actionName,id)
        if busy or not panel.Parent then return end
        busy=true;serial+=1;local generation=serial
        local token=response and response.token
        message="";render()
        task.delay(10,function()
            if not panel.Parent or serial~=generation or not busy then return end
            serial+=1;busy=false;response=nil;message="Sem resposta do servidor. Atualize.";render()
        end)
        task.spawn(function()
            local ok,result=pcall(function() return remote:InvokeServer(actionName,id,token) end)
            if not panel.Parent or serial~=generation then return end
            busy=false
            if ok and type(result)=="table" and type(result.view)=="table" and type(result.view.profile)=="table" then
                response=result;message=result.message or ""
            else
                response=nil;message=ok and type(result)=="table" and result.message or "Falha de comunicação. Confira o Output e atualize."
            end
            render()
        end)
    end
    search:GetPropertyChangedSignal("Text"):Connect(function() page=1;top();render() end)
    request("view")
end
return Screen
