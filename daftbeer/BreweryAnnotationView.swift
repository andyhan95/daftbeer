import SwiftUI
import MapKit

struct BreweryAnnotationView: View {
    let brewery: Brewery
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Beer icon
            Image(systemName: "mug.fill")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .white : .orange)
                .background(
                    Circle()
                        .fill(isSelected ? .orange : .white)
                        .frame(width: 32, height: 32)
                        .shadow(radius: 2)
                )
            
            // Selection indicator
            if isSelected {
                Circle()
                    .fill(.orange)
                    .frame(width: 8, height: 8)
                    .offset(y: -2)
            }
        }
    }
}

#Preview {
    BreweryAnnotationView(
        brewery: Brewery(
            id: "test",
            name: "Test Brewery",
            breweryType: "micro",
            address1: nil,
            address2: nil,
            address3: nil,
            city: nil,
            stateProvince: nil,
            postalCode: nil,
            country: nil,
            phone: nil,
            websiteUrl: nil,
            longitude: -118.243683,
            latitude: 34.052235
        ),
        isSelected: false
    )
}
