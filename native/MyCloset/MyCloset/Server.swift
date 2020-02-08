//
//  Server.swift
//  MyCloset
//
//  Created by Crisan Alexandra on 07/12/2019.
//  Copyright © 2019 Crisan Alexandra. All rights reserved.
//

import Foundation
import os.log
import UIKit
import SystemConfiguration


struct ItemStruct: Codable {
    let id: Int
    let name: String
    let photo: String
    let description: String
    let size: String
    let price: Int
}

class NodeServer {
    let server = "http://192.168.0.248:8080/item"
    //let server = "http://172.30.113.162:8080/item"
    let reachability = SCNetworkReachabilityCreateWithName(nil, "http://192.168.0.248:8080")
    
    func isNetworkReachable() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
    
    func DtoToItem(item: ItemStruct) -> ClothingItem {
        let s = (ClothingItem.Size(rawValue: item.size) ?? ClothingItem.Size(rawValue: "XS"))!
        
        let i = ClothingItem(id: item.id, name: item.name, photo: item.photo, description: item.description, size: s, price: item.price)
        //else do {fatalError("Unable to instantiate item!")}
        return i
    }
    
    func ItemToDto(item: ClothingItem) -> ItemStruct {
        return ItemStruct(id: item.id, name: item.name, photo: item.photo, description: item.description, size: item.size.rawValue, price: item.price)
    }
    
    func read(completionHandler completion: @escaping ([ClothingItem]?) -> Void) {
        print("Server connection: ", isNetworkReachable())
        var tempArray : [ClothingItem] = []
        let url = URL(string: server)
        let urlRequest = URLRequest(url: url!)
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print("error")
            } else {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error converting response as http url response or response is nil")
                    return
                }
                if httpResponse.statusCode == 200 {
                    guard let dataUnwrapped = data else {
                        print("data is nil ")
                        return
                    }
                    do {
                        let tempObject = try JSONDecoder().decode([ItemStruct].self, from: dataUnwrapped)
                        for i in tempObject {
                            tempArray.append(self.DtoToItem(item: i))
                        }
                        completion(tempArray)
                    } catch {
                        print("Error decoding json")
                    }
                }
            }
        }.resume()
    }
    
    func create(item: ClothingItem, completionHandler completion: @escaping (String?) -> Void) {
        let url = URL(string: server)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        do {
            urlRequest.httpBody = try JSONEncoder().encode(self.ItemToDto(item: item))
        } catch let error {
            print(error.localizedDescription)
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print("error")
            } else {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error converting response as http url response or response is nil")
                    return
                }
                if httpResponse.statusCode == 200 {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        completion(dataString)
                    }
                }
            }
         }.resume()
    }
    
    func delete(item: ClothingItem, completionHandler completion: @escaping (String?) -> Void) {
        var s = server + "/" + String(item.id)
        s = s.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: s)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print("error")
            } else {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error converting response as http url response or response is nil")
                    return
                }
                if httpResponse.statusCode == 200 {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        completion(dataString)
                    }
                }
            }
        }.resume()
    }

    func update(id: Int, newItem: ClothingItem, completionHandler completion: @escaping (String?) -> Void) {
        var s = server + "/" + String(id)
        s = s.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: s)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "PUT"
        do {
            urlRequest.httpBody = try JSONEncoder().encode(self.ItemToDto(item: newItem))
        } catch let error {
            print(error.localizedDescription)
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print("error")
            } else {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error converting response as http url response or response is nil")
                    return
                }
                if httpResponse.statusCode == 200 {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        completion(dataString)
                    }
                }
            }
        }.resume()
    }
}

class Reachability: NSObject {
    enum ReachabilityStatus {
    case notReachable
    case reachableViaWiFi
    case reachableViaWWAN
    }
    let ReachabilityDidChangeNotificationName = "ReachabilityDidChangeNotification"
    private var networkReachability: SCNetworkReachability?
    private var notifying: Bool = false
    private var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if let reachability = networkReachability, withUnsafeMutablePointer(to: &flags, { SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0)) }) == true {
            return flags
        }
        else {
            return []
        }
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
       
    init?(hostName: String) {
        networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, (hostName as NSString).utf8String!)
        super.init()
        if networkReachability == nil {
        return nil
        }
    }
    
    init?(hostAddress: sockaddr_in) {
        var address = hostAddress
        address.sin_len = UInt8(MemoryLayout.size(ofValue: address))
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = (8080)
        address.sin_addr.s_addr = inet_addr("192.168.0.248:8080xC0A800F8")
        
        guard let defaultRouteReachability = withUnsafePointer(to: &address, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }) else {
            return nil
        }
        networkReachability = defaultRouteReachability
        super.init()
        if networkReachability == nil {
            return nil
        }
    }
    
    static func networkReachabilityForInternetConnection() -> Reachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return Reachability(hostAddress: zeroAddress)
    }
     
    static func networkReachabilityForLocalWiFi() -> Reachability? {
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0 (0xA9FE0000).
        localWifiAddress.sin_addr.s_addr = 0xC0A800F8
        //localWifiAddress.sin_addr.s_addr = 0xAC1E71A2
        return Reachability(hostAddress: localWifiAddress)
    }
    
    func startNotifier() -> Bool {
        guard notifying == false else {
            return false
        }
        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        guard let reachability = networkReachability, SCNetworkReachabilitySetCallback(reachability, { (target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            if let currentInfo = info {
                let infoObject = Unmanaged<AnyObject>.fromOpaque(currentInfo).takeUnretainedValue()
                if infoObject is Reachability {
                    let networkReachability = infoObject as! Reachability
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ReachabilityDidChangeNotification"), object: networkReachability)
                }
            }
        }, &context) == true else { return false }
        guard SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) == true else { return false }
        notifying = true
        return notifying
    }
    
    func stopNotifier() {
        if let reachability = networkReachability, notifying == true {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            notifying = false
        }
    }
    
    var isReachable: Bool {
        switch currentReachabilityStatus {
        case .notReachable:
            return false
        case .reachableViaWiFi, .reachableViaWWAN:
            return true
        }
    }
    
     deinit {
         stopNotifier()
     }
}
