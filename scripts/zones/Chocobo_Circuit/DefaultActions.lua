-- local ID = zones[xi.zone.CHOCOBO_CIRCUIT]

return {
    ['Adrian']             = { event = 1 },
    ['Amaduralle']         = { event = 241 },
    ['Channon']            = { event = 342 },
    ['Chaquoillons']       = { event = 238 },
    ['Curtis']             = { event = 211 },
    ['Cyphaireau']         = { event = 240 },
    ['Cyril']              = { event = 0 },
    ['Delaulne']           = { event = 340 },
    ['Faboise']            = { event = 239 },
    ['Gustavo']            = { event = 226 },
    ['Joilevin']           = { event = 236 },
    ['Jolande']            = { event = 346 },
    ['Khatri']             = { event = 339 },
    ['Lisette']            = { event = 348 },
    ['Luca']               = { event = 338 },
    ['Magali']             = { event = 350 },
    ['Maxine']             = { event = 352 },
    ['Mediverchanne']      = { event = 242 },
    ['Mercedes']           = { event = 343 },
    ['Ove']                = { event = 353 },
    ['Pollante']           = { event = 237 },
    ['Raquel']             = { event = 354 },
    ['Rodrigo']            = { event = 347 },
    ['Russel']             = { event = 227 },
    ['Synergy_Engineer'] = function(player, npc)
        xi.synergy.engineerOnTrigger(player, npc, 11001)
    end,

    ['onEventFinish'] =
    {
        [11001] = function(player, csid, option, npc)
            xi.synergy.engineerOnEventFinish(player, csid, option, npc)
        end,
    },

    ['onEventUpdate'] =
    {
        [11001] = function(player, csid, option, npc)
            xi.synergy.engineerOnEventUpdate(player, csid, option, npc)
        end,
    },
    ['Synergy_Enthusiast'] = { event = 12001 },
    ['Timothy']            = { event = 349 },
    ['Vaihilique']         = { event = 243 },
    ['Valerio']            = { event = 351 },
}
