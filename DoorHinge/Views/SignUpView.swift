//
//  SignUpView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI

struct SignUpView: View {
    @Bindable private var vm: SignUpViewModel
    
    init(vm: SignUpViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            Image(.onboardingBackground)
            
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Text("Sign up")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    
                    Text("Start your dating journey today")
                        .font(.system(size: 18, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("First name")
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.leading)
                            
                        InputField(iconSystemName: "f.circle") {
                            TextField("First name", text: $vm.firstName)
                                .textContentType(.name)
                                .textInputAutocapitalization(.words)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Last name")
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.leading)
                        
                        InputField(iconSystemName: "l.circle") {
                            TextField("Last name", text: $vm.lastName)
                                .textContentType(.name)
                                .textInputAutocapitalization(.words)
                        }
                    }
                    
                    
                    InputField(iconSystemName: "envelope") {
                        TextField("Email", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    InputField(iconSystemName: "key") {
                        SecureField("Password", text: $vm.password)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    Divider()
                   
                    InputField(iconSystemName: "person") {
                        Text("Gender")
                            .foregroundStyle(.gray)
                       
                        Spacer()
                        
                        HStack {
                            Picker(selection: $vm.gender) {
                                Text("Male").tag(Gender.male)
                                Text("Female").tag(Gender.female)
                                Text("Gay").tag(Gender.gay)
                                Text("Lesbian").tag(Gender.lesbian)
                                Text("Non-bin").tag(Gender.nonBinary)
                                Text("Trans").tag(Gender.trans)
                            } label: {
                                Text("Gender")
                                Text("Select the gender you identify as")
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    
                    
                }
            }
            .padding(25)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.6))
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    let networkService = NetworkService(baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    SignUpView(vm: SignUpViewModel(authService: authService))
}
