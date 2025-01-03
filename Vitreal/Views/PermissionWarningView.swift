//
//  PermissionWarningView.swift
//  Vitreal
//
//  Created by Pratik Ray on 04/01/25.
//

import SwiftUI

struct PermissionWarningView: View {
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text("Screen recording permission is required")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
