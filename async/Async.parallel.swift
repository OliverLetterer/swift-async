/*
swift-async
Copyright (c) 2014 Oliver Letterer, Sparrow-Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

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
