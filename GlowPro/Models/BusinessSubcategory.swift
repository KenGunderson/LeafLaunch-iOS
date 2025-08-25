//
//  BusinessSubcategory.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import Foundation

enum BusinessSubcategory: String, Codable, CaseIterable {
    
    // Shared / Medspa items
    case bodyContouring = "BODY_CONTOURING"
    case injectables = "INJECTABLES"
    case prpRegenerative = "PRP_REGENERATIVE"
    case facialsHydro = "FACIALS_HYDRO"
    case chemicalPeels = "CHEMICAL_PEELS"
    case microneedling = "MICRONEEDLING"
    case laserHairRemoval = "LASER_HAIR_REMOVAL"
    case pigmentVascular = "PIGMENT_VASCULAR"
    case skinResurfacing = "SKIN_RESURFACING"
    case pmuAndBrows = "PMU_AND_BROWS"
    
    // Injector
    case botox = "BOTOX"
    case fillers = "FILLERS"
    case fatDissolvers = "FAT_DISSOLVERS"
    case prpPrf = "PRP_PRF"
    
    // Esthetician
    case facials = "FACIALS"
    case peels = "PEELS"
    case plasmaFibroblast = "PLASMA_FIBROBLAST"
    case acneCare = "ACNE_CARE"
    case skincare = "SKINCARE"
    
    // Body Contouring detail
    case fatFreezing = "FAT_FREEZING"
    case rfContour = "RF_CONTOUR"
    case cavitation = "CAVITATION"
    case muscleToning = "MUSCLE_TONING"
    case cellulite = "CELLULITE"
    case skinTightening = "SKIN_TIGHTENING"
    
    // Laser Clinic detail
    case hairRemoval = "HAIR_REMOVAL"
    case pigmentRemoval = "PIGMENT_REMOVAL"
    case tattooRemoval = "TATTOO_REMOVAL"
    case vascular = "VASCULAR"
    case resurfacing = "RESURFACING"
    case iplPhotofacial = "IPL_PHOTOFACIAL"
    case scarRepair = "SCAR_REPAIR"
    
    // PMU Artist
    case microblading = "MICROBLADING"
    case powderBrows = "POWDER_BROWS"
    case lipBlush = "LIP_BLUSH"
    case eyeliner = "EYELINER"
    case smp = "SMP"
    case areola = "AREOLA"
    case scarCamo = "SCAR_CAMO"
    
    // Medical Clinic
    case plasticSurgery = "PLASTIC_SURGERY"
    case cosmeticSurgery = "COSMETIC_SURGERY"
    case dermatology = "DERMATOLOGY"
    case dentistry = "DENTISTRY"
    case orthodontics = "ORTHODONTICS"
    
    // Other Business Types
    case weightLoss = "WEIGHT_LOSS"
    case hairRestoration = "HAIR_RESTORATION"
    case hairstylistBarber = "HAIRSTYLIST_BARBER"
    case footHandAesthetics = "FOOT_HAND_AESTHETICS"
    case fitnessBody = "FITNESS_BODY"
    case tattooArtist = "TATTOO_ARTIST"
        
}

extension BusinessSubcategory {
    
    var displayName: String {
        switch self {
        case .bodyContouring: return "Body Contouring"
        case .injectables: return "Injectables"
        case .prpRegenerative: return "PRP / Regenerative"
        case .facialsHydro: return "Facials / Hydro"
        case .chemicalPeels: return "Chemical Peels"
        case .microneedling: return "Microneedling"
        case .laserHairRemoval: return "Laser Hair Removal"
        case .pigmentVascular: return "Pigment / Vascular"
        case .skinResurfacing: return "Skin Resurfacing"
        case .pmuAndBrows: return "PMU & Brows"
 
        case .botox: return "Botox"
        case .fillers: return "Fillers"
        case .fatDissolvers: return "Fat Dissolvers"
        case .prpPrf: return "PRP/PRF"
 
        case .facials: return "Facials"
        case .peels: return "Peels"
        case .plasmaFibroblast: return "Plasma Fibroblast"
        case .acneCare: return "Acne Care"
        case .skincare: return "Skincare"
 
        case .fatFreezing: return "Fat Freezing"
        case .rfContour: return "RF Contour"
        case .cavitation: return "Cavitation"
        case .muscleToning: return "Muscle Toning"
        case .cellulite: return "Cellulite"
        case .skinTightening: return "Skin Tightening"
 
        case .hairRemoval: return "Hair Removal"
        case .pigmentRemoval: return "Pigment Removal"
        case .tattooRemoval: return "Tattoo Removal"
        case .vascular: return "Vascular"
        case .resurfacing: return "Resurfacing"
        case .iplPhotofacial: return "IPL Photofacial"
        case .scarRepair: return "Scar Repair"
            
        case .microblading: return "Microblading"
        case .powderBrows: return "Powder Brows"
        case .lipBlush: return "Lip Blush"
        case .eyeliner: return "Eyeliner"
        case .smp: return "SMP"
        case .areola: return "Areola"
        case .scarCamo: return "Scar Camo"
            
        case .plasticSurgery: return "Plastic Surgery"
        case .cosmeticSurgery: return "Cosmetic Surgery"
        case .dermatology: return "Dermatology"
        case .dentistry: return "Dentistry"
        case .orthodontics: return "Orthodontics"
            
        case .weightLoss: return "Weight Loss"
        case .hairRestoration: return "Hair Restoration"
        case .hairstylistBarber: return "Hairstylist / Barber"
        case .footHandAesthetics: return "Foot / Hand Aesthetics"
        case .fitnessBody: return "Fitness / Body"
        case .tattooArtist: return "Tattoo Artist"
        }
        
    }
    
}

extension BusinessSubcategory {
    
    var category: BusinessCategory {
        switch self {
            
        // Shared / Medspa
        case .bodyContouring,
             .injectables,
             .prpRegenerative,
             .facialsHydro,
             .chemicalPeels,
             .microneedling,
             .laserHairRemoval,
             .pigmentVascular,
             .skinResurfacing,
             .pmuAndBrows:
            return .medspa
            
        // Injector
        case .botox,
             .fillers,
             .fatDissolvers,
             .prpPrf:
            return .injector
            
        // Esthetician
        case .facials,
             .peels,
             .plasmaFibroblast,
             .acneCare,
             .skincare:
            return .esthetician
            
        // Body Contouring
        case .fatFreezing,
             .rfContour,
             .cavitation,
             .muscleToning,
             .cellulite,
             .skinTightening:
            return .bodyContouring
            
        // Laser Clinic
        case .hairRemoval,
             .pigmentRemoval,
             .tattooRemoval,
             .vascular,
             .resurfacing,
             .iplPhotofacial,
             .scarRepair:
            return .laserClinic
            
        // PMU Artist
        case .microblading,
             .powderBrows,
             .lipBlush,
             .eyeliner,
             .smp,
             .areola,
             .scarCamo:
            return .pmuArtist
            
        // Medical Clinic
        case .plasticSurgery,
             .cosmeticSurgery,
             .dermatology,
             .dentistry,
             .orthodontics:
            return .medicalClinic
            
        // Other Business Types
        case .weightLoss,
             .hairRestoration,
             .hairstylistBarber,
             .footHandAesthetics,
             .fitnessBody,
             .tattooArtist:
            return .otherBusinessTypes
        }
        
    }
    
}
