//
//  File.swift
//  
//
//  Created by Christopher Wyatt on 5/3/23.
//

import Foundation

#if !SPM

extension Bundle {
    static var module: Bundle { Bundle(for: self.classForCoder()) }
}

#endif
