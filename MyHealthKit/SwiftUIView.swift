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
    }
}






#Preview {
    SwiftUIView()
}
