//
//  SCError.swift
//  Sound Check
//
//  Created by Alex Ryan on 8/9/24.
//

import Foundation

enum SCError: LocalizedError {
    case authNotDetermine
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue

    var errorDescription: String? {
        switch self {
            case .authNotDetermine:
                "Need access to Health Data."
            case .sharingDenied(_):
                "No write access."
            case .noData:
                "No data."
            case .unableToCompleteRequest:
                "Unable to complete request."
            case .invalidValue:
                "Invalid Valuew"
        }
    }

    var failureReason: String {
        switch self {
            case .authNotDetermine:
                "You have not given access to your Health data. Please go to Settings > Health > Data Access & Devices."
            case .sharingDenied(let quantityType):
                "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Settings > Health > Data Access & Devices."
            case .noData:
                "There is no data for the Health statistic."
            case .unableToCompleteRequest:
                "We are unable to complete your request at this time. \n\nPlease try again later or contact support."
            case .invalidValue:
                "Must be a number with a maximum of one decimal place."
        }
    }
}
