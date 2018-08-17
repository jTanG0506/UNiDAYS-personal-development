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
