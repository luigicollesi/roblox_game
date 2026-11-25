--!nonstrict
-- Neutral test UI, isolated from navigation; no authoritative client calculations.
local Screen={}
local Players=game:GetService("Players")
local remote=game:GetService("ReplicatedStorage"):WaitForChild("Economy")
local function label(parent,text,height)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,height or 44)
    l.BackgroundTransparency=1
    l.TextColor3=Color3.fromRGB(240,240,240)
    l.TextSize=16;l.Font=Enum.Font.Gotham;l.TextWrapped=true
    l.TextXAlignment=Enum.TextXAlignment.Left;l.Text=text;l.Parent=parent
    return l
end
local function button(parent,text,enabled,fn)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,52);b.BackgroundColor3=Color3.fromRGB(49,49,49)
    b.TextColor3=enabled and Color3.fromRGB(245,245,245) or Color3.fromRGB(145,145,145)
    b.TextSize=15;b.TextWrapped=true;b.Font=Enum.Font.Gotham;b.Text=text;b.Parent=parent
    b.Active=enabled;b.AutoButtonColor=enabled;b.Selectable=enabled
    if enabled then b.Activated:Connect(fn) end
    return b
end
function Screen.open(gui,root)
    if gui:FindFirstChild("EconomyPanel") then return end
    local panel=Instance.new("Frame")
    panel.Name="EconomyPanel";panel.Size=UDim2.fromScale(1,1)
    panel.BackgroundColor3=Color3.fromRGB(25,25,25);panel.Parent=gui
    root.Visible=false
    local header=label(panel,"Economia / Inventário",40)
    header.Position=UDim2.fromOffset(10,0);header.Size=UDim2.new(1,-20,0,40)
    local close=button(panel,"Voltar à localização",true,function() root.Visible=true;panel:Destroy() end)
    close.Position=UDim2.new(0,10,0,42);close.Size=UDim2.new(1,-20,0,44)
    local refresh=button(panel,"Atualizar dados",true,function() end)
    refresh.Position=UDim2.new(0,10,0,90);refresh.Size=UDim2.new(1,-20,0,44)
    local search=Instance.new("TextBox")
    search.Size=UDim2.new(1,-20,0,42);search.Position=UDim2.fromOffset(10,138)
    search.PlaceholderText="Filtrar por nome, categoria ou material";search.Text=""
    search.ClearTextOnFocus=false;search.Font=Enum.Font.Gotham;search.TextSize=15
    search.BackgroundColor3=Color3.fromRGB(45,45,45);search.TextColor3=Color3.new(1,1,1)
    search.Parent=panel
    local scroll=Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0
    scroll.Position=UDim2.fromOffset(10,188);scroll.Size=UDim2.new(1,-20,1,-188)
    scroll.CanvasSize=UDim2.fromOffset(0,0);scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.ScrollingDirection=Enum.ScrollingDirection.Y;scroll.ScrollBarThickness=6;scroll.Parent=panel
    local body=Instance.new("Frame")
    body.BackgroundTransparency=1;body.Size=UDim2.new(1,-10,0,0)
    body.AutomaticSize=Enum.AutomaticSize.Y;body.Parent=scroll
    local layout=Instance.new("UIListLayout")
    layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Padding=UDim.new(0,6);layout.Parent=body
    local busy=false
    local response=nil
    local message=""
    local page=1
    local group="Ações"
    local serial=0
    local request
    local function render()
        if not panel.Parent then return end
        for _,child in ipairs(body:GetChildren()) do if child~=layout then child:Destroy() end end
        local order=0
        local function add(obj) order+=1;obj.LayoutOrder=order end
        add(label(body,message~="" and message or (busy and "Consultando servidor..." or ""),44))
        local view=response and response.view
        if not view then return end
        add(label(body,"Moedas: "..view.coins.." | Força: "..view.strength,42))
        if view.budget~=nil then add(label(body,"Orçamento do mercado: "..view.budget,34)) end
        if view.job~="" then add(label(body,"Produção: "..view.job.." (atualize para receber)",52)) end
        local tabs={"Ações","Materiais","Equipamentos","Maestria"}
        local available={}
        for _,row in ipairs(view.actions) do
            if not available[row.group] then available[row.group]=true;table.insert(tabs,row.group) end
        end
        if not table.find(tabs,group) then group="Ações";page=1 end
        local tabbar=Instance.new("Frame")
        tabbar.Size=UDim2.new(1,0,0,44);tabbar.BackgroundTransparency=1;tabbar.Parent=body;add(tabbar)
        local tabsScroll=Instance.new("ScrollingFrame")
        tabsScroll.Size=UDim2.fromScale(1,1);tabsScroll.BackgroundTransparency=1;tabsScroll.ScrollBarThickness=4
        tabsScroll.ScrollingDirection=Enum.ScrollingDirection.X;tabsScroll.CanvasSize=UDim2.fromOffset(0,0)
        tabsScroll.AutomaticCanvasSize=Enum.AutomaticSize.X;tabsScroll.Parent=tabbar
        local h=Instance.new("UIListLayout");h.FillDirection=Enum.FillDirection.Horizontal;h.Padding=UDim.new(0,6);h.Parent=tabsScroll
        for _,name in ipairs(tabs) do
            local b=button(tabsScroll,(group==name and "> " or "")..name,true,function() group=name;page=1;render() end)
            b.Size=UDim2.fromOffset(150,38)
        end
        local query=string.lower(search.Text)
        local function matches(text) return query=="" or string.find(string.lower(text),query,1,true)~=nil end
        local entries={}
        if group=="Materiais" or group=="Equipamentos" or group=="Maestria" then
            local list=group=="Materiais" and view.materials or group=="Equipamentos" and view.items or view.mastery
            for _,text in ipairs(list) do if matches(text) then table.insert(entries,{title=text}) end end
        else
            for _,row in ipairs(view.actions) do
                if (group=="Ações" or row.group==group) and matches(row.title.." "..row.group) then table.insert(entries,row) end
            end
        end
        local pages=math.max(1,math.ceil(#entries/12));page=math.clamp(page,1,pages)
        add(label(body,group.." | "..#entries.." resultados | página "..page.."/"..pages,36))
        add(button(body,"Página anterior",page>1,function() page-=1;render() end))
        for i=(page-1)*12+1,math.min(page*12,#entries) do
            local row=entries[i]
            if row.id then
                add(button(body,row.title..(row.enabled and "" or " [indisponível]"),row.enabled and not busy,function()
                    request("act",row.id)
                end))
            else
                add(label(body,row.title,60))
            end
        end
        add(button(body,"Próxima página",page<pages,function() page+=1;render() end))
    end
    request=function(action,id)
        if busy or not panel.Parent then return end
        busy=true;serial+=1;local generation=serial
        local token=response and response.token
        message="Consultando servidor...";render()
        task.delay(10,function()
            if not panel.Parent or generation~=serial or not busy then return end
            serial+=1;busy=false;response=nil;message="Sem resposta. Atualize os dados.";render()
        end)
        task.spawn(function()
            local ok,result=pcall(function() return remote:InvokeServer(action,id,token) end)
            if not panel.Parent or serial~=generation then return end
            busy=false
            if ok and type(result)=="table" and type(result.view)=="table" then
                response=result;message=result.message or ""
            else
                response=nil;message=ok and type(result)=="table" and result.message or "Falha de comunicação. Atualize."
            end
            render()
        end)
    end
    refresh.Activated:Connect(function() request("view") end)
    search:GetPropertyChangedSignal("Text"):Connect(function() page=1;render() end)
    request("view")
end
return Screen
