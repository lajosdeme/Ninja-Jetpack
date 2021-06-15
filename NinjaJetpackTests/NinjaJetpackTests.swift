//
//  HyperionTests.swift
//  HyperionTests
//
//  Created by Lajos Deme on 2021. 04. 07..
//

import XCTest
@testable import Hyperion

class NinjaJetpackTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLabelText() {
        let texts = [12,310,9341,1,198,200,2,32,1,95].map { $0.createLabelText() }
        XCTAssertEqual(["0012", "0310", "9341", "0001", "0198", "0200", "0002", "0032", "0001", "0095"], texts)
    }
    
    func testColor() {
        let hex = "0000FF"
        let color = UIColor.hexStr(hexStr: NSString(string: hex), alpha: 1.0)
        XCTAssertNotNil(color.toHex())
        XCTAssertEqual(hex, color.toHex()!)
        
        let colRgb = UIColor.black.rgb()
        XCTAssertEqual([colRgb.green, colRgb.green, colRgb.blue], [0,0,0])
    }
    


}
