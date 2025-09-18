----------------------------------------------------------
--  
--   All config changes should be followed by full reboot!
--
----------------------------------------------------------

-- Time (in seconds) between aspect balancing cycles, only triggers after a full cycle of all aspects being found at or above target levels with no crafts necessary
CycleSleep = 60

-- Time (in seconds) between re-attempts at balancing aspects while the smelters are busy
RetrySleep = 10

-- Targets counts of aspects to maintain in the system at all times, should be several multiples of the expected usage in a craft, possibly hundreds of times the expected usage of high-usage aspects such as primals
AspectTargets = {
    Aer=1024,
    Terra=1024,
    Ignis=1024,
    Aqua=1024,
    Ordo=1024,
    Perditio=1024,
    Praecantatio=1024,
    Vitreus=128,
    Permutatio=256,
    Cognitio=128,
    Lucrum=128,
    Machina=128,
    Auram=1024,
    Potentia=1024,
    Electrum=128,
    Instrumentum=128,
    Sensus=128,
    Lux=2048,
    Vitium=128,
    Vinculum=128,
    Herba=128,
    Victus=128,
    Arbor=128,
    Fames=128,
    Spiritus=1024,
    Vacuos=1024,
    Metallum=1024,
    Corpus=1024,
    Humanus=1024,
    Alienis=4096,
    Iter=256,
    Caelum=256,
}

-- Configuration of items which can smelt into essentia, and the essentia values they provide. 
-- No attempt is made at optimisation, first item found which provides the requested essentia will be used every time
-- Slot numbers must be unique and between 1 and 81, the size of the database. If more than 81 items need to be configured for 69 essentia types, we're doing it wrong
DatabaseRaw = {
    { -- IC2 rubber sheets
        slot=1,
        id="IC2:blockRubber",
        meta=0,
        aspects={Aer=5}
    },
    { -- Gravel
        slot=2,
        id="minecraft:gravel",
        meta=0,
        aspects={Terra=2}
    }, 
    { -- Blaze Rod
        slot=3,
        id="minecraft:blaze_rod",
        meta=0,
        aspects={Ignis=10,Praecantatio=4}
    },
    { -- Fresh Water
        slot=4,
        id="harvestcraft:freshwaterItem",
        meta=0,
        aspects={Aqua=1}
    },
    { -- Beeswax
        slot=5,
        id="Forestry:beeswax",
        meta=0,
        aspects={Ordo=3}
    },
    { -- Tiny Pile of stone dust
        slot=6,
        id="gregtech:gt.metaitem.01",
        meta=299,
        aspects={Perditio=1}
    },
    { -- Quite Clear Glass
        slot=7,
        id="EnderIO:blockFusedQuartz",
        meta=1,
        aspects={Vitreus=2}
    },
    { -- Honey Drop
        slot=8,
        id="Forestry:honeyDrop",
        meta=0,
        aspects={Permutatio=2,Victus=2}
    },
    { -- Paper 
        slot=9,
        id="minecraft:paper",
        meta=0,
        aspects={Cognitio=4,Aqua=2,Arbor=1}
    },
    { -- Gold Ingot 
        slot=10,
        id="minecraft:gold_ingot",
        meta=0,
        aspects={Metallum=3,Lucrum=2}
    },
    { -- Redstone Torch 
        slot=11,
        id="minecraft:redstone_torch",
        meta=0,
        aspects={Potentia=1,Machina=1}
    },
    { -- Terrawart
        slot=12,
        id="IC2:itemTerraWart",
        meta=0,
        aspects={Auram=8,Praecantatio=4,Victus=4}
    },
    { -- Fine Iron Wire
        slot=13,
        id="gregtech:gt.metaitem.02",
        meta=19032,
        aspects={Electrum=1}
    },
    { -- Rubber Round
        slot=14,
        id="gregtech:gt.metaitem.01",
        meta=25880,
        aspects={Instrumentum=1}
    },
    { -- Lapis
        slot=15,
        id="minecraft:dye",
        meta=4,
        aspects={Sensus=1}
    },
    { -- Torch
        slot=16,
        id="minecraft:torch",
        meta=0,
        aspects={Lux=1}
    },
    { -- Tainted Tendril
        slot=17,
        id="Thaumcraft:ItemResource",
        meta=12,
        aspects={Vitium=2,Lucrum=1,Fames=1}
    },
    { -- Soul Sand
        slot=18,
        id="minecraft:soul_sand",
        meta=0,
        aspects={Vinculum=1,Terra=1,Spiritus=1}
    },
    { -- Glass Bottle
        slot=19,
        id="minecraft:glass_bottle",
        meta=0,
        aspects={Vacuos=1}
    },
    { -- Magnesium dust
        slot=20,
        id="gregtech:gt.metaitem.01",
        meta=2018,
        aspects={Metallum=2,Perditio=1,Sano=1}
    },
    { -- Rotten Flesh
        slot=21,
        id="minecraft:rotten_flesh",
        meta=0,
        aspects={Corpus=2,Humanus=1}
    },
    { -- Rotten Flesh
        slot=22,
        id="minecraft:ender_pearl",
        meta=0,
        aspects={Alienis=4,Iter=4,Caelum=4}
    },
}

-- Export of defined variables for scoped use in other files, don't touch this unless you're adding new variables to configure
return {
    CycleSleep=CycleSleep,
    RetrySleep=RetrySleep,
    AspectTargets=AspectTargets,
    DatabaseRaw=DatabaseRaw
}