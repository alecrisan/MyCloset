//
//  ClothingItemRow.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 03/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import SwiftUI

struct ClothingItemRow: View {
    var clothingitem: ClothingItem
    
    var body: some View {
        HStack{
            clothingitem.image
            .resizable()
            .frame(width: 50, height: 50)
            Text(clothingitem.name)
        }
    }
}

struct ClothingItemRow_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ClothingItemRow(clothingitem: ClothingItem(id: 1, name: "skirt", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 10))
            ClothingItemRow(clothingitem: ClothingItem(id: 2, name: "dress", photo: "purpledress", description:"flowers", size: ClothingItem.Size.s, price: 10))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
