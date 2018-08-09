import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// PublishSubjects only emit to current subscribers
// PublishSubjects will re-emit its stop events to future subscribers.
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")
    
    let subscriptionOne = subject.subscribe(onNext: { string in
        print("S1 -", string)
    })
    
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subscriptionTwo = subject.subscribe { string in
        print("S2 -", string.element ?? string)
    }
    
    subject.onNext("3")
    subscriptionOne.dispose()
    subject.onNext("4")
    
    subject.onCompleted()
    subject.onNext("5")
    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()
    subject.subscribe {
        print("S3 -", $0.element ?? $0)
    }.disposed(by: disposeBag)
}
