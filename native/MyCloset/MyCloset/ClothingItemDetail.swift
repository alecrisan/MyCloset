//
//  ContentView.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 03/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import SwiftUI

struct ClothingItemDetail: View {
    @EnvironmentObject var itemsData: Closet
    
    var clothingitem: ClothingItem
    
    @State var modalDisplayed = false
    @State private var big = false
    @State private var showDetail = false
    
    var body: some View {
        
        VStack {
            CircleImage(image: clothingitem.image)
            VStack(alignment: .leading) {
                        Text(clothingitem.name)
                                .font(.title)
                                .padding(.leading)
                                .scaleEffect(big ? 0.5 : 1.0)
                                .animation(.spring())
                                .onTapGesture {
                                        self.big.toggle()
                                }
                }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 3)) {
                self.showDetail.toggle()
                }
            })
            {
                VStack{
                    
                Image(systemName: "chevron.right.circle")
                .imageScale(.large)
                .rotationEffect(.degrees(showDetail ? 90 : 0))
                .scaleEffect(showDetail ? 1.5 : 1)
                .padding()
                .animation(.easeInOut)
                    
                }
            }
            
            if(self.showDetail) {
                            
                HStack {
                    Text(clothingitem.description)
                        .font(.subheadline)
                    Spacer()
                    Text(clothingitem.size.rawValue)
                        .font(.subheadline)
                    Spacer()
                    Text(String(clothingitem.price))
                    .font(.subheadline)
                }
            .padding()
                .transition(AnyTransition.slide)

            }
            
            
        }
         .navigationBarTitle(Text(clothingitem.name), displayMode: .inline)
        
        }
            
    
}

struct ClothingItem_Previews: PreviewProvider {
    static var previews: some View {
        ClothingItemDetail(clothingitem: ClothingItem(id: 1, name: "skirt", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 10))
    }
}
