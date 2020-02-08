//
//  Closet.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 07/11/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import Foundation
import SQLite3
import UIKit
import os.log
import SwiftUI

class Closet: ObservableObject  {
    @Published var items = [ClothingItem]()
    var db: OpaquePointer?
    
    let server = NodeServer()
    var reachability = Reachability(hostAddress: sockaddr_in())
    
    init() {
        items = [ClothingItem]()
        db = createDb()
        //dropTables()
        createTable()
        //deleteAllItems()
        //initialData()
        //addCache()
        //items = select()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
         reachability?.stopNotifier()
    }
    
    func checkReachability() {
        guard let r = reachability else { return }
        if r.isReachable  {
            print("is reachable")
            print(r.currentReachabilityStatus)
        } else {
            print("is not reachable")
            print(r.currentReachabilityStatus)
        }
    }
    
    @objc func reachabilityDidChange(_ notification: Notification) {
          checkReachability()
          addCache()
       }
        
    func synchronize() {
            print("sync")
            var serverItems = [ClothingItem]()
            if(reachability!.isReachable) {
                print("if")
                server.read() { (output) in
                    DispatchQueue.main.async {
                        serverItems = output ?? []
                        print("add from server to db")
                        self.deleteAllItems()
                        print("serverItems")
                         for i in serverItems {
                            print(i.name)
                            self.addItem(clothingitem: ClothingItem(id: i.id, name: i.name, photo: i.photo, description: i.description, size: i.size, price: i.price))
                        }
                        sleep(1)
                        self.server.read() { (output) in
                            DispatchQueue.main.async {
                                self.items = output ?? []
                                print(self.items)
                            }
                        }
                    }
                }
            }
            else {
                print("server not reachable for sync")
            }
        }
        
    func readFromServer() {
            if reachability!.isReachable {
                server.read() { (output) in
                    DispatchQueue.main.async {
                        self.items = output ?? []
                    }
                }
            }
            else {
                self.items = self.select()
            }
    }
    
    func addToServer(item: ClothingItem) {
        if (reachability!.isReachable) {
                print("add online")
            self.server.create(item: ClothingItem(id: item.id, name: item.name, photo: item.photo, description: item.description, size: item.size, price: item.price)) { (output) in
                    DispatchQueue.main.async {
                        self.server.read() { (output) in
                            DispatchQueue.main.async {
                                self.items = output ?? []
                            }
                        }
                    }
                }
                self.addItem(clothingitem: item)
                self.items = self.select()
                }
            
        else {
            print("add offline")
            self.insert(id: Int32(item.id), name: item.name, imageName: item.photo, description: item.description, size: item.size.rawValue, price: Int32(item.price))
            self.insertCache(id: Int32(item.id), name: item.name, imageName: item.photo, description: item.description, size: item.size.rawValue, price: Int32(item.price))
        }
        }
    
    func deleteFromServer(id: Int) {
        if(reachability!.isReachable){
            let row = self.items.firstIndex(where: {$0.id == id})
            server.delete(item: self.items[row!]){ (output) in DispatchQueue.main.async {
                self.server.read() { (output) in
                    DispatchQueue.main.async {
                        self.items = output ?? []
                    }
                }
                }
            }
        }
        else{
            print("server not reachable for delete")
        }
    }
    
    func updateToServer(id: Int, newItem: ClothingItem) {
        if (reachability!.isReachable) {
            server.update(id: id, newItem: ClothingItem(id: id, name: newItem.name, photo: newItem.photo, description: newItem.description, size: ClothingItem.Size(rawValue: newItem.size.rawValue)!, price: newItem.price)) { (output) in
                DispatchQueue.main.async {
                    self.server.read() { (output) in
                        DispatchQueue.main.async {
                            self.items = output ?? []
                        }
                    }
                }
            }
        }
        else {
            print("Server not reachable for update")
        }
    }
        
    func addCache() {
        if reachability!.isReachable {
            self.synchronize()
            let dbItems = self.selectCache()
            var serverItems = [ClothingItem]()
            if reachability!.isReachable {
                server.read() { (output) in
                    DispatchQueue.main.async {
                        serverItems = output ?? []
                        print("add from dbcache to server")
                        for i in dbItems {
                            print(i.name)
                            self.server.create(item: i) {(output) in}
                            self.addItem(clothingitem: i)
                        }
                    }
                    self.deleteAllItemsCache()
                    print("deleted cache")
                    print(self.selectCache().count)
                    sleep(1)
                        self.server.read() { (output) in
                            DispatchQueue.main.async {
                                self.items = output ?? []
                            }
                        }
                    }
                }
            }
        }
    
