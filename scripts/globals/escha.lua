-----------------------------------
-- Escha helpers
-----------------------------------

xi = xi or {}
xi.escha = xi.escha or {}

xi.escha.defaultSiltCap = 50000
xi.escha.defaultBeadCap = 5000

xi.escha.urnSiltCap = 500000
xi.escha.urnBeadCap = 10000

xi.escha.cellarSiltCap = 1000000
xi.escha.cellarBeadCap = 25000

xi.escha.nefSiltCap = 1000000000
xi.escha.nefBeadCap = 50000

xi.escha.getSiltCap = function(player)
    if player:hasKeyItem(xi.ki.ESCHAN_NEF) then
        return xi.escha.nefSiltCap
    elseif player:hasKeyItem(xi.ki.ESCHAN_CELLAR) then
        return xi.escha.cellarSiltCap
    elseif player:hasKeyItem(xi.ki.ESCHAN_URN) then
        return xi.escha.urnSiltCap
    end

    return xi.escha.defaultSiltCap
end

xi.escha.getBeadCap = function(player)
    if player:hasKeyItem(xi.ki.ESCHAN_NEF) then
        return xi.escha.nefBeadCap
    elseif player:hasKeyItem(xi.ki.ESCHAN_CELLAR) then
        return xi.escha.cellarBeadCap
    elseif player:hasKeyItem(xi.ki.ESCHAN_URN) then
        return xi.escha.urnBeadCap
    end

    return xi.escha.defaultBeadCap
end

xi.escha.getCurrencyCap = function(player, currencyName)
    if currencyName == 'escha_silt' then
        return xi.escha.getSiltCap(player)
    elseif currencyName == 'escha_beads' then
        return xi.escha.getBeadCap(player)
    end

    return nil
end
