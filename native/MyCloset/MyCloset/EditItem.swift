//
//  EditItem.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 10/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import SwiftUI

struct EditItem: View {
    @EnvironmentObject var itemsData: Closet
    
    @State private var showingAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var id = 0
    @State var name = ""
    @State var description = ""
    @State var size = ""
    @State var image = ""
    @State var price = ""
    
    var allSizes = ["XS", "S", "M", "L", "XL","XXL"]
    
    var body: some View {
        NavigationView{
            Form {
                
                HStack {
                    Text("Name").bold()
                    Divider()
                    TextField("Name",
                              text: $name)
                }
                
                HStack{
                Text("Description").bold()
                Divider()
                TextField("Description",
                          text: $description)
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 20) {
                    Text("Image").bold()
                
                Picker("Image", selection: $image) {
                        Image("purpledress").tag("purpledress")
                        Image("jeans").tag("jeans")
                        Image("skirtbabyblue").tag("skirtbabyblue")
                }
                .pickerStyle(SegmentedPickerStyle())
                }
                }
                
                HStack{
                Text("Price").bold()
                Divider()
                TextField("Price", text: $price)
                }
                
                Picker(selection: $size,
                       label: Text("Size")) {
                        ForEach(0 ..< allSizes.count) {
                            Text(self.allSizes[$0]).tag(self.allSizes[$0])
                        }
                }

                Button (action: {

                    let item = ClothingItem(id: self.id , name: self.name, photo: self.image, description: self.description, size: ClothingItem.Size(rawValue: self.size)!, price: Int(self.price)!)

                    self.itemsData.updateToServer(id: self.id, newItem: item)
                    self.itemsData.editItem(id: self.id, clothingitem: item)

                    self.presentationMode.wrappedValue.dismiss()
                        })
                    {
                        Text("Edit item")
                    }
            }
        .navigationBarTitle(Text("Edit clothing item"))
        
        }
        
    }

}

struct EditItem_Previews: PreviewProvider {
    static let closet = Closet()

    static var previews: some View {
        EditItem(id: 1, name: "skirt", description:"jeans, baby blue", size: ClothingItem.Size.xs.rawValue, image: "skirtbabyblue", price: "10").environmentObject(closet)

    }
}
