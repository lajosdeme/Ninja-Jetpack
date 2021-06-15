//
//  CoinData.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 19..
//

import SpriteKit
import GameplayKit

class CoinData: Codable {
    let structure: [[Int]]
    static func loadFrom(file filename: String) -> CoinData? {
        var data: Data
        var coinData: CoinData?
        
        if let path = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                data = try Data(contentsOf: path)
            } catch {
                Logger.shared.prettyPrint("Could not load coin data for \(filename), error: \(error)")
                return nil
            }
            do {
                coinData = try JSONDecoder().decode(CoinData.self, from: data)
            } catch {
                Logger.shared.prettyPrint("File for coin \(filename) is not valid JSON: \(error)")
                return nil
            }
        }
        return coinData
    }
}
