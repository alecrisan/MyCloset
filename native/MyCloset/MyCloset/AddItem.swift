//
//  AddItem.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 05/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import SwiftUI
import UIKit

struct AddItem: View {
    @EnvironmentObject var itemsData: Closet
    
    @State var name = ""
    @State var description = ""
    @State var size = ""
    @State var image = ""
    @State var price = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var showingAlert = false
    
    var allSizes = ["XS", "S", "M", "L", "XL","XXL"]
    
    var body: some View {
        NavigationView{
        
            Form {
                TextField("Name",
                          text: $name)
                TextField("Description",
                          text: $description)
                Picker(selection: $size,
                       label: Text("Size")) {
                        ForEach(0 ..< allSizes.count) {
                            Text(self.allSizes[$0]).tag(self.allSizes[$0])
                        }
                }
                
                TextField("Price", text: $price)
                
                VStack(alignment: .leading, spacing: 20) {
                Text("Image")
                
                Picker("Image", selection: $image) {
                        Image("purpledress").tag("purpledress")
                        Image("jeans").tag("jeans")
                        Image("skirtbabyblue").tag("skirtbabyblue")
                }
                .pickerStyle(SegmentedPickerStyle())
                }
                    
                if self.isUserInformationValid() {

                Button (action: {
                    let id = self.itemsData.getLastId()
                    let item = ClothingItem(id: id + 1, name: self.name, photo: self.image, description: self.description, size: ClothingItem.Size.init(rawValue: self.size) ?? ClothingItem.Size(rawValue: "XS")!, price: Int(self.price)!)
                    
                    print(item)
                    
                    //self.itemsData.addItem(clothingitem: item)
                    self.itemsData.addToServer(item: item)
                    
                    print(self.itemsData.items)
                    self.presentationMode.wrappedValue.dismiss()
                    
                        })
                    {
                        Text("Add item")
                    }
                    
                }
            
            
        }
        .navigationBarTitle(Text("New clothing item"))
            
        }
        
    }
    
    private func isUserInformationValid() -> Bool {
        if name.isEmpty {
            return false
        }
        
        if description.isEmpty {
            return false
        }
        
        if size.isEmpty {
            return false
        }
        
        if price.isEmpty
        {
            return false
        }
        
        return true
    }
}

struct AddItem_Previews: PreviewProvider {
    static let closet = Closet()
    static var previews: some View {
        AddItem().environmentObject(closet)
    }
}
