//
//  AppDelegate.swift
//  async-demo
//
//  Created by Oliver Letterer on 20.09.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

import UIKit

class Room : NSObject, Printable, DebugPrintable {
    let number: Int

    init(number: Int) {
        self.number = number
    }

    override var description: String {
        return "Room \(number)"
    }

    override var debugDescription: String {
        return description
    }
}

class Floor : NSObject, Printable, DebugPrintable {
    let name: String

    init(name: String) {
        self.name = name
    }

    override var description: String {
        return "Floor \(name)"
    }

    override var debugDescription: String {
        return description
    }
}

class Building {
    init() {

    }

    func fetchData(completionHandler: ([Room]?, NSError?) -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            completionHandler(nil, NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil))
        }
    }

    func fetchRoomsOnFloor(floor: Floor, completionHandler: ([Room]?, NSError?) -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            completionHandler([Room(number: 1), Room(number: 2), Room(number: 3)], nil)
        }
    }

    func fetchFloors(completionHandler: ([Floor]?, NSError?) -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            completionHandler([Floor(name: "First floor"), Floor(name: "Second floor")], nil)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func crashWithoutStackVariable() {
        let building = Building()
        Async.bind({ building.fetchFloors($0) })() { (result, error) in
            println(result)
            println(error)
        }
    }

    func noCrashWithStackVariable() {
        let building = Building()
        let function = Async.bind({ building.fetchFloors($0) })
        function { (result, error) in
            println(result)
            println(error)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let building = Building()

        let tasks = [
            Async.bind({ building.fetchFloors($0) }),
            Async.bind({ building.fetchRoomsOnFloor(Floor(name: "First floor"), $0) }),
//            Async.bind({ building.fetchData($0) }),
        ]

        Async.parallel(tasks) { (results, error) in
            if let error = error {
                println("Error: \(error)")
            } else if let results = results {
                let floors = results[0] as [Floor]
                let rooms = results[1] as [Room]

                println("Got floors: \(floors)")
                println("And rooms: \(rooms)")
            } else {
                fatalError("Case not supported")
            }
        }

        return true
    }
}

