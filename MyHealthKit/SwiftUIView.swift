//
//  SwiftUIView.swift
//  MyHealthKit
//
//  Created by Michael S on 26/05/25.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var message = "Hello"

    var body: some View {
        NavigationStack {
            NavigationLink("Go to Detail", destination: Text("Detail View"))
        }

//        VStack {
//
//            HStack {
//                Text("Left")
//                    .padding()
//                     .background(Color.white)
//                     .border(Color.gray)
//                     .shadow(radius: 5)
//                Spacer()
//                Text("Right")
//            }
//            .padding()
//            
//            VStack {
//                Text("Section 1")
//                Divider()
//                Text("Section 2")
//            }
//            .padding()
//        }
    }
}






#Preview {
    SwiftUIView()
}
