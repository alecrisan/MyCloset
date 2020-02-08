//
//  MyClosetTests.swift
//  MyClosetTests
//
//  Created by Crisan Alexandra on 03/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import XCTest
@testable import MyCloset

class MyClosetTests: XCTestCase {

    var sut: Closet!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = Closet()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }

    
    func testItemIsAdded(){
        // 1. given
        let item = ClothingItem(id: 1, name: "skirt", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 10)

        // 2. when
        sut.addItem(clothingitem: item)

        // 3. then
        XCTAssertEqual(sut.items[sut.items.count - 1], item,"The item was not added!")
    }

    func testItemIsDeleted(){
        // 1. given
        let item1 = ClothingItem(id: 1, name: "pants", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 20)
        let item2 = ClothingItem(id: 2, name: "skirt", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 10)

        // 2. when
        sut.addItem(clothingitem: item1)
        sut.addItem(clothingitem: item2)
        sut.delete(id: item2.id)

        // 3. then
        XCTAssertNotEqual(sut.items[sut.items.count - 1], item2,"The item was not deleted!")
    }
    
    func testItemIsUpdated(){
        // 1. given
        let item = ClothingItem(id: 3, name: "skirt", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 10)

        // 2. when
        sut.addItem(clothingitem: item)
        sut.editItem(id: item.id, clothingitem: ClothingItem(id: item.id, name: item.name, photo: item.photo, description: item.description, size: ClothingItem.Size(rawValue: item.size.rawValue)!, price: 20))

        // 3. then
        XCTAssertEqual(sut.items[sut.items.count - 1].price, 20,"The item was not updated!")
    }
    
}
