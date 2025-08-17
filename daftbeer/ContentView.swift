//
//  ContentView.swift
//  daftbeer
//
//  Created by Andyne on 7/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var csvLoader = CSVLoader()
    
    var body: some View {
        BreweryMapView(csvLoader: csvLoader)
    }
}

#Preview {
    ContentView()
}
