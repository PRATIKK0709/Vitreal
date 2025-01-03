//
//  PermissionHelpers.swift
//  Vitreal
//
//  Created by Pratik Ray on 04/01/25.
//

import SwiftUI

func hasScreenCapturePermission() -> Bool {
    CGPreflightScreenCaptureAccess()
}

func requestScreenCapturePermission() {
    CGRequestScreenCaptureAccess()
}
