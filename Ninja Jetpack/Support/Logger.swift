//
//  Logger.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 24..
//

import Foundation

class Logger {
    static let shared = Logger()
    private init() {}
    
    func debugPrint(
        _ message: Any,
        extra1: String = #file,
        extra2: String = #function,
        extra3: Int = #line,
        remoteLog: Bool = false,
        plain: Bool = false
    ) {
        if plain {
            print(message)
            return
        }
        
        let filename = (extra1 as NSString).lastPathComponent
        print(message, "[\(filename) \(extra3) line]")
        
        if remoteLog {
            //Todo: record log in backend
        }
    }
    
    func prettyPrint(_ message: Any) {
        dump(message)
    }
    
    func printDocumentsDirectory() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Document Path: \(documentsPath)")
    }
    
    func logEvent(_ name: String? = nil, event: String? = nil, param: [String: Any]? = nil) {
        //TODO: log event in backend/FIR
        // Analytics.logEvent(name, parameters: param)
    }
}
