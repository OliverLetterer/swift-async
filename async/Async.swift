//
//  Async.swift
//  async-demo
//
//  Created by Oliver Letterer on 20.09.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

import Foundation

public struct Async {
    static func bind(wrapper: ((NSError?) -> ()) -> ()) -> ((NSError?) -> ()) -> () {
        let result: ((NSError?) -> ()) -> () = { (function) in
            wrapper() { (error) in
                function(error)
            }
        }

        return result
    }

    static func bind<T>(wrapper: ((T?, NSError?) -> ()) -> ()) -> ((Any?, NSError?) -> ()) -> () {
        let result: ((Any?, NSError?) -> ()) -> () = { (function) in
            wrapper() { (result, error) in
                function(result, error)
            }
        }

        return result
    }
}
