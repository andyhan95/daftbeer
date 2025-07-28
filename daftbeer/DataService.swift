//
//  DataService.swift
//  daftbeer
//
//  Created by Andyne on 7/25/25.
//

import Foundation
import MapKit

struct DataService {
    func getData() -> [Bar] {
        return [
            Bar(name: "Father's Office", price: 12.50, location: "Culver City", type: "Craft", coordinate: CLLocationCoordinate2D(latitude: 34.021179, longitude: -118.394371)
),
            Bar(name: "Wurstküche", price: 8.99, location: "Arts District", type: "European", coordinate: CLLocationCoordinate2D(latitude: 34.044119, longitude: -118.236502)
),
            Bar(name: "Homage Brewing", price: 9.99, location: "Chinatown", type: "Microbrew", coordinate: CLLocationCoordinate2D(latitude: 34.062930, longitude: -118.235370))
]
    }
}
