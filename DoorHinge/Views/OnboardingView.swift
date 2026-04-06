//
//  OnboardingView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            Image(.onboardingBackground)
                
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Find your match")
                                .font(.system(size: 40, weight: .bold, design: .serif))
                                .foregroundStyle(.white)
                            
                            Text("You won't be single anymore :)")
                                .font(.system(size: 18, weight: .light, design: .serif))
                                .foregroundStyle(.white)
                        }
                        
                        
                        HStack {
                            Button {
                                
                            } label: {
                                Text("Sign in")
                                    .font(.title3)
                                    .padding(.horizontal, 7)
                                    
                            }
                            .buttonStyle(.glass)
                            .padding(.trailing, 10)
                            
                            Button {
                                
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
                        .fill(.black.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(20)
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
}
