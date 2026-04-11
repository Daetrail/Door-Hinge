//
//  PersonalInformationView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 07/04/2026.
//

import SwiftUI
import ValidatorUI
import ValidatorCore

struct PersonalInformationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var navigationPath: NavigationPath
    @Bindable private var vm: SignUpViewModel
    
    @State private var eighteenYearsAgo = Calendar.current.date(byAdding: .year, value: -18, to: .now)!
    
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
                    Text("Basic")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("Let your potential matches know your name and gender.")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 10) {
                    InputField(iconSystemName: "f.circle") {
                        TextField("", text: $vm.firstName, prompt: Text("First name").foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)))
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                    }
                    .modifier(FieldValidation(text: $vm.firstName, isValid: $vm.isFirstNameValid, rules: [
                        LengthValidationRule(min: 1, error: "First name is required")
                    ]) { errors in
                        ForEach(errors.indices, id: \.self) { i in
                            Text(errors[i].message)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.leading)
                        }
                    })
                    
                    InputField(iconSystemName: "l.circle") {
                        TextField("", text: $vm.lastName, prompt: Text("Last name").foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)))
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                    }
                    .modifier(FieldValidation(text: $vm.lastName, isValid: $vm.isLastNameValid, rules: [
                        LengthValidationRule(min: 1, error: "First name is required")
                    ]) { errors in
                        ForEach(errors.indices, id: \.self) { i in
                            Text(errors[i].message)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.leading)
                        }
                    })
                    
                    InputField(iconSystemName: "person") {
                        Text("Gender")
                            .foregroundStyle(colorScheme == .dark ? .gray : .black)
                       
                        Spacer()
                        
                        Menu {
                            Button("Transgender") {
                                vm.gender = Gender.trans
                            }
                            Button("Non-binary") {
                                vm.gender = Gender.nonBinary
                            }
                            Button("Lesbian") {
                                vm.gender = Gender.lesbian
                            }
                            Button("Gay") {
                                vm.gender = Gender.gay
                            }
                            Button("Female") {
                                vm.gender = Gender.female
                            }
                            Button("Male") {
                                vm.gender = Gender.male
                            }
                        } label: {
                            HStack {
                                ZStack {
                                    Text("Transgender").hidden()
                                    
                                    Group {
                                        switch vm.gender {
                                        case .male:
                                            Text("Male")
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .female:
                                            Text("Female")
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .gay:
                                            Text("Gay")
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .lesbian:
                                            Text("Lesbian")
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .nonBinary:
                                            Text("Non-binary")
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .trans:
                                            Text("Transgender")
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                        
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                Image(systemName: "chevron.up.chevron.down")
                            }
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black)
                        }
                    }
                
                    InputField(iconSystemName: "calendar") {
                        Text("Birthday")
                            .foregroundStyle(colorScheme == .dark ? .gray : .black)
                        
                        Spacer()
                        
                        DatePicker("Date of Birth", selection: $vm.dateOfBirth, in: ...eighteenYearsAgo, displayedComponents: .date)
                            .tint(.orange)
                            .labelsHidden()
                            .scaleEffect(0.85, anchor: .trailing)
                            .frame(width: 110, height: 25, alignment: .trailing)
                            .tint(colorScheme == .dark ? .white.opacity(0.7) : .black)
                    }
                }
                
                Button {
                    navigationPath.append(SignUpRoutes.locationInformation)
                } label: {
                    HStack {
                        Text("Continue")
                    
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .disabled(!(vm.isFirstNameValid && vm.isLastNameValid))
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
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    let appState = AppState()
    let networkService = NetworkService(appState: appState, baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    NavigationStack {
        PersonalInformationView(vm: SignUpViewModel(networkService: networkService, authService: authService, appState: appState), navigationPath: $navigationPath)
    }
}
