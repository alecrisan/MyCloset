//
//  CircleImage.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 03/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var image: Image
    @State private var dim = false
    
    var body: some View {
        image
        .clipShape(Circle())
        .overlay(
        Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
            .opacity(dim ? 1.0 : 0.3)
        .animation(.easeInOut(duration: 1.0))
        .onTapGesture {
            self.dim.toggle()
        }
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: Image("skirtbabyblue"))
    }
}
