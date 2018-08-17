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
