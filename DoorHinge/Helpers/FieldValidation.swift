//
//  FieldValidation.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 07/04/2026.
//

import SwiftUI
import ValidatorCore
import ValidatorUI

struct FieldValidation<ErrorView: View>: ViewModifier {
    @Binding var text: String
    @Binding var isValid: Bool
    let rules: [any IValidationRule<String>]
    @ViewBuilder let errorContent: ([any IValidationError]) -> ErrorView
    
    @State private var hasInteracted = false
    @State private var errors: [any IValidationError] = []
    
    private let validator = Validator()
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
                .onChange(of: text) { _, newValue in
                    hasInteracted = true
                    let result = validator.validate(input: newValue, rules: rules)
                    if case .invalid(let errs) = result {
                        errors = errs
                        isValid = false
                    } else {
                        errors = []
                        isValid = true
                    }
                }
            
            if hasInteracted && !errors.isEmpty {
                errorContent(errors)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
