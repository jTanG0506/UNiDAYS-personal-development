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

example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest([left, right]) {
        strings in strings.joined(separator: " ")
    }
    
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    print("> Sending a value to Left")
    left.onNext("Hello")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    disposable.dispose()
}

example(of: "combine user choice and value") {
    let bag = DisposeBag()
    
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) { (format, when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "zip") {
    let bag = DisposeBag()
    
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "withLatestFrom") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    _ = observable.subscribe(onNext: {
        print($0)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
}

example(of: "sample") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = textField.sample(button)
    _ = observable.subscribe(onNext: {
        print($0)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    button.onNext(())
    textField.onNext("Paris")
    button.onNext(())
}

example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    disposable.dispose()
}

example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    let observable = source.switchLatest()
    
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")
    
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
}

example(of: "reduce") {
    let bag = DisposeBag()
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.reduce(0, accumulator: { summary, newValue in
        return summary + newValue
    })
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "scan") {
    let bag = DisposeBag()
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan(0, accumulator: +)
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "Challenge 1") {
    let bag = DisposeBag()
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let scanner = source.scan(0, accumulator: +)
    
    let observable = Observable.zip(source, scanner) { value, total in
        return "Current: \(value) Total: \(total)"
    }
    observable.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "Challenge 1 - Alternate") {
    let bag = DisposeBag()
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan((0, 0), accumulator: { total, value in
        return (value, value + total.1)
    })
    observable.subscribe(onNext: {
        print("Current: \($0.0) Total: \($0.1)")
    }).disposed(by: bag)
}
