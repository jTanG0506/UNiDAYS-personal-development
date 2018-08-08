import RxSwift

example(of: "never") {
    let observable = Observable<Any>.never()
    let disposeBag = DisposeBag()
    
    observable.do(onSubscribe: {
        print("--> Subscribe")
    }).subscribe(
        onNext: { element in
            print(element)
    },
        onCompleted: {
            print("Completed")
    },
        onDisposed: {
            print("Disposed")
    }).disposed(by: disposeBag)
}
