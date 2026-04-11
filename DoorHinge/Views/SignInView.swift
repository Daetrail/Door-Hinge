//
//  SignInView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 07/04/2026.
//

import SwiftUI
import ValidatorCore

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Bindable private var vm: SignInViewModel
    
    init(vm: SignInViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            Image(.onboardingBackground)
                .resizable()
                .blur(radius: 10)
            
            VStack(spacing: 25) {
                Text("Sign in")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                
                Text("Enter your credentials below.")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
               
                VStack(spacing: 10) {
                    InputField(iconSystemName: "envelope") {
                        TextField("", text: $vm.email, prompt: Text("Email").foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)))
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .modifier(FieldValidation(text: $vm.email, isValid: $vm.isEmailValid, rules: [
                        EmailValidationRule(error: "Enter a valid email address")
                    ]) { errors in
                        ForEach(errors.indices, id: \.self) { i in
                            Text(errors[i].message)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.leading)
                        }
                    })
                    
                    InputField(iconSystemName: "key") {
                        SecureField("", text: $vm.password, prompt: Text("Password").foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)))
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .modifier(FieldValidation(text: $vm.password, isValid: $vm.isPasswordValid, rules: [
                        LengthValidationRule(min: 1, error: "Password is required")
                    ]) { errors in
                        ForEach(errors.indices, id: \.self) { i in
                            Text(errors[i].message)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.leading)
                        }
                    })
                }
                
                Button {
                    Task {
                        await vm.signIn()
                    }
                } label: {
                    HStack {
                        Text("Sign in")
                   
                        if (!vm.isLoading) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        } else {
                            ProgressView()
                        }
                        
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .disabled(!(vm.isEmailValid && vm.isPasswordValid) || vm.isLoading)
            }
            .padding(25)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.8))
            }
            .containerRelativeFrame(.horizontal) { length, _ in
                length * 0.9
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .tint(colorScheme == .dark ? .black : .white)
            }
        }
    }
}

#Preview {
    let appState = AppState()
    let networkService = NetworkService(appState: appState, baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    SignInView(vm: SignInViewModel(authService: authService, appState: appState))
}
