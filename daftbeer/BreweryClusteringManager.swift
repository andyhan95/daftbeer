import Foundation
import MapKit

class BreweryClusteringManager: ObservableObject {
    @Published var clusteredBreweries: [BreweryCluster] = []
    private var lastUpdateRegion: MKCoordinateRegion?
    private var lastUpdateBreweries: [Brewery] = []
    
    func updateClusters(for breweries: [Brewery], in region: MKCoordinateRegion) {
        // Skip update if nothing has changed
        if breweries == lastUpdateBreweries && 
           lastUpdateRegion?.center.latitude == region.center.latitude &&
           lastUpdateRegion?.center.longitude == region.center.longitude &&
           lastUpdateRegion?.span.latitudeDelta == region.span.latitudeDelta {
            return
        }
        
        // Store current state
        lastUpdateBreweries = breweries
        lastUpdateRegion = region
        
        // Perform clustering on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let clusters = self?.performClustering(for: breweries, in: region) ?? []
            
            DispatchQueue.main.async {
                self?.clusteredBreweries = clusters
            }
        }
    }
    
    private func performClustering(for breweries: [Brewery], in region: MKCoordinateRegion) -> [BreweryCluster] {
        let zoomLevel = getZoomLevel(from: region)
        let clusterRadius = getClusterRadius(for: zoomLevel)
        
        // Filter breweries to only those in the visible region (with some padding)
        let visibleBreweries = breweries.filter { brewery in
            guard brewery.hasValidCoordinates else { return false }
            
            let coord = brewery.coordinate!
            return coord.latitude >= region.center.latitude - region.span.latitudeDelta * 0.6 &&
                   coord.latitude <= region.center.latitude + region.span.latitudeDelta * 0.6 &&
                   coord.longitude >= region.center.longitude - region.span.longitudeDelta * 0.6 &&
                   coord.longitude <= region.center.longitude + region.span.longitudeDelta * 0.6
        }
        
        // Use spatial partitioning for efficient clustering
        let gridSize = max(clusterRadius * 2, 0.001) // Grid cells slightly larger than cluster radius
        var grid: [String: [Brewery]] = [:]
        
        // Assign breweries to grid cells
        for brewery in visibleBreweries {
            guard brewery.hasValidCoordinates else { continue }
            let coord = brewery.coordinate!
            let gridKey = "\(Int(coord.latitude / gridSize))_\(Int(coord.longitude / gridSize))"
            
            if grid[gridKey] == nil {
                grid[gridKey] = []
            }
            grid[gridKey]?.append(brewery)
        }
        
        var clusters: [BreweryCluster] = []
        var processedBreweries = Set<String>()
        
        // Process each grid cell
        for (_, cellBreweries) in grid {
            if cellBreweries.count == 1 {
                // Single brewery - no clustering needed
                let brewery = cellBreweries[0]
                if !processedBreweries.contains(brewery.id) {
                    let cluster = BreweryCluster(
                        coordinate: brewery.coordinate!,
                        breweries: [brewery],
                        isCluster: false
                    )
                    clusters.append(cluster)
                    processedBreweries.insert(brewery.id)
                }
            } else {
                // Multiple breweries in cell - check for clustering
                
                for brewery in cellBreweries {
                    if processedBreweries.contains(brewery.id) { continue }
                    
                    // Find nearby breweries within cluster radius
                    var nearbyBreweries: [Brewery] = []
                    for otherBrewery in cellBreweries {
                        if otherBrewery.id == brewery.id || processedBreweries.contains(otherBrewery.id) { continue }
                        
                        let distance = calculateFastDistance(
                            from: brewery.coordinate!,
                            to: otherBrewery.coordinate!
                        )
                        
                        if distance <= clusterRadius {
                            nearbyBreweries.append(otherBrewery)
                        }
                    }
                    
                    if nearbyBreweries.isEmpty {
                        // Single brewery
                        let cluster = BreweryCluster(
                            coordinate: brewery.coordinate!,
                            breweries: [brewery],
                            isCluster: false
                        )
                        clusters.append(cluster)
                        processedBreweries.insert(brewery.id)
                    } else {
                        // Create cluster
                        let clusterBreweries = [brewery] + nearbyBreweries
                        
                        // Calculate center point
                        let avgLat = clusterBreweries.map { $0.coordinate!.latitude }.reduce(0, +) / Double(clusterBreweries.count)
                        let avgLon = clusterBreweries.map { $0.coordinate!.longitude }.reduce(0, +) / Double(clusterBreweries.count)
                        let clusterCenter = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
                        
                        let cluster = BreweryCluster(
                            coordinate: clusterCenter,
                            breweries: clusterBreweries,
                            isCluster: true
                        )
                        clusters.append(cluster)
                        
                        // Mark all as processed
                        for clusterBrewery in clusterBreweries {
                            processedBreweries.insert(clusterBrewery.id)
                        }
                    }
                }
            }
        }
        
        return clusters
    }
    
    // Much faster distance calculation using Haversine formula
    private func calculateFastDistance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        let lat1 = coord1.latitude * .pi / 180
        let lat2 = coord2.latitude * .pi / 180
        let deltaLat = (coord2.latitude - coord1.latitude) * .pi / 180
        let deltaLon = (coord2.longitude - coord1.longitude) * .pi / 180
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return 6371000 * c // Earth radius in meters
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
