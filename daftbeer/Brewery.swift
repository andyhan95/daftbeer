import Foundation
import CoreLocation

struct Brewery: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let breweryType: String
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let stateProvince: String?
    let postalCode: String?
    let country: String?
    let phone: String?
    let websiteUrl: String?
    let longitude: Double?
    let latitude: Double?
    
    // Computed property for full address
    var fullAddress: String {
        var components: [String] = []
        
        if let address1 = address1, !address1.isEmpty {
            components.append(address1)
        }
        if let address2 = address2, !address2.isEmpty {
            components.append(address2)
        }
        if let address3 = address3, !address3.isEmpty {
            components.append(address3)
        }
        
        var cityStateZip: [String] = []
        if let city = city, !city.isEmpty {
            cityStateZip.append(city)
        }
        if let state = stateProvince, !state.isEmpty {
            cityStateZip.append(state)
        }
        if let postalCode = postalCode, !postalCode.isEmpty {
            cityStateZip.append(postalCode)
        }
        
        if !cityStateZip.isEmpty {
            components.append(cityStateZip.joined(separator: ", "))
        }
        
        return components.isEmpty ? "No Address Available" : components.joined(separator: ", ")
    }
    
    // Computed property for coordinate
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // Check if brewery has valid coordinates
    var hasValidCoordinates: Bool {
        return coordinate != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breweryType = "brewery_type"
        case address1 = "address_1"
        case address2 = "address_2"
        case address3 = "address_3"
        case city
        case stateProvince = "state_province"
        case postalCode = "postal_code"
        case country
        case phone
        case websiteUrl = "website_url"
        case longitude
        case latitude
    }
    
    // Equatable conformance
    static func == (lhs: Brewery, rhs: Brewery) -> Bool {
        return lhs.id == rhs.id
    }
}
