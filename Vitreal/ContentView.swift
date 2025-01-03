//
//  ContentView.swift
//  Wakey
//
//  Created by Pratik Ray on 19/12/24.
//

//
//  ContentView.swift
//  Wakey
//
//  Created by Pratik Ray on 19/12/24.
//

// AppDelegate.swift

import SwiftUI
import Cocoa
import CoreImage
import UniformTypeIdentifiers
import os.log
import ScreenCaptureKit

private let logger = Logger(subsystem: "com.screenshotutility", category: "main")





// ContentView.swift
struct ContentView: View {
   @State private var selectedApp: String = ""
   @State private var availableApps: [String] = []
   @State private var screenshotTaken: Bool = false
   @State private var lastScreenshotPath: String = ""
   @State private var errorMessage: String? = nil
   @State private var showError: Bool = false
   @State private var isProcessing: Bool = false
   @State private var hasPermissions: Bool = false
    @State private var previewImage: NSImage? = nil
    @State private var showPreview: Bool = false
   
   private let screenshotsFolder: URL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!.appendingPathComponent("AppScreenshots")
   
   var body: some View {
       VStack(spacing: 32) {
           Text("ScreenshotAssist")
               .font(.system(size: 24, weight: .light))
               .foregroundColor(.black.opacity(0.8))
               .padding(.top, 32)
           
           if !hasPermissions {
               PermissionWarningView()
           }
           
           VStack(alignment: .leading, spacing: 8) {
               Text("Select Application")
                   .font(.system(size: 14, weight: .regular))
                   .foregroundColor(.black.opacity(0.6))
               
               Menu {
                   ForEach(availableApps, id: \.self) { app in
                       Button(action: {
                           selectedApp = app
                       }) {
                           Text(app)
                       }
                   }
               } label: {
                   HStack {
                       Text(selectedApp.isEmpty ? "Select App" : selectedApp)
                           .foregroundColor(selectedApp.isEmpty ? .gray : .black)
                       Spacer()
                       Image(systemName: "chevron.down")
                           .foregroundColor(.gray)
                   }
                   .padding(.horizontal, 12)
                   .padding(.vertical, 8)
                   .frame(maxWidth: .infinity)
                   .background(Color.black.opacity(0.02))
               }
               .frame(maxWidth: .infinity)
           }
           .padding(.horizontal, 32)
           
           if isProcessing {
               ProgressView()
                   .progressViewStyle(CircularProgressViewStyle())
           }
           
           VStack(spacing: 16) {
               Button(action: takeScreenshot) {
                   HStack {
                       Image(systemName: "camera")
                           .font(.system(size: 14))
                       Text("Capture")
                           .font(.system(size: 14, weight: .medium))
                   }
                   .frame(maxWidth: .infinity)
                   .frame(height: 44)
                   .background(selectedApp.isEmpty ? Color.black.opacity(0.05) : Color.black.opacity(0.8))
                   .foregroundColor(selectedApp.isEmpty ? .black.opacity(0.3) : .white)
                   .cornerRadius(8)
               }
               .disabled(selectedApp.isEmpty || isProcessing)
               .buttonStyle(PlainButtonStyle())
               
               Button(action: openScreenshotsFolder) {
                   HStack {
                       Image(systemName: "folder")
                           .font(.system(size: 14))
                       Text("View Captures")
                           .font(.system(size: 14, weight: .regular))
                   }
                   .frame(maxWidth: .infinity)
                   .frame(height: 44)
                   .background(Color.white)
                   .foregroundColor(.black.opacity(0.6))
                   .cornerRadius(8)
                   .overlay(
                       RoundedRectangle(cornerRadius: 8)
                           .stroke(Color.black.opacity(0.1), lineWidth: 1)
                   )
               }
               .disabled(isProcessing)
               .buttonStyle(PlainButtonStyle())
           }
           .padding(.horizontal, 32)
           
           if screenshotTaken {
               HStack {
                   Image(systemName: "checkmark.circle.fill")
                       .foregroundColor(.black.opacity(0.6))
                   Text("Captured successfully")
                       .font(.system(size: 13, weight: .regular))
                       .foregroundColor(.black.opacity(0.6))
               }
               .padding(.vertical, 8)
               .padding(.horizontal, 16)
               .background(Color.black.opacity(0.05))
               .cornerRadius(6)
               .onAppear {
                   DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                       screenshotTaken = false
                   }
               }
           }
           
           Spacer()
       }
       .frame(width: 380, height: 340)
       .background(Color.white)
       .preferredColorScheme(.light)
       .alert("Error", isPresented: $showError) {
           Button("OK") { showError = false }
       } message: {
           Text(errorMessage ?? "An unknown error occurred")
       }
       .onAppear {
           checkPermissions()
           loadRunningApps()
           createScreenshotsFolder()
       }
   }
   
   private func checkPermissions() {
       hasPermissions = hasScreenCapturePermission()
       if !hasPermissions {
           requestScreenCapturePermission()
       }
   }
   
   private func takeScreenshot() {
       guard !selectedApp.isEmpty else { return }
       guard hasPermissions else {
           showError(message: ScreenshotError.noPermissions.errorDescription ?? "")
           return
       }
       
       isProcessing = true
       
       DispatchQueue.global(qos: .userInitiated).async {
           do {
               _ = try ScreenshotHelpers.captureScreenshot(for: selectedApp, in: screenshotsFolder)
               DispatchQueue.main.async {
                   screenshotTaken = true
               }
           } catch let error as ScreenshotError {
               showError(message: error.errorDescription ?? "Unknown error")
           } catch {
               showError(message: error.localizedDescription)
           }
           
           DispatchQueue.main.async {
               isProcessing = false
           }
       }
   }
   
   private func createScreenshotsFolder() {
       do {
           try FileManager.default.createDirectory(at: screenshotsFolder, withIntermediateDirectories: true, attributes: nil)
       } catch {
           logger.error("Failed to create screenshots directory: \(error.localizedDescription)")
           showError(message: "Failed to create screenshots directory")
       }
   }
   
   private func openScreenshotsFolder() {
       NSWorkspace.shared.open(screenshotsFolder)
   }
   
   private func loadRunningApps() {
       let workspace = NSWorkspace.shared
       availableApps = workspace.runningApplications
           .filter { $0.activationPolicy == .regular }
           .compactMap { $0.localizedName }
           .filter { !$0.isEmpty }
           .sorted()
   }
   
   private func showError(message: String) {
       DispatchQueue.main.async {
           errorMessage = message
           showError = true
           logger.error("\(message)")
       }
   }
}

struct PreviewWindow: View {
    let screenshot: NSImage
    let onDismiss: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack {
            Image(nsImage: screenshot)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 600, maxHeight: 400)
            
            HStack {
                Button("Discard") { onDismiss() }
                Button("Save") { onSave() }
            }
            .padding()
        }
        .background(Color.white)
        .frame(minWidth: 400, minHeight: 300)
    }
}



#Preview {
    ContentView()
}
