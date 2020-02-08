//
//  Data.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 03/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation

//let itemsData: [ClothingItem] = load("itemsData.json")
//var itemsData: [ClothingItem] = [ClothingItem(id: 1, name: "skirt", imageName: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs),
//    ClothingItem(id: 2, name: "dress", imageName: "purpledress", description:"flowers", size: ClothingItem.Size.s)]

//func load<T: Decodable>(_ filename: String) -> T {
//    let data: Data
//
//    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
//        else {
//            fatalError("Couldn't find \(filename) in main bundle.")
//    }
//
//    do {
//        data = try Data(contentsOf: file)
//    } catch {
//        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
//    }
//
//    do {
//        let decoder = JSONDecoder()
//        return try decoder.decode(T.self, from: data)
//    } catch {
//        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
//    }
//}
//
//func add<ClothingItem: Encodable>(_ filename: String, clothingitem: ClothingItem) {
//    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
//        else {
//            fatalError("Couldn't find \(filename) in main bundle.")
//    }
//
//    do {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let data = try encoder.encode(clothingitem)
//        print(String(data: data, encoding: .utf8)!)
//        print(file)
//        try data.write(to: file)
//    } catch {
//        fatalError("Couldn't parse \(filename) as \(ClothingItem.self):\n\(error)")
//    }
//}


final class ImageStore {
    typealias _ImageDictionary = [String: CGImage]
    fileprivate var images: _ImageDictionary = [:]

    fileprivate static var scale = 2
    
    static var shared = ImageStore()
    
    func image(name: String) -> Image {
        let index = _guaranteeImage(name: name)
        
        return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(verbatim: name))
    }

    static func loadImage(name: String) -> CGImage {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            fatalError("Couldn't load image \(name).jpg from main bundle.")
        }
        return image
    }
    
    fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
        if let index = images.index(forKey: name) { return index }
        
        images[name] = ImageStore.loadImage(name: name)
        return images.index(forKey: name)!
    }
}
