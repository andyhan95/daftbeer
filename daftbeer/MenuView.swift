//
//  ContentView.swift
//  daftbeer
//
//  Created by Andyne on 7/22/25.
//

import SwiftUI
import MapKit

struct MenuView: View {
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.0765, longitude: -118.3088),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ) // By default, the map is centered at the now defunct Southland Beer as an homage
    )
    @State var barItems:[Bar] = [Bar]()
    var dataService = DataService()
    
    var body: some View {
        ZStack {
            Color(.gray).ignoresSafeArea()
            VStack {
                Map(position: $position) {
                        }
                List(barItems) { item in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(item.name).bold()
                                    Spacer()
                                    Text("\(item.price.formatted(.currency(code: "USD"))) and up")
                                }
                                HStack {
                                    Text(item.location).font(.caption)
                                    Spacer()
                                    Text(item.type).font(.caption)
                                }
                            }.listRowBackground(Color(.lightGray))
                        }.listStyle(.plain).onAppear(){
                            barItems = dataService.getData()
                        }
                    }
                }
            }
        }
        
        #Preview {
            MenuView()
        }
