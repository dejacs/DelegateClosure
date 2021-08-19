import UIKit
import PlaygroundSupport

// Uma tela que tem uma subview com um botão
// Delegate ou closure
// Camadas: ViewController, Interactor, Presenter, Factory, Coodinator
// weak, unowned e strong
// ViewController -> Interactor -> Presenter -weak-> ViewController (fecha o fluxo = referência fraca)
// ViewController -> Interactor -> Presenter -> Coordinator -weak-> ViewController (fecha o fluxo = referência fraca)


// -------- Factory --------

enum TelaFactory {
    static func make() -> UIViewController {
        let coordinator = TelaCoordinator()
        let presenter = TelaPresenter(coordinator: coordinator)
        let interactor = TelaInteractor(presenter: presenter)
        let viewController = TelaViewController(interactor: interactor)
        
        presenter.viewController = viewController
        coordinator.viewController = viewController
        
        return viewController
    }
}

// -------- Coordinator --------

enum TelaAction {
    case confirm
}

protocol TelaCoordinating {
    var viewController: UIViewController? { get set }
    func perform(action: TelaAction)
}

final class TelaCoordinator: TelaCoordinating {
    weak var viewController: UIViewController?
    
    func perform(action: TelaAction) {
        guard case .confirm = action else { return }
        viewController?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}

// -------- Presenter --------

protocol TelaPresenting {
    var viewController: TelaDisplaying? { get set }
    func didNextStep(action: TelaAction)
}

final class TelaPresenter: TelaPresenting {
    private let coordinator: TelaCoordinating
    weak var viewController: TelaDisplaying?
    
    init(coordinator: TelaCoordinating) {
        self.coordinator = coordinator
    }
    
    func didNextStep(action: TelaAction) {
        coordinator.perform(action: action)
    }
}

// -------- Interactor --------

protocol TelaInteracting: ButtonActionDelegate {
    func didConfirm()
}

final class TelaInteractor: TelaInteracting {
    private let presenter: TelaPresenting
    
    init(presenter: TelaPresenting) {
        self.presenter = presenter
    }
    
    func didConfirm() {
        presenter.didNextStep(action: .confirm)
    }
    
    func didConfirmSecondary() {
        presenter.didNextStep(action: .confirm)
    }
}

// -------- View Controller --------

protocol TelaDisplaying: AnyObject { }

final class TelaViewController: UIViewController {
    private let interactor: TelaInteracting
    
    private lazy var buttonView: UIView = {
        let view = ButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .cyan
        view.buttonAction = { self.interactor.didConfirm() } // Aqui está chamando diretamente a função do interactor
        return view
    }()
    
    private lazy var secondaryButtonView: UIView = {
        let view = SecondaryButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
        view.buttonActionDelegate = interactor // Aqui o interactor está sendo encarregado de implementar buttonActionDelegate
        return view
    }()
    
    init(interactor: TelaInteracting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Telona"
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .magenta
        view.addSubview(buttonView)
        view.addSubview(secondaryButtonView)
        
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonView.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
        
        NSLayoutConstraint.activate([
            secondaryButtonView.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 10),
            secondaryButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            secondaryButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            secondaryButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            secondaryButtonView.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
    }
}

extension TelaViewController: TelaDisplaying { }

//                                                             Closure
// ------------------------------------------------------------------------------------------------------------------------

final class ButtonView: UIView {
    var buttonAction: (() -> Void)?
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .purple
        button.setTitle("Confirmar", for: .normal)
        button.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            confirmButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 120.0),
            confirmButton.heightAnchor.constraint(equalToConstant: 40.0),
            confirmButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20.0),
            confirmButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20.0)
        ])
    }
    
    required init?(coder: NSCoder) { nil }
}

@objc
extension ButtonView {
    func confirmButtonDidTap() {
        buttonAction?()
    }
}

//                                                             Delegate
// ------------------------------------------------------------------------------------------------------------------------

protocol ButtonActionDelegate {
    func didConfirmSecondary()
}

final class SecondaryButtonView: UIView {
    var buttonActionDelegate: ButtonActionDelegate?
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Confirmar", for: .normal)
        button.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            confirmButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 120.0),
            confirmButton.heightAnchor.constraint(equalToConstant: 40.0),
            confirmButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20.0),
            confirmButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20.0)
        ])
    }
    
    required init?(coder: NSCoder) { nil }
}

@objc
extension SecondaryButtonView {
    func confirmButtonDidTap() {
        buttonActionDelegate?.didConfirmSecondary()
    }
}

// -------- Playground --------

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = UINavigationController(rootViewController: TelaFactory.make())
