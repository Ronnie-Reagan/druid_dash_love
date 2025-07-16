local helpers = {}

function helpers.is_value_in_set(value, set)
    for _, element in ipairs(set) do
        if value == element then
            return true
        end
    end
    return false
end

function helpers.random_element_from(collection)
    local collection_lenght = #collection
    local fetch_index = math.random(1, collection_lenght)
    return collection[fetch_index]
end

return helpers
