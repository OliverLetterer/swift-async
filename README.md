# swift-async

`swift-async` allows You to group async tasks, like loading data from the network or performing long running computations, together with a unified completion handler.

## Usage

For the sake of simplicity, consider the following model:

```swift
class Room {
    let number: Int
}

class Floor {
    let name: String
}

class Building {
    func performAsyncWork1(completionHandler: (NSError?) -> ()) {
        // perform async work and invoke completionHandler when done
    }

    func fetchRoomsOnFloor(floor: Floor, completionHandler: ([Room]?, NSError?) -> ()) {
        // fetch some data here and invoke completionHandler when done
    }

    func fetchFloors(completionHandler: ([Floor]?, NSError?) -> ()) {
        // fetch some data here and invoke completionHandler when done
    }
}

```

### Executing tasks in parallel

```swift
let building1 = Building()
let building2 = Building()

let tasks = [
    Async.bind { building1.fetchFloors($0) },
    Async.bind { building1.fetchRoomsOnFloor(Floor(name: "First floor"), $0) },

    Async.bind { building2.fetchFloors($0) },
    Async.bind { building2.fetchRoomsOnFloor(Floor(name: "First floor"), $0) },
]

Async.parallel(tasks) { (results, error) in
    if let error = error {
        println("Error: \(error)")
    } else if let results = results {
        let floors = results[0] as [Floor]
        let rooms = results[1] as [Room]

        println("Got floors: \(floors)")
        println("And rooms: \(rooms)")
    }
}
```

### Executing tasks one after another

```swift
let building1 = Building()
let building2 = Building()

let tasks = [
    building1.performAsyncWork1,
    building2.performAsyncWork2,
    Async.bind { building1.performAsyncWorkWithObject(nil, completionHandler: $0) },
]

Async.series(tasks) { (error) in
    if let error = error {
        return println("Error: \(error)")
    } else {
        println("all tasks succeeded")
    }
}
```

## Asumptions

All functions must take a unified completion handler that either takes
* a single `NSError?` argument
* or a generic type `T?` and a `NSError?` argument

`swift-async` is __not__ thread safe, so You need to make sure that all completion handlers get executed on the same thread.



```
func loadDataFromNetwork1(completionHandler: (result: NSDictionary, error: NSError) -> ()) {

}
```
