local logger = {}

logger.active = false

function logger.log(...)
    if logger.active then
        print(...)
    end
end

return logger