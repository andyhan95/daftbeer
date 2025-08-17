import SwiftUI
import MapKit

struct ClusterAnnotationView: View {
    let cluster: BreweryCluster
    let isSelected: Bool
    
    var body: some View {
        if cluster.isCluster {
            // Cluster view
            ZStack {
                Circle()
                    .fill(isSelected ? .orange : .blue)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 2)
                
                Text("\(cluster.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        } else {
            // Single brewery view
            BreweryAnnotationView(
                brewery: cluster.breweries.first!,
                isSelected: isSelected
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ClusterAnnotationView(
            cluster: BreweryCluster(
                coordinate: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
                breweries: [
                    Brewery(
                        id: "1",
                        name: "Test Brewery 1",
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
                    Brewery(
                        id: "2",
                        name: "Test Brewery 2",
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
                    )
                ],
                isCluster: true
            ),
            isSelected: false
        )
        
        ClusterAnnotationView(
            cluster: BreweryCluster(
                coordinate: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
                breweries: [
                    Brewery(
                        id: "1",
                        name: "Single Brewery",
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
                    )
                ],
                isCluster: false
            ),
            isSelected: false
        )
    }
}
