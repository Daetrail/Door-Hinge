//
//  LocationInformationView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 07/04/2026.
//

import SwiftUI

struct LocationInformationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var navigationPath: NavigationPath
    @Bindable private var vm: SignUpViewModel
   
    static let excludedRegions: Set<String> = [
        "AC", // Ascension Island
        "AQ", // Antarctica
        "BV", // Bouvet Island
        "CP", // Clipperton Island
        "CQ", // Sark
        "DG", // Diego Garcia
        "EA", // Ceuta & Melilla
        "EU", // European Union
        "EZ", // Eurozone
        "GS", // So. Georgia & So. Sandwich Isl.
        "HM", // Heard & McDonald Islands
        "IC", // Canary Islands
        "IO", // Chagos Archipelago
        "NF", // Norfolk Island
        "PN", // Pitcairn Islands
        "QO", // Outlying Oceania
        "SJ", // Svalbard & Jan Mayen
        "TA", // Tristan da Cunha
        "TF", // French Southern Territories
        "TK", // Tokelau
        "UM", // US Outlying Islands
        "UN", // United Nations
        "XK", // Kosovo
    ]
    
    let countries = Locale.Region.isoRegions
        .filter {
            $0.identifier.count == 2 &&
            $0.identifier.allSatisfy(\.isLetter) &&
            !excludedRegions.contains($0.identifier)}
        .compactMap {
            Locale.current.localizedString(forRegionCode: $0.identifier)
        }
        .sorted()
    
    @State private var showCountryPicker = false
    @State private var searchText = ""
    
    @State private var showCityPicker = false
    @State private var citySearchText = ""
    
    var filteredCountries: [String] {
        if searchText.isEmpty { return countries }
        return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredCities: [String] {
        if citySearchText.isEmpty { return vm.cityList }
        return vm.cityList.filter { $0.localizedCaseInsensitiveContains(citySearchText) }
    }
    
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
                    Text("Location")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("Match with people in your city.")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Country")
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black)
                            .padding(.leading)
                            
                        InputField(iconSystemName: "globe") {
                            Button {
                                showCountryPicker = true
                            } label: {
                                HStack {
                                    if colorScheme == .light {
                                        Text(vm.country.isEmpty ? "Select a country" : vm.country)
                                            .foregroundStyle(vm.country.isEmpty ? .black.opacity(0.5) : .gray)
                                    } else {
                                        Text(vm.country.isEmpty ? "Select a country" : vm.country)
                                            .foregroundStyle(vm.country.isEmpty ? .white.opacity(0.5) : .gray)
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.black.opacity(0.5))
                                }
                            }
                        }
                        .sheet(isPresented: $showCountryPicker) {
                            NavigationStack {
                                List(filteredCountries, id: \.self) { country in
                                    Button {
                                        vm.country = country
                                        vm.countryCode = Locale.Region.isoRegions.first { region in
                                            Locale.current.localizedString(forRegionCode: region.identifier) == country
                                        }?.identifier ?? "GB"
                                        print(vm.countryCode)
                                        vm.city = ""
                                        showCountryPicker = false
                                    } label: {
                                        Text(country)
                                            .foregroundStyle(.primary)
                                    }
                                    .tint(.primary)
                                }
                                .searchable(text: $searchText, prompt: "Search countries")
                                .overlay {
                                    if filteredCountries.isEmpty {
                                        ContentUnavailableView.search(text: searchText)
                                    }
                                }
                                .navigationTitle("Select Country")
                                .navigationBarTitleDisplayMode(.inline)
                            }
                            .presentationDetents([.medium])
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("City")
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black)
                            .padding(.leading)
                        
                        InputField(iconSystemName: "location") {
                            Button {
                                showCityPicker = true
                            } label: {
                                HStack {
                                    switch (vm.country, colorScheme) {
                                    case let (c, cs) where c.isEmpty && cs == .light:
                                        Text(vm.city.isEmpty ? "Pick a country first" : vm.city)
                                            .foregroundStyle(vm.city.isEmpty ? .black.opacity(0.5) : .gray)
                                    case let (c, cs) where c.isEmpty && cs == .dark:
                                        Text(vm.city.isEmpty ? "Pick a country first" : vm.city)
                                            .foregroundStyle(vm.city.isEmpty ? .white.opacity(0.5) : .gray)
                                    case (_, .light):
                                        Text(vm.city.isEmpty ? "Select a city" : vm.city)
                                            .foregroundStyle(vm.city.isEmpty ? .black.opacity(0.5) : .gray)
                                    case (_, .dark):
                                        Text(vm.city.isEmpty ? "Select a city" : vm.city)
                                            .foregroundStyle(vm.country.isEmpty ? .white.opacity(0.5) : .gray)
                                    default:
                                        Text(vm.city.isEmpty ? "Select a city" : vm.city)
                                            .foregroundStyle(vm.country.isEmpty ? .white.opacity(0.5) : .gray)
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.black.opacity(0.5))
                                }
                            }
                            .disabled(vm.cityList.isEmpty)
                        }
                        .sheet(isPresented: $showCityPicker) {
                            NavigationStack {
                                List(filteredCities, id: \.self) { city in
                                    Button {
                                        vm.city = city
                                        showCityPicker = false
                                    } label: {
                                        Text(city)
                                            .foregroundStyle(.primary)
                                    }
                                    .tint(.primary)
                                }
                                .searchable(text: $citySearchText, prompt: "Search cities")
                                .overlay {
                                    if filteredCities.isEmpty {
                                        ContentUnavailableView.search(text: citySearchText)
                                    }
                                }
                                .navigationTitle("Select City")
                                .navigationBarTitleDisplayMode(.inline)
                            }
                            .presentationDetents([.medium])
                        }
                        .overlay {
                            if vm.cityList.isEmpty {
                                Capsule()
                                    .fill(.black.opacity(0.3))
                            }
                        }
                    }
                }
                
                Button {
                    navigationPath.append(SignUpRoutes.contactInformation)
                    
                } label: {
                    HStack {
                        Text("Continue")
                    
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .disabled(vm.city.isEmpty || vm.country.isEmpty)
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
        LocationInformationView(vm: SignUpViewModel(networkService: networkService, authService: authService, appState: appState), navigationPath: $navigationPath)
    }
}
