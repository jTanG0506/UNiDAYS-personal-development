import RxSwift

example(of: "toArray") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C").toArray().subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}

example(of: "map") {
    let disposeBag = DisposeBag()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(123, 4, 56).map {
        formatter.string(from: $0) ?? ""
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6).enumerated().map { index, int in
        index > 2 ? int * 2 : int
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}

struct Student {
    var score: BehaviorSubject<Int>
}

example(of: "flatMap") {
    let disposeBag = DisposeBag()
    
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
    student.flatMap { $0.score }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    student.onNext(ryan)
    ryan.score.onNext(85)
    student.onNext(charlotte)
    ryan.score.onNext(95)
    charlotte.score.onNext(100)
}