    func initialData()
    {
        addItem(clothingitem: ClothingItem(id: 1, name: "skirt", photo: "skirtbabyblue", description:"jeans, baby blue", size: ClothingItem.Size.xs, price: 10))
        addItem(clothingitem: ClothingItem(id: 2, name: "dress", photo: "purpledress", description:"flowers", size: ClothingItem.Size.s, price: 20))
    }
    
    func addItem(clothingitem: ClothingItem)
    {
        items.append(clothingitem)
        insert(id: Int32(clothingitem.id), name: clothingitem.name, imageName: clothingitem.photo, description: clothingitem.description, size: clothingitem.size.rawValue, price: Int32(clothingitem.price))
    }
    
    func editItem(id: Int, clothingitem: ClothingItem)
    {
        if let row = self.items.firstIndex(where: {$0.id == clothingitem.id}) {
               items[row] = clothingitem
        }
        
        update(id: Int32(id), name: clothingitem.name, imageName: clothingitem.photo, description: clothingitem.description, size: clothingitem.size.rawValue, price: Int32(clothingitem.price))
    }
    
    func deleteItem(at offsets: IndexSet) {
        self.items.remove(atOffsets: offsets)
    }
    
    func delete(id: Int)
    {
        if let row = self.items.firstIndex(where: {$0.id == id}) {
            self.items.remove(at: row)
        }
        deleteDB(id: Int32(id))
    }
    
