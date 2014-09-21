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
    static func series(tasks: [((NSError?) -> ()) -> ()], completionHandler: (NSError?) -> ()) {
        _series(tasks, completionHandler: completionHandler)
    }

    private static func _series(var remainingTasks: [((NSError?) -> ()) -> ()], completionHandler: (NSError?) -> ()) {
        if remainingTasks.count == 0 {
            return completionHandler(nil)
        }

        let nextTask = remainingTasks.removeAtIndex(0)
        nextTask() { (error) in
            if let error = error {
                completionHandler(error)
            } else {
                return self._series(remainingTasks, completionHandler: completionHandler)
            }
        }
    }
}

public extension Async {
    static func series<T>(tasks: [((T?, NSError?) -> ()) -> ()], completionHandler: ([T]?, NSError?) -> ()) {
        _series(tasks, finalResults: [], completionHandler: completionHandler)
    }
    
    private static func _series<T>(var remainingTasks: [((T?, NSError?) -> ()) -> ()], var finalResults: [T], completionHandler: ([T]?, NSError?) -> ()) {
        if remainingTasks.count == 0 {
            return completionHandler(finalResults, nil)
        }

        let nextTask = remainingTasks.removeAtIndex(0)
        nextTask() { (result, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let result = result {
                finalResults.append(result)
                return self._series(remainingTasks, finalResults: finalResults, completionHandler: completionHandler)
            } else {
                println("[Async] task at index \(finalResults.count) must either return an error or a result")
                fatalError("[Async] neither error nor result returned")
            }
        }
    }
}
