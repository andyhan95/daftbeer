import SwiftUI
import MapKit

struct BreweryMapView: View {
    @ObservedObject var csvLoader: CSVLoader
    @StateObject private var clusteringManager = BreweryClusteringManager()
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedCluster: BreweryCluster?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683), // DTLA
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var regionUpdateTimer: Timer?
    @State private var showDebugInfo = false
    @State private var showFilterSearch = false
    @State private var showProfileSettings = false
    @State private var hasShownLocationPrompt = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: clusteringManager.clusteredBreweries) { cluster in
                MapAnnotation(coordinate: cluster.coordinate) {
                    ClusterAnnotationView(
                        cluster: cluster,
                        isSelected: selectedCluster?.id == cluster.id
                    )
                    .onTapGesture {
                        selectedCluster = cluster
                    }
                }
            }
            .ignoresSafeArea()
            .onChange(of: region.center.latitude) { _ in
                scheduleRegionUpdate()
            }
            .onChange(of: region.center.longitude) { _ in
                scheduleRegionUpdate()
            }
            .onChange(of: region.span.latitudeDelta) { _ in
                scheduleRegionUpdate()
            }
            .onChange(of: csvLoader.breweries.count) { _ in
                updateClusters()
            }
            
            // Floating buttons
            VStack {
                HStack {
                    Spacer()
                    
                    // Profile/Settings button (top-right)
                    Button(action: {
                        showProfileSettings = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.trailing)
                    .padding(.top, 60) // Account for safe area
                }
                
                Spacer()
                
                HStack {
                    // Re-center button (bottom-left)
                    Button(action: {
                        reCenterMap()
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    // Filter/Search button (bottom-right)
                    Button(action: {
                        showFilterSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.trailing)
                }
                .padding(.bottom, 40)
            }
            
            // Debug info overlay
            if showDebugInfo {
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Info")
                            .font(.headline)
                        Text("Total breweries: \(csvLoader.breweries.count)")
                        Text("Clusters: \(clusteringManager.clusteredBreweries.count)")
                        Text("Individual dots: \(clusteringManager.clusteredBreweries.filter { !$0.isCluster }.count)")
                        Text("Clustered dots: \(clusteringManager.clusteredBreweries.filter { $0.isCluster }.count)")
                        Text("Zoom level: \(String(format: "%.1f", getZoomLevel(from: region)))")
                        Text("Cluster radius: \(String(format: "%.4f", getClusterRadius(for: getZoomLevel(from: region))))")
                        Text("Location status: \(locationStatusText)")
                    }
                    .font(.caption)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding()
                }
            }
            
            // Debug toggle button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showDebugInfo.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Loading indicator
            if csvLoader.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading breweries...")
                        .font(.headline)
                        .padding(.top)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            
            // Error alert
            if let errorMessage = csvLoader.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
        .onAppear {
            if csvLoader.breweries.isEmpty {
                csvLoader.loadBreweries()
            }
            
            // Show location prompt on first launch
            if !hasShownLocationPrompt {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    locationManager.requestLocationPermission()
                    hasShownLocationPrompt = true
                }
            }
        }
        .onDisappear {
            regionUpdateTimer?.invalidate()
        }
        .sheet(isPresented: $showFilterSearch) {
            FilterSearchView()
        }
        .sheet(isPresented: $showProfileSettings) {
            ProfileSettingsView()
        }
        .sheet(item: $selectedCluster) { cluster in
            BreweryDetailView(cluster: cluster) {
                selectedCluster = nil
            }
        }
        .overlay {
            // Location prompt
            if locationManager.showLocationPrompt {
                LocationPromptView(
                    onProceed: {
                        locationManager.proceedWithLocationRequest()
                    },
                    onDismiss: {
                        locationManager.showLocationPrompt = false
                    }
                )
            }
            
            // Settings prompt
            if locationManager.showSettingsPrompt {
                SettingsPromptView(
                    onOpenSettings: {
                        locationManager.openSettings()
                    },
                    onDismiss: {
                        locationManager.showSettingsPrompt = false
                    }
                )
            }
        }
    }
    
    private var locationStatusText: String {
        switch locationManager.locationStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always"
        case .authorizedWhenInUse:
            return "When In Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func scheduleRegionUpdate() {
        regionUpdateTimer?.invalidate()
        regionUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            updateClusters()
        }
    }
    
    private func updateClusters() {
        clusteringManager.updateClusters(for: csvLoader.breweries, in: region)
    }
    
    private func reCenterMap() {
        if let userLocation = locationManager.userLocation {
            // Center on user location
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = userLocation.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
        } else if locationManager.locationStatus == .denied || locationManager.locationStatus == .restricted {
            // Show settings prompt
            locationManager.showSettingsPrompt = true
        } else {
            // Center on DTLA
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)
                region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            }
        }
    }
    
    private func getZoomLevel(from region: MKCoordinateRegion) -> Double {
        return log2(360.0 / region.span.longitudeDelta)
    }
    
    private func getClusterRadius(for zoomLevel: Double) -> Double {
        if zoomLevel > 14 {
            return 0.0001
        } else if zoomLevel > 12 {
            return 0.0005
        } else if zoomLevel > 10 {
            return 0.001
        } else {
            return 0.005
        }
    }
}

#Preview {
    BreweryMapView(csvLoader: CSVLoader())
}
