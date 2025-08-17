import Foundation

class CSVLoader: ObservableObject {
    @Published var breweries: [Brewery] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadBreweries() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "california", withExtension: "csv") else {
            errorMessage = "Couldn't load places. Please restart the app."
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let csvString = String(data: data, encoding: .utf8) ?? ""
            let breweries = parseCSV(csvString)
            
            // Filter out breweries without valid coordinates
            let validBreweries = breweries.filter { $0.hasValidCoordinates }
            
            DispatchQueue.main.async {
                self.breweries = validBreweries
                self.isLoading = false
                
                if validBreweries.isEmpty {
                    self.errorMessage = "Couldn't load places. Please restart the app."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Couldn't load places. Please restart the app."
                self.isLoading = false
            }
        }
    }
    
    private func parseCSV(_ csvString: String) -> [Brewery] {
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }
        
        // Skip header line
        let dataLines = Array(lines.dropFirst())
        
        return dataLines.compactMap { line in
            let columns = parseCSVLine(line)
            guard columns.count >= 14 else { return nil }
            
            // Parse coordinates
            let longitude = Double(columns[12])
            let latitude = Double(columns[13])
            
            return Brewery(
                id: columns[0],
                name: columns[1],
                breweryType: columns[2],
                address1: columns[3].isEmpty ? nil : columns[3],
                address2: columns[4].isEmpty ? nil : columns[4],
                address3: columns[5].isEmpty ? nil : columns[5],
                city: columns[6].isEmpty ? nil : columns[6],
                stateProvince: columns[7].isEmpty ? nil : columns[7],
                postalCode: columns[8].isEmpty ? nil : columns[8],
                country: columns[9].isEmpty ? nil : columns[9],
                phone: columns[10].isEmpty ? nil : columns[10],
                websiteUrl: columns[11].isEmpty ? nil : columns[11],
                longitude: longitude,
                latitude: latitude
            )
        }
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            switch char {
            case "\"":
                inQuotes.toggle()
            case ",":
                if !inQuotes {
                    result.append(current.trimmingCharacters(in: .whitespaces))
                    current = ""
                } else {
                    current.append(char)
                }
            default:
                current.append(char)
            }
        }
        
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }
}
