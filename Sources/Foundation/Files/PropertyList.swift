//
//  File.swift
//  
//
//  Created by David Casserly on 08/06/2022.
//

import Foundation

public class PropertyListReader {
    public static func readPropertyList(resource: String, bundle: Bundle = Bundle.main) throws -> [String: AnyObject]  {
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        let plistPath: String? = bundle.path(forResource: resource, ofType: "plist")! //the path of the data
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        let plistData: [String: AnyObject] = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]
        return plistData
    }
}
