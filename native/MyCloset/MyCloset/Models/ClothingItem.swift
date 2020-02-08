//
//  ClothingItem.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 03/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import Foundation
import SwiftUI

struct ClothingItem: Hashable, Codable, Identifiable{
    var id: Int
    var name: String
    var photo: String
    var description: String
    var size: Size
    var price: Int
    
    static let `default` = Self(id: 1, name: "skirt", photo: "skirtbabyblue", description: "jeans, baby blue", size: ClothingItem.Size.xs, price: 0)
    
    enum Size: String, CaseIterable, Codable, Hashable {
        case xs = "XS"
        case s = "S"
        case m = "M"
        case l = "L"
        case xl = "XL"
        case xxl = "XXL"
    }
}

extension ClothingItem
{
    var image: Image
    {
        ImageStore.shared.image(name: photo)
    }
    
    mutating func edit(clothingitem: ClothingItem)
    {
        self.name = clothingitem.name
        self.photo = clothingitem.photo
        self.description = clothingitem.description
        self.size = ClothingItem.Size(rawValue: clothingitem.size.rawValue)!
        self.price = clothingitem.price
    }
}
