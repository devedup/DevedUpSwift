//
//  File.swift
//  
//
//  Created by David Casserly on 05/08/2020.
//

import XCTest
@testable import DevedUpSwiftFoundation

final class ValidatorTests: XCTestCase {
    
    func testValidateFullPhoneNumber() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var number = "+447999695766"
        var result = Validator.validateFullPhoneNumber(number)
        XCTAssertTrue(result)
        
        number = "447999695766"
        result = Validator.validateFullPhoneNumber(number)
        XCTAssertFalse(result)
        
        number = "44799"
        result = Validator.validateFullPhoneNumber(number)
        XCTAssertFalse(result)
        
        number = "+1234567"
        result = Validator.validateFullPhoneNumber(number)
        XCTAssertTrue(result)
    }

    func testValidatePhoneNumber() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var number = "+447999695766"
        var result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertFalse(result)
        
        number = "447999695766"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertFalse(result)
        
        number = "44799"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertFalse(result)
        
        number = "+1234567"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertFalse(result)
        
        number = "012345"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertFalse(result)
        
        number = "0123456"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertTrue(result)
        
        number = "0123456789123456"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertFalse(result)
        
        number = "012345678912345"
        result = Validator.validatePhoneNumberNoCode(number)
        XCTAssertTrue(result)
    }
    
    func testValidatePhoneCode() {
        var number = "+1"
        var result = Validator.validatePhoneCode(number)
        XCTAssertTrue(result)
        
        number = "+12"
        result = Validator.validatePhoneCode(number)
        XCTAssertTrue(result)
        
        number = "+123"
        result = Validator.validatePhoneCode(number)
        XCTAssertTrue(result)
        
        number = "123"
        result = Validator.validatePhoneCode(number)
        XCTAssertFalse(result)
        
        number = "+1234"
        result = Validator.validatePhoneCode(number)
        XCTAssertFalse(result)
        
        number = "+"
        result = Validator.validatePhoneCode(number)
        XCTAssertFalse(result)
        
        number = "ddd"
        result = Validator.validatePhoneCode(number)
        XCTAssertFalse(result)
        
        number = "++1"
        result = Validator.validatePhoneCode(number)
        XCTAssertFalse(result)
    }
    
    func testValidateSingleNumber() {
        var number = "1"
        var result = Validator.validateSingleNumber(number)
        XCTAssertTrue(result)
        
        number = "11"
        result = Validator.validateSingleNumber(number)
        XCTAssertFalse(result)
        
        number = ""
        result = Validator.validateSingleNumber(number)
        XCTAssertFalse(result)
        
        number = "z"
        result = Validator.validateSingleNumber(number)
        XCTAssertFalse(result)
    }
    
}
