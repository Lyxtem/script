local HttpService = game:GetService('HttpService')
local HttpRequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local Players = game:GetService('Players')

-- Configuración
local webhookURL = "https://ptb.discord.com/api/webhooks/1351745157170597920/wGPPiyfqwaIqcOcqgslQ4RRPMFl9jRrIMoHLkUeQIt9Ck4xKgDQHumbReBNo5ZqQmy5m" -- Cambia esto por la URL de tu webhook de Discord
local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')
local main = playerGui:WaitForChild('Main')
local fruitShop = main:WaitForChild('FruitShop')
local left = fruitShop:WaitForChild('Left')
local center = left:WaitForChild('Center')
local scrollingFrame = center:WaitForChild('ScrollingFrame')
local container = scrollingFrame:WaitForChild('Container')

local previousStock = {}

-- Función para obtener el stock actual de frutas
local function getCurrentStock()
    local stock = {}
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA('Frame') and child:FindFirstChild('Price') then
            local price = child.Price.Text
            stock[child.Name] = price
        end
    end
    return stock
end

-- Función para enviar el stock al webhook de Discord
local function sendToWebhook(stock)
    local message = "**Stock Actual de Frutas en Blox Fruits:**\n"
    for fruit, price in pairs(stock) do
        message = message .. string.format("**%s**: %s\n", fruit, price)
    end

    local payload = HttpService:JSONEncode({content = message})
    HttpRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = payload
    })
end

-- Función para detectar cambios en el stock
local function checkForChanges()
    while true do
        local currentStock = getCurrentStock()

        if HttpService:JSONEncode(currentStock) ~= HttpService:JSONEncode(previousStock) then
            sendToWebhook(currentStock)
            previousStock = currentStock
        end

        wait(300) -- Verifica cada 5 minutos
    end
end

-- Enviar stock inicial y empezar a monitorear cambios
previousStock = getCurrentStock()
sendToWebhook(previousStock)
checkForChanges()
