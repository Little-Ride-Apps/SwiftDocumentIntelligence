//
//  Utils.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import Foundation

func printObject(_ items: Any?...) {
    #if DEBUG
    print(Date().logDateFormat(), separator: "", terminator: ": ")

    for (idx, item) in items.enumerated() {
        if idx != items.count - 1 {
            if item != nil {
                print(item!, separator: "", terminator: ", ")
            } else {
                print(String(describing: item), separator: "    ", terminator: ", ")
            }
        } else {
            if item != nil {
                print(item!, separator: "", terminator: "\n")
            } else {
                print(String(describing: item), separator: "", terminator: "\n")
            }
        }
    }
    #endif
}

func getIDCardDetails(texts: [String]) {
    
}

