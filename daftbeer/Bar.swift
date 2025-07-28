//
//  Bar.swift
//  daftbeer
//
//  Created by Andyne on 7/24/25.
//

import Foundation
import MapKit

struct Bar: Identifiable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var location: String
    var type: String
    let coordinate: CLLocationCoordinate2D
}
