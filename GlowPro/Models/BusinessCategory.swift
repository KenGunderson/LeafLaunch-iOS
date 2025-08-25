//
//  BusinessCategory.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import Foundation

enum BusinessCategory: String, Codable, CaseIterable {
    
    case medspa = "MEDSPA"
    case injector = "INJECTOR"
    case esthetician = "ESTHETICIAN"
    case bodyContouring = "BODY_CONTOURING"
    case laserClinic = "LASER_CLINIC"
    case pmuArtist = "PMU_ARTIST"
    case medicalClinic = "MEDICAL_CLINIC"
    case otherBusinessTypes = "OTHER_BUSINESS_TYPES"
    
    var displayName: String {
        switch self {
        case .medspa: return "Medspa"
        case .injector: return "Injector"
        case .esthetician: return "Esthetician"
        case .bodyContouring: return "Body Contouring"
        case .laserClinic: return "Laser Clinic"
        case .pmuArtist: return "PMU Artist"
        case .medicalClinic: return "Medical Clinic"
        case .otherBusinessTypes: return "Other Business Types"
        }
    }
    
    var subcategories: [BusinessSubcategory] {
        
        switch self {
        case .medspa:
            return [
                .bodyContouring,
                .injectables,
                .prpRegenerative,
                .facialsHydro,
                .chemicalPeels,
                .laserHairRemoval,
                .pigmentVascular,
                .skinResurfacing,
                .pmuAndBrows,
            ]
            
        case .injector:
            return [
                .botox,
                .fillers,
                .fatDissolvers,
                .prpPrf,
            ]
            
        case .esthetician:
            return [
                .facials,
                .peels,
                .plasmaFibroblast,
                .microneedling,
                .acneCare,
                .skincare,
            ]
            
        case .bodyContouring:
            return [
                .fatFreezing,
                .rfContour,
                .cavitation,
                .muscleToning,
                .cellulite,
                .skinTightening
            ]
            
        case .laserClinic:
            return [
                .hairRemoval,
                .pigmentRemoval,
                .tattooRemoval,
                .vascular,
                .resurfacing,
                .iplPhotofacial,
                .scarRepair
            ]
            
        case .pmuArtist:
            return [
                .microblading,
                .powderBrows,
                .lipBlush,
                .eyeliner,
                .smp,
                .areola,
                .scarCamo
            ]
            
        case .medicalClinic:
            return [
                .plasticSurgery,
                .cosmeticSurgery,
                .dermatology,
                .dentistry,
                .orthodontics
            ]
            
        case .otherBusinessTypes:
            return [
                .weightLoss,
                .hairRestoration,
                .hairstylistBarber,
                .footHandAesthetics,
                .fitnessBody,
                .tattooArtist
            ]
        }
        
    }
    
}
