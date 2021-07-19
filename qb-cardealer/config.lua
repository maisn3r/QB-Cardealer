Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Config = Config or {}

Config.Locations = {
    ["menu"] = {
        coords = {x = -786.44, y = -229.65, z = 37.07, h = 315.03, r = 1.0}, 
    },
    ["boss"] = {
        coords = {x = -788.81, y = -216.47, z = 37.07, h = 145.53, r = 1.0}, 
    },
    ["garage"] = {
        coords = {x = -777.35, y = -201.40, z = 37.28, h = 29.99, r = 1.0}, 
    },
    ["platform"] = {
        coords = {x = -783.78, y = -223.77, z = 37.32, h = 135.14, r = 1.0}, 
    },
    ["display1"] = {
        coords = {x = -790.99, y = -224.31, z = 37.07, h = 171.93, r = 1.0}, 
    },
    ["display2"] = {
        coords = {x = -794.87, y = -230.98, z = 37.07, h = 76.57, r = 1.0}, 
    },
    ["display3"] = {
        coords = {x = -792.19, y = -236.60, z = 37.07, h = 252.13, r = 1.0}, 
    },
    ["display4"] = {
        coords = {x = -788.94, y = -242.1302, z = 37.07, h = 268.76, r = 1.0}, 
    },
    ["display5"] = {
        coords = {x = -784.6474, y = -244.5164, z = 36.132255, h = 114.25999, r = 1.0}, 
    },
}

Config.Vehicles = {
    ["Alfa Romeo"] = { "aqv","stelvio"},
    ["Audi "] = { "audirs6tk","2015a3","q820", "r820", "rs3", "rs4avant","rs5r","rs7c8","rs62","sq72016","tts"},
    ["Bentley"] = { "contss18","bdragon","ben17","bentaygast"},
    ["BMW"] = { "m5e60","440i","bmci","m2","m135i","rmodx6","e46","acs8"},
    ["Chevrolet"] = { "z2879","c7","exor","corvettezr1"},
    ["Dodge"] = { "69charger","raid","16challenger","viper"},
    ["Ferrari"] = { "f812","f40"},
    ["Ford"] = { "mustang19","focusrs","f150","68mustang","fe86","fgt"},
    ["Honda"] = { "fk8"},
    ["Jeep"] = { "srt8b","trhawk"},
    ["Kia"] = { "kiagt"},
    ["Lada"] = { "lada2107"},
    ["Lamborghini"] = { "urus","lp700r"},
    ["Maserati"] = { "mqgts"},
    ["Mercedes"] = { "mbw124","gt63","a45amg","c63s","cls63s","g632019","s63w222"},
    ["Nissan"] = { "r35","s30"},
    ["Pontiac"] = { "firebird"},
    ["Porsche"] = { "por930","gt3rs","panamera17turbo","911turbos"},
    ["Range Rover"] = { "rrauto"},
    ["Rolls Royce"] = { "wraith"},
    ["Tesla"] = { "models"},
    ["Toyota"] = { "camry18"},
    ["Other"] = { "vantage","esv","300srt8","bluecunt"},
}
