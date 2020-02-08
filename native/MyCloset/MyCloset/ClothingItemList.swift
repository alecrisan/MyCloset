//
//  ClothingItemList.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 04/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import SwiftUI
import SQLite3

struct ClothingItemList: View {
    
    @EnvironmentObject var itemsData: Closet
    
    @State var modalDisplayed = false
    @State var editModalDisplayed = false
    
    @State var showingAlertDelete = false
    @State var showingAlertEdit = false
    
    var body: some View {
            
        NavigationView{
            VStack{
                HStack{
            Button(action:
                {
                    self.modalDisplayed = true
                    
            })
            {
                Text("Add")
            }
            .sheet(isPresented: $modalDisplayed) {
                AddItem().environmentObject(self.itemsData)
            }
            Spacer()
            Button(action:
                    {
                        self.itemsData.synchronize()
                        self.itemsData.addCache()
                })
                {
                    Text("Refresh")
                }
                }
                .padding([.horizontal])
            
            List{
                ForEach (self.itemsData.items) {
                clothingitem in
                    VStack{

                    NavigationLink(destination: ClothingItemDetail(clothingitem: clothingitem))
                    {
                    ClothingItemRow(clothingitem: clothingitem)
                        .contextMenu
                        {
                            Button(action:{
                                
                                self.itemsData.checkReachability()
                                print(self.itemsData.reachability!.currentReachabilityStatus)
                                if(self.itemsData.reachability!.isReachable) {
                                    print("yes")
                                    self.itemsData.deleteFromServer(id: clothingitem.id)
                                    self.itemsData.delete(id: clothingitem.id)
                                }
                                else {
                                    print("no")
                                    self.showingAlertDelete = true
                                }

                                })
                                {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                        .alert(isPresented: self.$showingAlertDelete) {
                                                Alert(title: Text("You are offline"), message: Text("Please check your internet connection!"), dismissButton: .default(Text("Got it!")))
                                    
                                                        }
                                }
                            Spacer()
                            Button(action:{
                                    if(self.itemsData.reachability!.isReachable) {
                                    self.editModalDisplayed = true
                                }
                                    else{
                                        self.showingAlertEdit = true
                                }

                                })
                                {
                                    Text("Edit")
                                    .alert(isPresented: self.$showingAlertEdit) {
                                                Alert(title: Text("You are offline"), message: Text("Please check your internet connection!"), dismissButton: .default(Text("Got it!")))
                                    
                                                        }
                                }
                            .sheet(isPresented: self.$editModalDisplayed) {
                                EditItem(id: clothingitem.id, name: clothingitem.name, description: clothingitem.description, size: clothingitem.size.rawValue, image: clothingitem.photo, price: String(clothingitem.price)).environmentObject(self.itemsData)
                                }
                            
                        }
    
                    }
                    }
                }
                .onDelete(perform: self.itemsData.deleteItem)
                
            }
            .navigationBarTitle(Text("My Closet"))
            
                }

            }
    }
}


struct ClothingItemList_Previews: PreviewProvider {
    static let closet = Closet()
    static var previews: some View {
        ClothingItemList().environmentObject(closet)
    }
}
