keys = Config.Keys
local iscrafting = false
local blipsadded = false

Citizen.CreateThread(function()
    UIPrompt.initialize()

    while true do
        Citizen.Wait(1)
        -- Check for craftable object starters
        local player = PlayerPedId()
        local Coords = GetEntityCoords(player)
        
        if  Config.CraftingPropsEnabled then
            local propjobcheck = CheckJob(Config.CampfireJobLock)
            for k, v in pairs(Config.CraftingProps) do
                if propjobcheck and iscrafting == false and uiopen == false then
                    local campfire = DoesObjectOfTypeExistAtCoords(Coords.x, Coords.y, Coords.z, Config.Distances.campfire, GetHashKey(v), 0) --This is resource intensive, but not sure there is a way around this.
                    if campfire then
                        UIPrompt.activate('Campfire')
    
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, CraftPrompt) then
                            VUI.OpenUI({ id = 'campfires' })
                        end
                    end 
                end
            end 
        end

        -- Check for craftable location starters
        local blipcount = 0
        for k, loc in ipairs(Config.Locations) do
            local jobcheck = CheckJob(loc.Job)
            if jobcheck and uiopen == false then
                if loc.Blip and blipsadded == false then
                    blipcount = blipcount + 1
                    Blips.addBlipForCoords(k, loc.name, loc.Blip.Hash, loc.x, loc.y, loc.z)
                end                
                
                local dist = getCoordDistance(loc, Coords)
                if Config.Distances.locations > dist then
                    UIPrompt.activate(loc.name)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, CraftPrompt) then
                        VUI.OpenUI(loc)
                    end
                end 
            end
        end

        if blipcount > 0 then
            blipsadded = true
        end

        -- Hide the native rest prompts while the crafting menu is open
        if (uiopen == true or iscrafting == true) then
            Citizen.InvokeNative(0xF1622CE88A1946FB)
        end
    end
end)

RegisterNetEvent("vorp:crafting")
AddEventHandler("vorp:crafting", function(animation)
    local playerPed = PlayerPedId()
    iscrafting = true

    VUI.Animate()

    if not animation then
        animation = "craft"
    end

    Animations.playAnimation(playerPed, animation)
    exports['progressBars']:startUI(Config.CraftTime, _U('Crafting'))

    Wait(Config.CraftTime)

    Animations.endAnimation(animation)

    TriggerEvent("vorp:TipRight", _U('FinishedCrafting'), 4000)
    VUI.Refocus()

    iscrafting = false
end)

RegisterNetEvent("vorp:UpdateRecipes")
AddEventHandler("vorp:UpdateRecipes", function(recipes)
    Config.Crafting = recipes
end)
