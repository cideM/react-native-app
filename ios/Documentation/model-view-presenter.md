# MVP – Model View Presenter

> This documentation is possibly out of date. Please read with a grain of salt.

This project uses the Model View Presenter pattern to separate the business from the view layer.

## The Model
* is the data itself. Usually a struct or an enum. Can have calculated properties.
* should be completely independed. Esp. not be dependent on the Presenter or the View
* should have a fixture factory implemented (see auto fixture generation)
* should not have any busines logic. They rarely have any functions (other than serialization etc.)
* should be implemented in the `Interfaces` component.



## The Presenter
* is a protocol and a specific implementation
* the protocol has the suffix `PresenterType`, for example: `LoginPresenterType`
* the protocol conforms to `AnyObject`
* is initialized with the Model (if a model is needed), for example, if a presenter performs network calls, then it would need to get the service responsible for these network calls injected to it through its initializer.
* keeps a strong reference to the Model
* encapsulates all the busines logic
* should be completely testable via unit tests
* you never import UIKit inside a presenter
* keeps a `weak` reference to the view via a protocol **not the concrete type**
* the view property is set inside the `viewDidLoad()` method of the connected view controller to be sure that the view is ready to receive commands.




## The View
* is a protocol and a specific implementation
* the protocol has the suffix `ViewType`, for example: `LoginViewType`
* the protocl conforms to `AnyObject`
* protocol should not have any UIKit dependencies
* implementation should hold a strong reference to the presenter via a protocol **not the presenter type itself**
* the presenter property must be set in the initializer of the view. For example: `init(presenter:)` and it must be held as a strong reference
* implementation should abstract all UIKit specific types and functions
* in practice usually is a UIViewController or a UIView
* should contain as little logic as possible; it is passive / doesn't "understand" what it is doing, just does what the presenter tells it to do




## The ViewData
* is a protocol **or** a type
* is the representation of the Views data so the View is independent of the Model




## Usage Example

```
protocol LoginPresenterType: AnyObject {
    var view: LoginViewType? { get }
    func login(username: String, password: String)
}

protocol LoginViewType: AnyObject {
    func showActivityIndicator()
    func showLoginSuccess()
}

final class LoginPresenter: LoginPresenterType {
    weak var view: LoginViewType?
    
    func login(username: String, password: String) {
        // Do something with the credentials
    }
}

final class LoginViewController: UIViewController {
    let presenter: LoginPresenterType

    let usernameTextField: UITextField = UITextField(frame: .zero)
    let passwordTextField: UITextField = UITextField(frame: .zero)
    
    init(presenter: LoginPresnterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
    }

    func loginButtonTapped() {
        presenter.login(username: usernameTextField.text!, password: passwordTextField.text!)
    }
}

extension LoginViewController: LoginViewType {
    func showLoginSuccess() {
        print("Login success")
    }

    func showActivityIndicator() {

    }
}

// The Coordinator will responsible for the initialization of both the presenter and the view controller. It will also be responsible for injecting the depencies to the presenter.

let loginViewController = LoginViewController()
loginViewController.presenter = LoginPresenter(view: loginViewController)
loginViewController.loginButtonTapped()

```
