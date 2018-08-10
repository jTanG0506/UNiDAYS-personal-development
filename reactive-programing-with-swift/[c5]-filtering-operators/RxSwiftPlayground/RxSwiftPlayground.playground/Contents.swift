import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

example(of: "ignoreElements") {
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes.ignoreElements().subscribe { _ in
        print("You're out!")
        }.disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onCompleted()
}


example(of: "elementAt") {
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes.elementAt(2).subscribe(onNext: { _ in
        print("You're out!")
    }).disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6).filter { int in
        int % 2 == 0
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C", "D", "E", "F").skip(3).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 3, 4, 4).skipWhile{ int in
        int % 2 == 0
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject.skipUntil(trigger).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext("X")
    subject.onNext("C")
}

example(of: "take") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6).take(3).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}


example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    Observable.of(2, 4, 4, 4, 6, 6).enumerated().takeWhile { index, int in
        int % 2 == 0 && index < 3
    }.map { $0.element }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}