# swift-async

Group async tasks together with a unified completion handler.

## Usage

```
func loadDataFromNetwork1(completionHandler: (result: NSDictionary, error: NSError) -> ()) {

}
```

``` swift
let tasks = []
```


```
Async.series(tasks) { (results, error) in

}
```

```
Async.parallel(tasks) { (results, error) in

}
```
