import SwiftUI

struct FilterSearchView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Filter & Search")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Search and filter breweries by type, location, and more.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Filter & Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Profile & Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Manage your profile and app preferences.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FilterSearchView()
        ProfileSettingsView()
    }
}