    func createDb() -> OpaquePointer?
    {
        var db: OpaquePointer? = nil
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Closet.sqlite")
        
        if (sqlite3_open_v2(fileURL.path, &db, SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK) {

          print("Database opening failed!");
        }
        else {
            print("database open")
        }
//        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
//        {
//            print("Error opening database")
//        }
//        else
//        {
//            print("Database open")
//        }
        return db
    }
    
    func dropTables()
    {
        let dropTable1Query = "DROP TABLE Item;";
        let dropTable2Query = "DROP TABLE ItemCache;";
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, dropTable1Query, -1, &deleteStatement, nil) == SQLITE_OK {
            
          if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted table.")
          } else {
            print("Could not delete table.")
          }
        } else {
          print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
        
        var deleteStatement2: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, dropTable2Query, -1, &deleteStatement2, nil) == SQLITE_OK {
            
          if sqlite3_step(deleteStatement2) == SQLITE_DONE {
            print("Successfully deleted table.")
          } else {
            print("Could not delete table.")
          }
        } else {
          print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement2)
        
    }

    func createTable()
    {
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Item(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, photo TEXT, description TEXT, size TEXT, price INTEGER)"
        let createTable2Query = "CREATE TABLE IF NOT EXISTS ItemCache(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, photo TEXT, description TEXT, size TEXT, price INTEGER)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        else
        {
            print("Table created")
        }
        
        if sqlite3_exec(db, createTable2Query, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        else
        {
            print("Table created")
        }
    }
    
    func getLastId() -> Int {
        let queryStatementString = "SELECT MAX(id) FROM Item;"
        var queryStatement: OpaquePointer? = nil
        var id = 0
    
    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
      
      while sqlite3_step(queryStatement) == SQLITE_ROW {
        
        id = Int(sqlite3_column_int(queryStatement, 0))

        
        print("Query Result:")
        print("\(id)")
    
        print(id)

      }
    } else {
      print("SELECT statement could not be prepared")
    }

    
    sqlite3_finalize(queryStatement)
        return id
    }

    func insert(id: Int32, name: String, imageName: String, description: String, size: String, price: Int32)
    {
        let insertStatementString = "INSERT INTO Item (id, name, photo, description, size, price) VALUES (?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        // 1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
          let id: Int32 = id
            let name: NSString = NSString(string: name)
          let imageName: NSString = NSString(string: imageName)
            let description: NSString = NSString(string: description)
            let size: NSString = NSString(string: size)
          let price: Int32 = price

          // 2
          sqlite3_bind_int(insertStatement, 1, id)
          // 3
          sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, imageName.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, description.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, size.utf8String, -1, nil)
           sqlite3_bind_int(insertStatement, 6, price)

          // 4
          if sqlite3_step(insertStatement) == SQLITE_DONE {
            print("Successfully inserted row.")
          } else {
            print("Could not insert row.")
          }
        } else {
          print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }
    
    func insertCache(id: Int32, name: String, imageName: String, description: String, size: String, price: Int32)
    {
        let insertStatementString = "INSERT INTO ItemCache (id, name, photo, description, size, price) VALUES (?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        // 1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
          let id: Int32 = id
            let name: NSString = NSString(string: name)
          let imageName: NSString = NSString(string: imageName)
            let description: NSString = NSString(string: description)
            let size: NSString = NSString(string: size)
          let price: Int32 = price

          // 2
          sqlite3_bind_int(insertStatement, 1, id)
          // 3
          sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, imageName.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, description.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, size.utf8String, -1, nil)
           sqlite3_bind_int(insertStatement, 6, price)

          // 4
          if sqlite3_step(insertStatement) == SQLITE_DONE {
            print("Successfully inserted row in cache.")
          } else {
            print("Could not insert row in cache.")
          }
        } else {
          print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }

    func select() -> [ClothingItem]
    {
        let queryStatementString = "SELECT * FROM Item;"
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
          // 2
          while sqlite3_step(queryStatement) == SQLITE_ROW {
            // 3
            let id = sqlite3_column_int(queryStatement, 0)

            // 4
            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
            let name = String(cString: queryResultCol1!)
            
            let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
            let imageName = String(cString: queryResultCol2!)
            
            let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
            let description = String(cString: queryResultCol3!)
            
            let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
            let size = String(cString: queryResultCol4!)
            
            let price = sqlite3_column_int(queryStatement, 5)

            // 5
            print("Query Result:")
            print("\(id) | \(name) | \(imageName) | \(description) | \(size) | \(price)")
            
            let item = ClothingItem(id: Int(id), name: name, photo: imageName, description: description, size: ClothingItem.Size.init(rawValue: size) ?? ClothingItem.Size(rawValue: "XS")!, price: Int(price))
            
            print(item)
            
            self.addItem(clothingitem: item)

          }
        } else {
          print("SELECT statement could not be prepared")
        }

        // 6
        sqlite3_finalize(queryStatement)
        return items
    }
    
    func selectCache() -> [ClothingItem]
    {
        let queryStatementString = "SELECT * FROM ItemCache;"
        var queryStatement: OpaquePointer? = nil
        var items = [ClothingItem]()
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
          // 2
          while sqlite3_step(queryStatement) == SQLITE_ROW {
            // 3
            let id = sqlite3_column_int(queryStatement, 0)

            // 4
            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
            let name = String(cString: queryResultCol1!)
            
            let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
            let imageName = String(cString: queryResultCol2!)
            
            let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
            let description = String(cString: queryResultCol3!)
            
            let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
            let size = String(cString: queryResultCol4!)
            
            let price = sqlite3_column_int(queryStatement, 5)

            // 5
            print("Query Result Cache:")
            print("\(id) | \(name) | \(imageName) | \(description) | \(size) | \(price)")
            
            let item = ClothingItem(id: Int(id), name: name, photo: imageName, description: description, size: ClothingItem.Size.init(rawValue: size) ?? ClothingItem.Size(rawValue: "XS")!, price: Int(price))
            
            print(item)
            
            items.append(item)

          }
        } else {
          print("SELECT statement could not be prepared")
        }

        // 6
        sqlite3_finalize(queryStatement)
        return items
    }
    
    func update(id: Int32, name: String, imageName: String, description: String, size: String, price: Int32)
    {
        let updateStatementString = "UPDATE Item SET name = '\(name)', photo = '\(imageName)', description = '\(description)', size = '\(size)', price = \(price) WHERE id = \(id);"
        var updateStatement: OpaquePointer? = nil
          if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
              print("Successfully updated row.")
            } else {
              print("Could not update row.")
            }
          } else {
            print("UPDATE statement could not be prepared")
          }
          sqlite3_finalize(updateStatement)
        
    }
    
    
    func deleteDB(id: Int32)
    {
        let deleteStatementString = "DELETE FROM Item WHERE id = \(id);"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, id)
            
          if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted row.")
          } else {
            print("Could not delete row.")
          }
        } else {
          print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteDBCache(id: Int32)
    {
        let deleteStatementString = "DELETE FROM ItemCache WHERE id = \(id);"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, id)
            
          if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted row.")
          } else {
            print("Could not delete row.")
          }
        } else {
          print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteAllItems()
    {
        let deleteStatementString = "DELETE FROM Item"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            
          if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted table.")
          } else {
            print("Could not delete table.")
          }
        } else {
          print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteAllItemsCache()
    {
        let deleteStatementString = "DELETE FROM ItemCache"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            
          if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted table.")
          } else {
            print("Could not delete table.")
          }
        } else {
          print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
}


