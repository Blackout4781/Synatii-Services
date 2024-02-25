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
        local service = rawget(self, p)

        if not service then
            if p == 'VirtualInputManager' and vim then
                service = vim
            else
                service = game:GetService(p)
                
                if p == 'VirtualInputManager' and service then
                    local constantValue = getServerConstant and getServerConstant('VirtualInputManager') or "DefaultConstant"
                    service.Name = constantValue
                end
            end

            rawset(self, p, service)
        end

        return service
    end,
})

return Services
