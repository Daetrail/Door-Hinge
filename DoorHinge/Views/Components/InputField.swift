//
//  InputField.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI

struct InputField<Content: View>: View {
    var iconSystemName: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconSystemName)
                .foregroundStyle(.secondary.opacity(0.7))
                .frame(width: 25, height: 25)
            
            content()
        }
        .padding()
        .glassEffect()
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var secureText = ""
    
    VStack {
        InputField(iconSystemName: "person") {
            TextField("Text", text: $text)
                .foregroundStyle(.primary)
                .autocorrectionDisabled(true)
                .textContentType(.username)
                .autocapitalization(.none)
        }
        
        InputField(iconSystemName: "key") {
            SecureField("Secure Text", text: $secureText)
                .foregroundStyle(.primary)
                .autocorrectionDisabled()
                .textContentType(.password)
        }
    }
}
