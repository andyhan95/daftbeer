import SwiftUI
import CoreLocation

struct BreweryDetailView: View {
    let cluster: BreweryCluster
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var showWebsiteError = false
    
    private let maxDragOffset: CGFloat = 200
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(.secondary)
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with back button
                        HStack {
                            Button(action: onDismiss) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if cluster.isCluster {
                            // Cluster view
                            VStack(alignment: .leading, spacing: 16) {
                                Text("\(cluster.count) Breweries")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Tap to see individual breweries")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                // Show first few breweries as preview
                                ForEach(Array(cluster.breweries.prefix(3)), id: \.id) { brewery in
                                    HStack {
                                        Image(systemName: "mug.fill")
                                            .foregroundColor(.orange)
                                            .frame(width: 20)
                                        
                                        Text(brewery.name)
                                            .font(.body)
                                        
                                        Spacer()
                                    }
                                }
                                
                                if cluster.breweries.count > 3 {
                                    Text("+ \(cluster.breweries.count - 3) more")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            // Single brewery view
                            let brewery = cluster.breweries.first!
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // Name
                                Text(brewery.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                // Type
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text(brewery.breweryType.capitalized)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Address
                                HStack(alignment: .top) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 20)
                                    
                                    Text(brewery.fullAddress)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                // Phone (if available)
                                if let phone = brewery.phone, !phone.isEmpty {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        
                                        Button(action: {
                                            if let url = URL(string: "tel:\(phone)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Text(formatPhoneNumber(phone))
                                                .font(.body)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                
                                // Website (if available)
                                if let website = brewery.websiteUrl, !website.isEmpty {
                                    HStack {
                                        Image(systemName: "globe")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        
                                        Button(action: {
                                            openWebsite(website)
                                        }) {
                                            Text("Visit Website")
                                                .font(.body)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .background(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > maxDragOffset {
                                onDismiss()
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
        }
        .alert("Can't open website", isPresented: $showWebsiteError) {
            Button("OK") { }
        } message: {
            Text("The website link couldn't be opened.")
        }
    }
    
    private func formatPhoneNumber(_ phone: String) -> String {
        // Simple phone number formatting
        let cleaned = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleaned.count == 10 {
            let index = cleaned.index(cleaned.startIndex, offsetBy: 3)
            let index2 = cleaned.index(cleaned.startIndex, offsetBy: 6)
            return "(\(cleaned[..<index])) \(cleaned[index..<index2])-\(cleaned[index2...])"
        } else if cleaned.count == 11 && cleaned.hasPrefix("1") {
            let index = cleaned.index(cleaned.startIndex, offsetBy: 1)
            let index2 = cleaned.index(cleaned.startIndex, offsetBy: 4)
            let index3 = cleaned.index(cleaned.startIndex, offsetBy: 7)
            return "(\(cleaned[index..<index2])) \(cleaned[index2..<index3])-\(cleaned[index3...])"
        }
        
        return phone
    }
    
    private func openWebsite(_ urlString: String) {
        var urlString = urlString
        
        // Add https if no protocol specified
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        guard let url = URL(string: urlString) else {
            showWebsiteError = true
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showWebsiteError = true
        }
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    BreweryDetailView(
        cluster: BreweryCluster(
            coordinate: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
            breweries: [
                Brewery(
                    id: "1",
                    name: "Test Brewery",
                    breweryType: "micro",
                    address1: "123 Main St",
                    address2: nil,
                    address3: nil,
                    city: "Los Angeles",
                    stateProvince: "CA",
                    postalCode: "90210",
                    country: "US",
                    phone: "5551234567",
                    websiteUrl: "https://example.com",
                    longitude: -118.243683,
                    latitude: 34.052235
                )
            ],
            isCluster: false
        ),
        onDismiss: {}
    )
}
