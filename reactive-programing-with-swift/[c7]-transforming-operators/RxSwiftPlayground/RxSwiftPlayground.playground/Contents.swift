import RxSwift

example(of: "toArray") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C").toArray().subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}
