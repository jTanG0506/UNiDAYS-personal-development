import RxSwift

example(of: "Variable") {
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    let userSession = Variable(UserSession.loggedOut)
    
    userSession.asObservable().subscribe(onNext: { state in
        print("stateChanged: ", state)
    }).disposed(by: disposeBag)
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com", password == "appleseed" else {
            completion(LoginError.invalidCredentials)
            return
        }
        
        completion(nil)
        userSession.value = .loggedIn
    }
    
    func logOut() {
        userSession.value = .loggedOut
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        guard userSession.value == .loggedIn else {
            print("You can't do that!")
            return
        }
        
        action()
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
        
        print()
    }
}
