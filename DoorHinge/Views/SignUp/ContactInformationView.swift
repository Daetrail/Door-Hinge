//
//  ContactInformationView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 07/04/2026.
//

import SwiftUI
import ValidatorCore

struct ContactInformationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var navigationPath: NavigationPath
    @Bindable private var vm: SignUpViewModel
    
    init(vm: SignUpViewModel, navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            Image(.onboardingBackground)
                .resizable()
                .blur(radius: 10)
            
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Text("Contact")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("Get emails about getting matched up and protect your account with a secure password.")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                }
                
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
                        LengthValidationRule(min: 8, max: 32, error: "Between 8 and 32 characters long"),
                        RegexValidationRule(pattern: "[A-Z]", error: "Must have a uppercase character"),
                        RegexValidationRule(pattern: "[a-z]", error: "Must have a lowercase character"),
                        RegexValidationRule(pattern: "[0-9]", error: "Must have a digit character"),
                        RegexValidationRule(pattern: "[#?!@$%^&*-]", error: "Must have at least one of the following symbols: #?!@$%^&*-"),
                        RegexValidationRule(pattern: #"^[\x00-\x7F]+$"#, error: "Must only consist of ASCII characters")
                    ]) { errors in
                        ForEach(errors.indices, id: \.self) { i in
                            Text(errors[i].message)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.leading)
                        }
                    })
                    
                    InputField(iconSystemName: "key") {
                        SecureField("", text: $vm.confirmPassword, prompt: Text("Confirm password").foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)))
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .modifier(FieldValidation(text: $vm.confirmPassword, isValid: $vm.isConfirmPasswordValid, rules: [
                        EqualityValidationRule(compareTo: vm.password, error: "Must match password"),
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
                        await vm.signUp()
                    }
                } label: {
                    HStack {
                        Text("Finish")
                   
                        if !vm.isLoading {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        } else {
                            ProgressView()
                        }
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .disabled(!(vm.isEmailValid && vm.isPasswordValid && vm.isConfirmPasswordValid) || vm.isLoading)
            }
            .padding(25)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.horizontal) { length, _ in
                length * 0.9
            }
        }
        .ignoresSafeArea()
        .alert("Error", isPresented: $vm.showError) {
            Button(role: .confirm) {
                Task {
                    await vm.getCitiesInCountry()
                }
            } label: {
                Text("Retry")
            }
            
            Button(role: .cancel) {
                
            } label: {
                Text("Dismiss")
            }
        } message: {
            Text(vm.errorMessage)
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    let appState = AppState()
    let networkService = NetworkService(appState: appState, baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    NavigationStack {
        ContactInformationView(vm: SignUpViewModel(networkService: networkService, authService: authService, appState: appState), navigationPath: $navigationPath)
    }
}
