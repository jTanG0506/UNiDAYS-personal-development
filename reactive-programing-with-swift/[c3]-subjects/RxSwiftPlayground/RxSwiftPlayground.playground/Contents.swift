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

enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event)
}


// BehaviourSubjects always emit the latest element, so you need to provide an initial value.
// BehaviorSubjects are useful when you want to pre-populate a view with the most recent data.
example(of: "BehaviourSubject") {
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    subject.onNext("X")
    
    subject.subscribe {
        print(label: "1 -", event: $0)
    }.disposed(by: disposeBag)
    
    subject.onError(MyError.anError)
    subject.subscribe {
        print(label: "2 -", event: $0)
    }.disposed(by: disposeBag)
}


// ReplaySubjects will buffer, the latest elements they emit, up to a specified size.
// ReplaySubjects will then replay that buffer to new subscribers.
example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject.subscribe {
        print(label: "1 -", event: $0)
    }.disposed(by: disposeBag)
    
    subject.subscribe {
        print(label: "2 -", event: $0)
    }.disposed(by: disposeBag)
    
    subject.onNext("4")
    subject.onError(MyError.anError)
    
    subject.subscribe {
        print(label: "3 -", event: $0)
    }
}

example(of: "Variable") {
    let variable = Variable("Initial value")
    let disposeBag = DisposeBag()
    
    variable.value = "New initial value"
    
    variable.asObservable().subscribe {
        print(label: "1 -", event: $0)
    }.disposed(by: disposeBag)
    
    variable.value = "1"

    variable.asObservable().subscribe {
        print(label: "2 -", event: $0)
    }.disposed(by: disposeBag)

    variable.value = "2"
}
