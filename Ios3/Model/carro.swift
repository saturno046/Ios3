//
//  carro.swift
//  Carangas
//
//  Created by Lucas Ventura on 01/12/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import UIKit

class carro: Codable {
    
    var _id: String
    var brand: String
    var gasType: Int
    var name: String
    var price: Double
    
    var gas: String {
        switch gasType {
        case 0:
            return "flex"
        case 1:
            return "alcool"
        default:
            return "gasolina"
        }
    }
    

}
