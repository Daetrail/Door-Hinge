//
//  SignUpView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI

enum SignUpRoutes: Hashable {
    case personalInformation
    case locationInformation
    case contactInformation
}

struct SignUpView: View {
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
                Text("Sign up")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    Text("To start your dating journey, we need some details about you.")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                   
                    Text("This is so we can match you with a potential date much faster.")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personal information is securely stored in our servers. No third parties have any access to it.")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    navigationPath.append(SignUpRoutes.personalInformation)
                } label: {
                    HStack {
                        Text("Continue")
                    
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
            }
            .padding(25)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.6))
            }
            .containerRelativeFrame(.horizontal) { length, _ in
                length * 0.9
            }
        }
        .navigationDestination(for: SignUpRoutes.self) { route in
            switch route {
            case .personalInformation:
                PersonalInformationView(vm: vm, navigationPath: $navigationPath)
            case .locationInformation:
                LocationInformationView(vm: vm, navigationPath: $navigationPath)
            case .contactInformation:
                ContactInformationView(vm: vm, navigationPath: $navigationPath)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    let networkService = NetworkService(baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    let appState = AppState()
    
    NavigationStack(path: $navigationPath) {
        SignUpView(vm: SignUpViewModel(networkService: networkService, authService: authService, appState: appState), navigationPath: $navigationPath)
    }
}
