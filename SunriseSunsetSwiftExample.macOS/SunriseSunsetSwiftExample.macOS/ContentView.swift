//
//  ContentView.swift
//  SunriseSunsetTest
//
//  Created by Kraig Spear on 7/5/21.
//

import SwiftUI


struct ContentView: View {


    @ObservedObject var viewModel = ContentViewModel()


    var body: some View {
        VStack {
            Text("Sunrise / Sunset Example")
                .font(.largeTitle)
                .padding()
            Image(systemName: "sun.max.fill")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .padding(.top, 20)

            LatLngView(viewModel: viewModel)
                .frame(width: 200, alignment: .center)
                .padding()

            Text(viewModel.result)
                 .font(.title2)

        }.frame(minWidth: 500,minHeight: 500, alignment: .center)
    }
}

struct LatLngView: View {

    @ObservedObject var viewModel: ContentViewModel

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TextField("Latitude",
                      text: $viewModel.latitude)
            TextField("Longitude",
                      text: $viewModel.longitude)

            Button(
                action: { viewModel.calculate() },
                label: {
                    Text("Calculate")
                    .font(.body)
            }).padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
