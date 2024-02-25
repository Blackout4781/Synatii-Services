local Services = {}
local vim = getvirtualinputmanager and getvirtualinputmanager()

function Services:Get(...)
    local allServices = {}

    for _, service in ipairs{...} do
        table.insert(allServices, self[service])
    end

    return unpack(allServices)
end

setmetatable(Services, {
    __index = function(self, p)
        if p == 'VirtualInputManager' and vim then
            return vim
        end

        local service = game:GetService(p)
        if p == 'VirtualInputManager' and service then
            -- Assuming a default value if getServerConstant is not defined
            local constantValue = getServerConstant and getServerConstant('VirtualInputManager') or "DefaultConstant"
            service.Name = constantValue
        end

        rawset(self, p, service)
        return rawget(self, p)
    end,
})

return Services
