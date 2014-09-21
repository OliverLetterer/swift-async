//
//  Async.swift
//  async-demo
//
//  Created by Oliver Letterer on 20.09.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

import Foundation

struct Async<T: Any> {
    typealias completionHandler = (NSError?) -> ()
    typealias resultCompletionHandler = (T?, NSError?) -> ()
    typealias resultCompletionHandlerWrapper = ((T?, NSError?) -> ()) -> ()
}

extension Async {
    static func bind(wrapper: resultCompletionHandlerWrapper) -> Async<Any>.resultCompletionHandlerWrapper {
        let result: Async<Any>.resultCompletionHandlerWrapper = { (function) in
            wrapper() { (result, error) in
                var upcastedResult: Any? = nil

                if let result = result {
                    upcastedResult = result
                }

                function(upcastedResult, error)
            }
        }

        return result
    }
}

extension Async {
    static func parallel(tasks: [resultCompletionHandlerWrapper], completionHandler: ([T]?, NSError?) -> ()) {
        println("[Async] Executing \(tasks.count) tasks in parallel")

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
                    println("[Async] Task \(index) failed with error: \(error)")

                    globalError = error
                    completionHandler(nil, error)
                } else if let result = result {
                    println("[Async] Task \(index) completed")

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
