Config = {}

Config.UseKzCart = false -- Next release

Config.MoneyforPlayer = 0.5
--Config.MoneyforBusiness = 0.25 -- Next release 
Config.Timetocraft = 1000

Config.Run = {
[1] = {
        id = "1",
        label = 'Féraille > Renforcé',
        desc = 'Munitions d\'armes',
        harvest = 'metalscrap',
        processing = 'metalscraprenforced',
        blips = "blip_shop_blacksmith",
        craft = {
            [1] = {item = "ammo_repeater",  forPlayer = 0.2, forBusiness = 0.1},
            [2] = {item = "ammo_revolver",  forPlayer = 0.1, forBusiness = 0.05},
            [3] = {item = "ammo_rifle",     forPlayer = 0.2, forBusiness = 0.1},
            [4] = {item = "ammo_pistol",    forPlayer = 0.1, forBusiness = 0.05},
            [5] = {item = "ammo_shotgun",   forPlayer = 0.2, forBusiness = 0.1},
        }
    },
[2] = {
        id = "2",
        label = 'Verre > Bouteille',
        desc = 'Boissons',
        harvest = 'glass',
        processing = 'bottle',
        blips = "blip_summer_cow",
        craft = {
            [1] = {item = "watter_bottle",  forPlayer = 0.5, forBusiness = 0.02},
            [2] = {item = "coffee",         forPlayer = 0.4, forBusiness = 0.01},
        }
    },
}


