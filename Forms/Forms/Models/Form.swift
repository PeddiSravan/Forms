//
//  File.swift
//  Forms
//
//  Created by Sravan Peddi on 16/06/19.
//

import Foundation

class FormsMainModel:Codable {
    var form:FormsModel!
}

class FormsModel:Codable {
    var name:String = CommonStrings.emptyString
    var username:String = CommonStrings.emptyString
    var sections:[SectionModel] = []
}

class SectionModel:Codable {
    var name = CommonStrings.emptyString
    var code = CommonStrings.emptyString
    var type = CommonStrings.emptyString
    var value:[String] = []
    var options:[String]?
    var Footer:String?
    var childList:[SectionModel]?
}


