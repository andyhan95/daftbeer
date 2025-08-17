import SwiftUI

struct LocationPromptView: View {
    let onProceed: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Share your location for the best experience")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("We'll use your location to show you nearby breweries and center the map on your area.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button("Okay") {
                        onProceed()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
}

struct SettingsPromptView: View {
    let onOpenSettings: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                Image(systemName: "location.slash.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Location Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("To show you nearby breweries, please enable location access in Settings.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button("No Thanks") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Sure") {
                        onOpenSettings()
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LocationPromptView(
            onProceed: {},
            onDismiss: {}
        )
        
        SettingsPromptView(
            onOpenSettings: {},
            onDismiss: {}
        )
    }
}
