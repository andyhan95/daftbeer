import Foundation
import MapKit

class BreweryClusteringManager: ObservableObject {
    @Published var clusteredBreweries: [BreweryCluster] = []
    
    func updateClusters(for breweries: [Brewery], in region: MKCoordinateRegion) {
        let zoomLevel = getZoomLevel(from: region)
        let clusterRadius = getClusterRadius(for: zoomLevel)
        
        var clusters: [BreweryCluster] = []
        var processedBreweries = Set<String>()
        
        for brewery in breweries {
            guard brewery.hasValidCoordinates else { continue }
            
            if processedBreweries.contains(brewery.id) { continue }
            
            // Find nearby breweries within cluster radius
            let nearbyBreweries = breweries.filter { otherBrewery in
                guard otherBrewery.hasValidCoordinates else { return false }
                guard otherBrewery.id != brewery.id else { return false }
                
                let distance = calculateDistance(
                    from: brewery.coordinate!,
                    to: otherBrewery.coordinate!
                )
                
                return distance <= clusterRadius
            }
            
            if nearbyBreweries.isEmpty {
                // Single brewery - no clustering needed
                let cluster = BreweryCluster(
                    coordinate: brewery.coordinate!,
                    breweries: [brewery],
                    isCluster: false
                )
                clusters.append(cluster)
                processedBreweries.insert(brewery.id)
            } else {
                // Create cluster with nearby breweries
                var clusterBreweries = [brewery] + nearbyBreweries
                
                // Calculate center point of cluster
                let avgLat = clusterBreweries.map { $0.coordinate!.latitude }.reduce(0, +) / Double(clusterBreweries.count)
                let avgLon = clusterBreweries.map { $0.coordinate!.longitude }.reduce(0, +) / Double(clusterBreweries.count)
                let clusterCenter = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
                
                let cluster = BreweryCluster(
                    coordinate: clusterCenter,
                    breweries: clusterBreweries,
                    isCluster: true
                )
                clusters.append(cluster)
                
                // Mark all breweries in this cluster as processed
                for clusterBrewery in clusterBreweries {
                    processedBreweries.insert(clusterBrewery.id)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.clusteredBreweries = clusters
        }
    }
    
    private func calculateDistance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2)
    }
    
    private func getZoomLevel(from region: MKCoordinateRegion) -> Double {
        return log2(360.0 / region.span.longitudeDelta)
    }
    
    private func getClusterRadius(for zoomLevel: Double) -> Double {
        // Much more conservative clustering - only cluster when breweries are very close
        if zoomLevel > 16 {
            return 5.0 // 5 meters - only cluster if breweries are literally touching
        } else if zoomLevel > 14 {
            return 10.0 // 10 meters - very close proximity
        } else if zoomLevel > 12 {
            return 25.0 // 25 meters - close proximity
        } else if zoomLevel > 10 {
            return 50.0 // 50 meters - moderate proximity
        } else {
            return 100.0 // 100 meters - only cluster when zoomed way out
        }
    }
}

struct BreweryCluster: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let breweries: [Brewery]
    let isCluster: Bool
    
    var count: Int {
        return breweries.count
    }
    
    var displayName: String {
        if isCluster {
            return "\(count) breweries"
        } else {
            return breweries.first?.name ?? "Unknown"
        }
    }
}
