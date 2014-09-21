//
//  Async.series.swift
//  async-demo
//
//  Created by Oliver Letterer on 21.09.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

import Foundation

public extension Async {
    public static func series(tasks: [((NSError?) -> ()) -> ()], completionHandler: (NSError?) -> ()) {
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
    static func series(tasks: [((T?, NSError?) -> ()) -> ()], completionHandler: ([T]?, NSError?) -> ()) {
        _series(tasks, finalResults: [], completionHandler: completionHandler)
    }
    
    private static func _series(var remainingTasks: [((T?, NSError?) -> ()) -> ()], var finalResults: [T], completionHandler: ([T]?, NSError?) -> ()) {
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
