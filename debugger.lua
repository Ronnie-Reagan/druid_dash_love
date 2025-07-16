local debugger = {
    active = false -- default to false
}
function debugger.print(literal)
    if debugger.active then

        print(tostring(literal))
    end
end

return debugger
