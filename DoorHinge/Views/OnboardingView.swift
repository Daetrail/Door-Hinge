//
//  OnboardingView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI
    
enum OnboardingRoutes: Hashable {
    case signUp
    case signIn
}

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var navigationPath = NavigationPath()
    @State private var signUpVM: SignUpViewModel
    @State private var signInVM: SignInViewModel
    
    init(networkService: NetworkService, authService: AuthService, appState: AppState) {
        signUpVM = SignUpViewModel(networkService: networkService, authService: authService, appState: appState)
        signInVM = SignInViewModel(authService: authService, appState: appState)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
             ZStack {
                Image(.onboardingBackground)
                    .resizable()                    
                    
                VStack {
                    ForEach(0..<10) { _ in
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Find your match")
                                    .font(.system(size: 40, weight: .bold, design: .serif))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Text("You won't be single anymore :)")
                                    .font(.system(size: 18, weight: .light, design: .serif))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            
                            
                            HStack {
                                Button {
                                    navigationPath.append(OnboardingRoutes.signIn)
                                } label: {
                                    Text("Sign in")
                                        .font(.title3)
                                        .padding(.horizontal, 7)
                                        
                                }
                                .buttonStyle(.glass)
                                .padding(.trailing, 10)
                                
                                
                                Button {
                                    navigationPath.append(OnboardingRoutes.signUp)
                                } label: {
                                    Text("Sign up")
                                        .font(.title3)
                                        .padding(.horizontal, 7)
                                        
                                }
                                .buttonStyle(.glassProminent)
                                .tint(.orange)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(20)
                
            }
            .ignoresSafeArea()
            .navigationDestination(for: OnboardingRoutes.self) { route in
                switch route {
                case .signUp:
                    SignUpView(vm: signUpVM, navigationPath: $navigationPath)
                case .signIn:
                    SignInView(vm: signInVM)
                }
            }
        }
    }
}

#Preview {
    let appState = AppState()
    let networkService = NetworkService(appState: appState, baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    OnboardingView(networkService: networkService, authService: authService, appState: appState)
}
