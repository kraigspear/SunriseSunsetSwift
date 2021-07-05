//
//  ContentViewModel.swift
//  SunriseSunsetTest
//
//  Created by Kraig Spear on 7/5/21.
//

import SwiftUI
import Combine
import CoreLocation
import SunriseSunset
import XCTest

final class ContentViewModel: ObservableObject {

    @Published var latitude = ""
    @Published var longitude = ""

    @Published var errorMessage = ""
    @Published var result = ""

    init() {
        load()
    }

    func calculate() {
        let lat = Double(latitude)!
        let lng = Double(longitude)!
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let sunResult = SunriseSunset.calc(date: Date(), coordinate: coordinate)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium

        result = "􀆱 \(dateFormatter.string(from: sunResult.sunrise)) 􀆳 \(dateFormatter.string(from: sunResult.sunset))"

        save()
    }


    // MARK: - User Defaults

    private let latKey = "latitude"
    private let lngKey = "longitude"

    private func load() {
        latitude = UserDefaults.standard.string(forKey: latKey) ?? ""
        longitude = UserDefaults.standard.string(forKey: lngKey) ?? ""
    }

    private func save() {
        UserDefaults.standard.set(latitude, forKey: latKey)
        UserDefaults.standard.set(longitude, forKey: lngKey)
    }
}
