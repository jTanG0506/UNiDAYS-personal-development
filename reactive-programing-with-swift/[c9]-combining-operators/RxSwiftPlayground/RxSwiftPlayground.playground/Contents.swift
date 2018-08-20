import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

example(of: "startWith") {
    let bag = DisposeBag()
    let numbers = Observable.of(2, 3, 4)
    
    let observable = numbers.startWith(1)
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "Observable.concat") {
    let bag = DisposeBag()
    
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    let observable = Observable.concat([first, second])
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "concat") {
    let bag = DisposeBag()
    
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "concatMap") {
    let bag = DisposeBag()
    
    let sequences = [
        "Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
    ]
    
    let observable = Observable.of("Germany", "Spain")
        .concatMap { country in sequences[country] ?? .empty() }
    
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    let observable = source.merge()
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    disposable.dispose()
}
