//
//  File.swift
//  Forms
//
//  Created by Sravan Peddi on 16/06/19.
//

import Foundation

struct Form {
    var name = CommonStrings.emptyString
    var sections = [Section]()
    
}
struct Section
{
    var name = CommonStrings.emptyString
    var code = CommonStrings.emptyString
    var type = CommonStrings.emptyString
    var value = [String]()
    var childList = [Section]()
    
//    name    "Residents Information"
//    code    "section_1"
//    type    "section"
//    value    []
//    childList
}
