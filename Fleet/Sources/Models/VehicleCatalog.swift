import Foundation

/// Comprehensive catalog of vehicle makes and models sold in the US market (2005–2025).
/// Used by the add-vehicle form to provide picker-based selection.
enum VehicleCatalog {

    // MARK: - Public API

    /// All makes sorted alphabetically.
    static let makes: [String] = Array(catalog.keys).sorted()

    /// Returns the models for a given make, sorted alphabetically.
    static func models(for make: String) -> [String] {
        (catalog[make] ?? []).sorted()
    }

    /// Year range available for selection (descending so newest appears first).
    static let years: [Int] = Array((2005...2025).reversed())

    // MARK: - Catalog Data

    // swiftlint:disable function_body_length
    private static let catalog: [String: [String]] = [

        // ──────────────────────────────────────────────
        // TOYOTA
        // ──────────────────────────────────────────────
        "Toyota": [
            "4Runner",
            "86",
            "Avalon",
            "bZ4X",
            "C-HR",
            "Camry",
            "Celica",
            "Corolla",
            "Corolla Cross",
            "Corolla Hatchback",
            "Corolla iM",
            "Crown",
            "Echo",
            "FJ Cruiser",
            "GR Corolla",
            "GR Supra",
            "GR86",
            "Grand Highlander",
            "Highlander",
            "Land Cruiser",
            "Matrix",
            "Mirai",
            "MR2 Spyder",
            "Prius",
            "Prius C",
            "Prius Prime",
            "Prius V",
            "RAV4",
            "RAV4 Prime",
            "Sequoia",
            "Sienna",
            "Solara",
            "Supra",
            "Tacoma",
            "Tundra",
            "Venza",
            "Yaris",
            "Yaris iA",
        ],

        // ──────────────────────────────────────────────
        // HONDA
        // ──────────────────────────────────────────────
        "Honda": [
            "Accord",
            "Accord Crosstour",
            "Civic",
            "Civic Type R",
            "Clarity",
            "CR-V",
            "CR-Z",
            "Crosstour",
            "Element",
            "Fit",
            "HR-V",
            "Insight",
            "Odyssey",
            "Passport",
            "Pilot",
            "Prelude",
            "Prologue",
            "Ridgeline",
            "S2000",
        ],

        // ──────────────────────────────────────────────
        // FORD
        // ──────────────────────────────────────────────
        "Ford": [
            "Bronco",
            "Bronco Sport",
            "C-Max",
            "Crown Victoria",
            "EcoSport",
            "Edge",
            "Escape",
            "Excursion",
            "Expedition",
            "Explorer",
            "F-150",
            "F-150 Lightning",
            "F-250 Super Duty",
            "F-350 Super Duty",
            "F-450 Super Duty",
            "Fiesta",
            "Five Hundred",
            "Flex",
            "Focus",
            "Focus RS",
            "Focus ST",
            "Freestar",
            "Freestyle",
            "Fusion",
            "GT",
            "Maverick",
            "Mustang",
            "Mustang Mach-E",
            "Ranger",
            "Shelby GT350",
            "Shelby GT500",
            "Taurus",
            "Transit Connect",
            "Transit Van",
        ],

        // ──────────────────────────────────────────────
        // CHEVROLET
        // ──────────────────────────────────────────────
        "Chevrolet": [
            "Avalanche",
            "Aveo",
            "Blazer",
            "Blazer EV",
            "Bolt EUV",
            "Bolt EV",
            "Camaro",
            "Cobalt",
            "Colorado",
            "Corvette",
            "Cruze",
            "Equinox",
            "Equinox EV",
            "Express",
            "HHR",
            "Impala",
            "Malibu",
            "Monte Carlo",
            "Silverado 1500",
            "Silverado 2500HD",
            "Silverado 3500HD",
            "Silverado EV",
            "Sonic",
            "Spark",
            "SS",
            "SSR",
            "Suburban",
            "Tahoe",
            "Tracker",
            "Trailblazer",
            "Traverse",
            "Trax",
            "Uplander",
            "Volt",
        ],

        // ──────────────────────────────────────────────
        // GMC
        // ──────────────────────────────────────────────
        "GMC": [
            "Acadia",
            "Canyon",
            "Envoy",
            "Hummer EV",
            "Hummer EV SUV",
            "Sierra 1500",
            "Sierra 2500HD",
            "Sierra 3500HD",
            "Terrain",
            "Yukon",
            "Yukon XL",
        ],

        // ──────────────────────────────────────────────
        // RAM
        // ──────────────────────────────────────────────
        "Ram": [
            "1500",
            "1500 Classic",
            "2500",
            "3500",
            "ProMaster",
            "ProMaster City",
        ],

        // ──────────────────────────────────────────────
        // JEEP
        // ──────────────────────────────────────────────
        "Jeep": [
            "Cherokee",
            "Commander",
            "Compass",
            "Gladiator",
            "Grand Cherokee",
            "Grand Cherokee 4xe",
            "Grand Cherokee L",
            "Grand Wagoneer",
            "Liberty",
            "Patriot",
            "Renegade",
            "Wagoneer",
            "Wrangler",
            "Wrangler 4xe",
        ],

        // ──────────────────────────────────────────────
        // DODGE
        // ──────────────────────────────────────────────
        "Dodge": [
            "Avenger",
            "Caliber",
            "Challenger",
            "Charger",
            "Dakota",
            "Dart",
            "Durango",
            "Grand Caravan",
            "Hornet",
            "Journey",
            "Magnum",
            "Neon",
            "Nitro",
            "Viper",
        ],

        // ──────────────────────────────────────────────
        // CHRYSLER
        // ──────────────────────────────────────────────
        "Chrysler": [
            "200",
            "300",
            "Aspen",
            "Crossfire",
            "Pacifica",
            "PT Cruiser",
            "Sebring",
            "Town & Country",
            "Voyager",
        ],

        // ──────────────────────────────────────────────
        // NISSAN
        // ──────────────────────────────────────────────
        "Nissan": [
            "350Z",
            "370Z",
            "Altima",
            "Ariya",
            "Armada",
            "Cube",
            "Frontier",
            "GT-R",
            "Juke",
            "Kicks",
            "Leaf",
            "Maxima",
            "Murano",
            "NV200",
            "Pathfinder",
            "Quest",
            "Rogue",
            "Rogue Select",
            "Rogue Sport",
            "Sentra",
            "Titan",
            "Titan XD",
            "Versa",
            "Versa Note",
            "Xterra",
            "Z",
        ],

        // ──────────────────────────────────────────────
        // HYUNDAI
        // ──────────────────────────────────────────────
        "Hyundai": [
            "Accent",
            "Azera",
            "Elantra",
            "Elantra GT",
            "Elantra N",
            "Entourage",
            "Equus",
            "Genesis",
            "Genesis Coupe",
            "Ioniq",
            "Ioniq 5",
            "Ioniq 6",
            "Kona",
            "Kona Electric",
            "Kona N",
            "Nexo",
            "Palisade",
            "Santa Cruz",
            "Santa Fe",
            "Sonata",
            "Tiburon",
            "Tucson",
            "Veloster",
            "Veloster N",
            "Venue",
            "Veracruz",
        ],

        // ──────────────────────────────────────────────
        // KIA
        // ──────────────────────────────────────────────
        "Kia": [
            "Amanti",
            "Borrego",
            "Cadenza",
            "Carnival",
            "EV6",
            "EV9",
            "Forte",
            "K5",
            "K900",
            "Niro",
            "Niro EV",
            "Optima",
            "Rio",
            "Rondo",
            "Sedona",
            "Seltos",
            "Sorento",
            "Soul",
            "Soul EV",
            "Spectra",
            "Sportage",
            "Stinger",
            "Telluride",
        ],

        // ──────────────────────────────────────────────
        // SUBARU
        // ──────────────────────────────────────────────
        "Subaru": [
            "Ascent",
            "Baja",
            "BRZ",
            "Crosstrek",
            "Forester",
            "Impreza",
            "Legacy",
            "Outback",
            "Solterra",
            "Tribeca",
            "WRX",
            "XV Crosstrek",
        ],

        // ──────────────────────────────────────────────
        // MAZDA
        // ──────────────────────────────────────────────
        "Mazda": [
            "CX-3",
            "CX-30",
            "CX-5",
            "CX-50",
            "CX-7",
            "CX-70",
            "CX-9",
            "CX-90",
            "Mazda2",
            "Mazda3",
            "Mazda5",
            "Mazda6",
            "MazdaSpeed3",
            "MazdaSpeed6",
            "MX-5 Miata",
            "MX-30",
            "RX-8",
            "Tribute",
        ],

        // ──────────────────────────────────────────────
        // VOLKSWAGEN
        // ──────────────────────────────────────────────
        "Volkswagen": [
            "Arteon",
            "Atlas",
            "Atlas Cross Sport",
            "Beetle",
            "CC",
            "e-Golf",
            "Eos",
            "GLI",
            "Golf",
            "Golf Alltrack",
            "Golf GTI",
            "Golf R",
            "Golf SportWagen",
            "ID.4",
            "ID.Buzz",
            "Jetta",
            "Passat",
            "Phaeton",
            "Rabbit",
            "Routan",
            "Taos",
            "Tiguan",
            "Touareg",
        ],

        // ──────────────────────────────────────────────
        // BMW
        // ──────────────────────────────────────────────
        "BMW": [
            "1 Series",
            "2 Series",
            "3 Series",
            "4 Series",
            "5 Series",
            "6 Series",
            "7 Series",
            "8 Series",
            "i3",
            "i4",
            "i5",
            "i7",
            "iX",
            "M2",
            "M3",
            "M4",
            "M5",
            "M8",
            "X1",
            "X2",
            "X3",
            "X3 M",
            "X4",
            "X4 M",
            "X5",
            "X5 M",
            "X6",
            "X6 M",
            "X7",
            "XM",
            "Z4",
        ],

        // ──────────────────────────────────────────────
        // MERCEDES-BENZ
        // ──────────────────────────────────────────────
        "Mercedes-Benz": [
            "A-Class",
            "AMG GT",
            "B-Class",
            "C-Class",
            "CL-Class",
            "CLA",
            "CLK-Class",
            "CLS",
            "E-Class",
            "EQB",
            "EQE",
            "EQE SUV",
            "EQS",
            "EQS SUV",
            "G-Class",
            "GLA",
            "GLB",
            "GLC",
            "GLC Coupe",
            "GLE",
            "GLE Coupe",
            "GLK-Class",
            "GLS",
            "Maybach GLS",
            "Maybach S-Class",
            "Metris",
            "ML-Class",
            "R-Class",
            "S-Class",
            "SL",
            "SLC",
            "SLK-Class",
            "Sprinter",
        ],

        // ──────────────────────────────────────────────
        // AUDI
        // ──────────────────────────────────────────────
        "Audi": [
            "A3",
            "A4",
            "A4 allroad",
            "A5",
            "A6",
            "A6 allroad",
            "A7",
            "A8",
            "e-tron",
            "e-tron GT",
            "e-tron S",
            "e-tron Sportback",
            "Q3",
            "Q4 e-tron",
            "Q5",
            "Q5 Sportback",
            "Q6 e-tron",
            "Q7",
            "Q8",
            "Q8 e-tron",
            "R8",
            "RS 3",
            "RS 5",
            "RS 6 Avant",
            "RS 7",
            "RS e-tron GT",
            "RS Q8",
            "S3",
            "S4",
            "S5",
            "S6",
            "S7",
            "S8",
            "SQ5",
            "SQ7",
            "SQ8",
            "TT",
            "TT RS",
            "TTS",
        ],

        // ──────────────────────────────────────────────
        // LEXUS
        // ──────────────────────────────────────────────
        "Lexus": [
            "CT",
            "ES",
            "GS",
            "GX",
            "IS",
            "LC",
            "LFA",
            "LS",
            "LX",
            "NX",
            "RC",
            "RC F",
            "RX",
            "RZ",
            "SC",
            "TX",
            "UX",
        ],

        // ──────────────────────────────────────────────
        // ACURA
        // ──────────────────────────────────────────────
        "Acura": [
            "ILX",
            "Integra",
            "MDX",
            "NSX",
            "RDX",
            "RL",
            "RLX",
            "RSX",
            "TL",
            "TLX",
            "TSX",
            "ZDX",
        ],

        // ──────────────────────────────────────────────
        // INFINITI
        // ──────────────────────────────────────────────
        "Infiniti": [
            "EX",
            "FX",
            "G",
            "G35",
            "G37",
            "JX",
            "M",
            "Q40",
            "Q50",
            "Q60",
            "Q70",
            "QX30",
            "QX50",
            "QX55",
            "QX56",
            "QX60",
            "QX70",
            "QX80",
        ],

        // ──────────────────────────────────────────────
        // CADILLAC
        // ──────────────────────────────────────────────
        "Cadillac": [
            "ATS",
            "ATS-V",
            "CT4",
            "CT5",
            "CT6",
            "CTS",
            "CTS-V",
            "DeVille",
            "DTS",
            "Escalade",
            "Escalade ESV",
            "ELR",
            "Lyriq",
            "SRX",
            "STS",
            "XT4",
            "XT5",
            "XT6",
            "XTS",
        ],

        // ──────────────────────────────────────────────
        // LINCOLN
        // ──────────────────────────────────────────────
        "Lincoln": [
            "Aviator",
            "Continental",
            "Corsair",
            "LS",
            "Mark LT",
            "MKC",
            "MKS",
            "MKT",
            "MKX",
            "MKZ",
            "Nautilus",
            "Navigator",
            "Navigator L",
            "Town Car",
            "Zephyr",
        ],

        // ──────────────────────────────────────────────
        // BUICK
        // ──────────────────────────────────────────────
        "Buick": [
            "Cascada",
            "Century",
            "Enclave",
            "Encore",
            "Encore GX",
            "Envision",
            "Envista",
            "LaCrosse",
            "LeSabre",
            "Lucerne",
            "Park Avenue",
            "Rainier",
            "Regal",
            "Regal Sportback",
            "Regal TourX",
            "Rendezvous",
            "Terraza",
            "Verano",
        ],

        // ──────────────────────────────────────────────
        // TESLA
        // ──────────────────────────────────────────────
        "Tesla": [
            "Cybertruck",
            "Model 3",
            "Model S",
            "Model X",
            "Model Y",
            "Roadster",
        ],

        // ──────────────────────────────────────────────
        // VOLVO
        // ──────────────────────────────────────────────
        "Volvo": [
            "C30",
            "C40 Recharge",
            "C70",
            "EX30",
            "EX90",
            "S40",
            "S60",
            "S80",
            "S90",
            "V40",
            "V60",
            "V60 Cross Country",
            "V90",
            "V90 Cross Country",
            "XC40",
            "XC40 Recharge",
            "XC60",
            "XC70",
            "XC90",
        ],

        // ──────────────────────────────────────────────
        // PORSCHE
        // ──────────────────────────────────────────────
        "Porsche": [
            "718 Boxster",
            "718 Cayman",
            "718 Spyder",
            "911",
            "Boxster",
            "Cayenne",
            "Cayenne Coupe",
            "Cayman",
            "Macan",
            "Panamera",
            "Taycan",
        ],

        // ──────────────────────────────────────────────
        // LAND ROVER
        // ──────────────────────────────────────────────
        "Land Rover": [
            "Defender",
            "Discovery",
            "Discovery Sport",
            "Freelander",
            "LR2",
            "LR3",
            "LR4",
            "Range Rover",
            "Range Rover Evoque",
            "Range Rover Sport",
            "Range Rover Velar",
        ],

        // ──────────────────────────────────────────────
        // MINI
        // ──────────────────────────────────────────────
        "MINI": [
            "Clubman",
            "Convertible",
            "Cooper",
            "Cooper Countryman",
            "Cooper Hardtop",
            "Cooper Paceman",
            "Cooper Roadster",
            "Countryman",
            "Hardtop 2 Door",
            "Hardtop 4 Door",
        ],

        // ──────────────────────────────────────────────
        // MITSUBISHI
        // ──────────────────────────────────────────────
        "Mitsubishi": [
            "Eclipse",
            "Eclipse Cross",
            "Endeavor",
            "Galant",
            "Lancer",
            "Lancer Evolution",
            "Mirage",
            "Mirage G4",
            "Outlander",
            "Outlander PHEV",
            "Outlander Sport",
            "Raider",
        ],

        // ──────────────────────────────────────────────
        // GENESIS
        // ──────────────────────────────────────────────
        "Genesis": [
            "Electrified G80",
            "Electrified GV70",
            "G70",
            "G80",
            "G90",
            "GV60",
            "GV70",
            "GV80",
        ],

        // ──────────────────────────────────────────────
        // RIVIAN
        // ──────────────────────────────────────────────
        "Rivian": [
            "R1S",
            "R1T",
            "R2",
        ],

        // ──────────────────────────────────────────────
        // LUCID
        // ──────────────────────────────────────────────
        "Lucid": [
            "Air",
            "Gravity",
        ],

        // ──────────────────────────────────────────────
        // JAGUAR
        // ──────────────────────────────────────────────
        "Jaguar": [
            "E-PACE",
            "F-PACE",
            "F-TYPE",
            "I-PACE",
            "S-Type",
            "X-Type",
            "XE",
            "XF",
            "XJ",
            "XK",
        ],

        // ──────────────────────────────────────────────
        // ALFA ROMEO
        // ──────────────────────────────────────────────
        "Alfa Romeo": [
            "4C",
            "4C Spider",
            "Giulia",
            "Stelvio",
            "Tonale",
        ],

        // ──────────────────────────────────────────────
        // MASERATI
        // ──────────────────────────────────────────────
        "Maserati": [
            "Ghibli",
            "GranSport",
            "GranTurismo",
            "Grecale",
            "Levante",
            "MC20",
            "Quattroporte",
        ],

        // ──────────────────────────────────────────────
        // FIAT
        // ──────────────────────────────────────────────
        "Fiat": [
            "124 Spider",
            "500",
            "500e",
            "500L",
            "500X",
        ],

        // ──────────────────────────────────────────────
        // SCION (2005–2016)
        // ──────────────────────────────────────────────
        "Scion": [
            "FR-S",
            "iA",
            "iM",
            "iQ",
            "tC",
            "xA",
            "xB",
            "xD",
        ],

        // ──────────────────────────────────────────────
        // SATURN (2005–2010)
        // ──────────────────────────────────────────────
        "Saturn": [
            "Astra",
            "Aura",
            "Ion",
            "Outlook",
            "Relay",
            "Sky",
            "Vue",
        ],

        // ──────────────────────────────────────────────
        // PONTIAC (2005–2010)
        // ──────────────────────────────────────────────
        "Pontiac": [
            "G5",
            "G6",
            "G8",
            "Grand Prix",
            "GTO",
            "Solstice",
            "Torrent",
            "Vibe",
        ],

        // ──────────────────────────────────────────────
        // HUMMER (2005–2010)
        // ──────────────────────────────────────────────
        "Hummer": [
            "H2",
            "H3",
            "H3T",
        ],

        // ──────────────────────────────────────────────
        // MERCURY (2005–2011)
        // ──────────────────────────────────────────────
        "Mercury": [
            "Grand Marquis",
            "Mariner",
            "Milan",
            "Montego",
            "Monterey",
            "Mountaineer",
            "Sable",
        ],

        // ──────────────────────────────────────────────
        // SAAB (2005–2011)
        // ──────────────────────────────────────────────
        "Saab": [
            "9-2X",
            "9-3",
            "9-5",
            "9-7X",
        ],

        // ──────────────────────────────────────────────
        // SUZUKI (2005–2013)
        // ──────────────────────────────────────────────
        "Suzuki": [
            "Equator",
            "Forenza",
            "Grand Vitara",
            "Kizashi",
            "Reno",
            "SX4",
            "Verona",
            "XL-7",
        ],

        // ──────────────────────────────────────────────
        // POLESTAR
        // ──────────────────────────────────────────────
        "Polestar": [
            "Polestar 1",
            "Polestar 2",
            "Polestar 3",
        ],

        // ──────────────────────────────────────────────
        // FISKER
        // ──────────────────────────────────────────────
        "Fisker": [
            "Karma",
            "Ocean",
        ],

        // ──────────────────────────────────────────────
        // SMART (2008–2019)
        // ──────────────────────────────────────────────
        "smart": [
            "fortwo",
            "fortwo Electric Drive",
        ],
    ]
    // swiftlint:enable function_body_length
}
