import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// PublishSubjects only emit to current subscribers
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")
    
    let subscriptionOne = subject.subscribe(onNext: { string in
        print(string)
    })
    
    subject.on(.next("1"))
    subject.onNext("2")
}
