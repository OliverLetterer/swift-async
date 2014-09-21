//
//  Async.parallel.swift
//  async-demo
//
//  Created by Oliver Letterer on 21.09.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

import Foundation

public extension Async {
    static func parallel(tasks: [((NSError?) -> ()) -> ()], completionHandler: (NSError?) -> ()) {
        if tasks.count == 0 {
            return completionHandler(nil)
        }

        var globalError: NSError? = nil
        var completedTasks = 0

        for (index, task) in enumerate(tasks) {
            task() { (error) in
                if globalError != nil {
                    return
                }

                completedTasks++

                if let error = error {
                    globalError = error
                    return completionHandler(error)
                }

                if completedTasks == tasks.count {
                    completionHandler(nil)
                }
            }
        }
    }
}

public extension Async {
    static func parallel<T>(tasks: [((T?, NSError?) -> ()) -> ()], completionHandler: ([T]?, NSError?) -> ()) {
        if tasks.count == 0 {
            return completionHandler([], nil)
        }

        var optionalResults: [T?] = Array(count: tasks.count, repeatedValue: nil)
        var globalError: NSError? = nil
        var completedTasks = 0

        for (index, task) in enumerate(tasks) {
            task() { (result, error) in
                if globalError != nil {
                    return
                }

                completedTasks++

                if let error = error {
                    globalError = error
                    return completionHandler(nil, error)
                } else if let result = result {
                    optionalResults[index] = result
                } else {
                    println("[Async] task at index \(index) must either return an error or a result")
                    fatalError("[Async] neither error nor result returned")
                }

                if completedTasks == tasks.count {
                    let results = optionalResults.map({ $0! })
                    completionHandler(results, nil)
                }
            }
        }
    }
}
