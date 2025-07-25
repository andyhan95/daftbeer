//
//  ContentView.swift
//  daftbeer
//
//  Created by Andyne on 7/22/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        ZStack {
            Color(.gray).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20.0) {
                Image("hike").resizable().cornerRadius(15.0).aspectRatio(contentMode: .fit)
                HStack {
                    Text("Switzer Falls").font(.largeTitle).fontWeight(.semibold).foregroundColor(Color.white)
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.leadinghalf.filled")
                        }.foregroundColor(.orange).font(.caption)
                        Text("361 Reviews").font(.caption)
                    }
                }
                Text("A scenic, moderate-intesity hike with breathtaking views of the Switzer River and the surrounding mountains.")
                    .font(.body)
                    .foregroundColor(Color.white)
                HStack {
                    Spacer()
                    Image(systemName: "binoculars.fill")
                    Image(systemName: "fork.knife")
                }.foregroundColor(.orange).font(.caption)
            }.padding(20.0).background(Rectangle().foregroundColor(.gray).cornerRadius(15.0).shadow(radius: 15.0)).padding(20.0)
        }
    }
}

#Preview {
    MenuView()
}
