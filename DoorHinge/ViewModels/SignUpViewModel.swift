//
//  SignUpViewModel.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import Foundation

@Observable
final class SignUpViewModel {
    private var networkService: NetworkService
    private var authService: AuthService
    private var appState: AppState
   
    var cityList: [String] = []
    
    var firstName = ""
    var isFirstNameValid = false
    
    var lastName = ""
    var isLastNameValid = false
    
    var email = ""
    var isEmailValid = false
    
    var password = ""
    var confirmPassword = ""
    var isPasswordValid = false
    var isConfirmPasswordValid = false
    
    var country = ""
    var countryCode: String = "" {
        didSet {
            Task {
                await getCitiesInCountry()
            }
        }
    }
    var city = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: .now)!
    
    var gender: Gender = .male
    
    var showError = false
    var errorMessage = ""
    var isLoading = false
    
    init(networkService: NetworkService, authService: AuthService, appState: AppState) {
        self.networkService = networkService
        self.authService = authService
        self.appState = appState
    }
    
    func getCitiesInCountry() async {
        do {
            cityList = []
            let response = try await networkService.get("/city?cc=\(countryCode)")
            
            switch response.status {
            case 200:
                let parsedData = try parseCodable(type: ResponseSchema<[String]>.self, from: response.data)
                
                guard let cities = parsedData.data else {
                    errorMessage = "Something went wrong in requesting the cities from the server."
                    showError = true
                    return
                }
                
                cityList = cities
                
            default:
                errorMessage = "Something went wrong in requesting the cities from the server."
                showError = true
            }
            
        } catch {
            errorMessage = "Something went wrong in requesting the cities from the server."
            showError = true
        }
    }
    
    func signUp() async {
        do {
            guard !isLoading else {
                return
            }
            
            isLoading = true
            
            try await authService.signUp(email: email, firstName: firstName, lastName: lastName, password: password, city: city, country: country, gender: gender, dateOfBirth: dateOfBirth.formatted(.iso8601.year().month().day().dateSeparator(.dash)))
            
            appState.authState = .authenticated
            
            resetForm()
            
        } catch AppError.auth(.emailTaken(let msg)) {
            errorMessage = msg
            showError = true
        } catch let err {
            errorMessage = err.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func resetForm() {
        cityList = []
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        confirmPassword = ""
        city = ""
        country = ""
        dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: .now)!
        gender = .male
    }
}
