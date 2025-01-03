//
//  ScreenshotHelpers.swift
//  Vitreal
//
//  Created by Pratik Ray on 04/01/25.
//

import CoreImage
import Cocoa
import os.log

private let logger = Logger(subsystem: "com.screenshotutility", category: "screenshot")

class ScreenshotHelpers {
   static func captureScreenshot(for selectedApp: String, in screenshotsFolder: URL) throws -> String {
       let workspace = NSWorkspace.shared
       guard let app = workspace.runningApplications.first(where: { $0.localizedName == selectedApp }) else {
           throw ScreenshotError.applicationNotFound
       }
       
       guard let windows = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] else {
           throw ScreenshotError.windowNotFound
       }
       
       let appWindows = windows.filter { window in
           guard let ownerPID = window[kCGWindowOwnerPID as String] as? Int else { return false }
           return ownerPID == app.processIdentifier
       }
       
       guard let window = appWindows.first,
             let windowID = window[kCGWindowNumber as String] as? CGWindowID else {
           throw ScreenshotError.windowNotFound
       }
       
       guard let cgImage = CGWindowListCreateImage(
           .null,
           .optionIncludingWindow,
           windowID,
           [.boundsIgnoreFraming, .bestResolution, .nominalResolution]
       ) else {
           throw ScreenshotError.imageCreationFailed
       }

       return try saveScreenshot(cgImage: cgImage, appName: selectedApp, folder: screenshotsFolder)
   }
   
   private static func saveScreenshot(cgImage: CGImage, appName: String, folder: URL) throws -> String {
       let timestamp = ISO8601DateFormatter().string(from: Date())
           .replacingOccurrences(of: ":", with: "-")
       let sanitizedAppName = appName.replacingOccurrences(of: "/", with: "-")
       let filename = "Screenshot-\(sanitizedAppName)-\(timestamp).png"
       let fileURL = folder.appendingPathComponent(filename)
       
       let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
       
       guard let tiffData = nsImage.tiffRepresentation,
             let bitmapImage = NSBitmapImageRep(data: tiffData),
             let pngData = bitmapImage.representation(using: .png, properties: [.compressionFactor: 1.0]) else {
           throw ScreenshotError.imageCreationFailed
       }
       
       try pngData.write(to: fileURL)
       logger.info("Screenshot saved at \(fileURL.path)")
       return fileURL.path
   }
}
