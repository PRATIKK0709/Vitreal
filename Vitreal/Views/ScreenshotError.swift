//
//  ScreenshotError.swift
//  Vitreal
//
//  Created by Pratik Ray on 04/01/25.
//

import SwiftUI

enum ScreenshotError: LocalizedError {
    case windowNotFound
    case imageCreationFailed
    case saveFailed(Error)
    case noPermissions
    case applicationNotFound
    
    var errorDescription: String? {
        switch self {
        case .windowNotFound:
            return "Unable to find the application window"
        case .imageCreationFailed:
            return "Failed to create screenshot image"
        case .saveFailed(let error):
            return "Failed to save screenshot: \(error.localizedDescription)"
        case .noPermissions:
            return "Missing required permissions"
        case .applicationNotFound:
            return "Selected application not found"
        }
    }
}
