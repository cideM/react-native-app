//
//  CatifyFloret.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 10.10.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import Cauliframework
import UIKit

class CatifyFloret: InterceptingFloret, DisplayingFloret {

    var enabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "CatifyFloret.enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CatifyFloret.enabled")
        }
    }
    var type: PlaceholderType {
        get {
            guard let rawType = UserDefaults.standard.string(forKey: "CatifyFloret.type"),
                  let type = PlaceholderType(rawValue: rawType) else {
                return .placekitten
            }
            return type
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "CatifyFloret.type")
        }
    }

    func willRequest(_ record: Record, modificationCompletionHandler completionHandler: @escaping (Record) -> Void) {
        if let url = record.designatedRequest.url, url.path.hasSuffix(".jpg") {
            var newRecord = record
            var newRequest = record.designatedRequest
            newRequest.url = type.placeholder(for: url) ?? url
            newRecord.designatedRequest = newRequest
            completionHandler(newRecord)
        } else {
            return completionHandler(record)
        }
    }

    func didRespond(_ record: Record, modificationCompletionHandler completionHandler: @escaping (Record) -> Void) {
        completionHandler(record)
    }

    func viewController(_ cauli: Cauli) -> UIViewController {
        let viewController = CatifyFloretViewController(nibName: nil, bundle: nil)
        viewController.catifyFloret = self
        return viewController
    }
}

extension CatifyFloret {
    enum PlaceholderType: String, CaseIterable {
        case placekitten // https://placekitten.com
        case placesloth // https://placesloth.com
        case placeskull // https://placeskull.com
        case placedog // https://placedog.net
        case baconmockup // https://baconmockup.com
        case placebear // https://placebear.com
        case cageme // https://cageme.herokuapp.com
        case placebeard // http://placebeard.it
        case placecage // https://www.placecage.com
        case fillmurray // https://www.fillmurray.com
        case placekeanu

        var name: String {
            switch self {
            case .placekitten: return "Kitten"
            case .placesloth: return "Sloth"
            case .placeskull: return "Skull"
            case .placedog: return "Dog"
            case .baconmockup: return "Bacon"
            case .placebear: return "Bear"
            case .cageme: return "Cage"
            case .placebeard: return "Beard"
            case .placecage: return "Cage 2"
            case .fillmurray: return "Murray"
            case .placekeanu: return "Keanu"
            }
        }

        func placeholder(for url: URL) -> URL? {
            let width = max(10, abs(url.hashValue) % 100) + 300
            let height = max(10, (abs(url.hashValue) / 100) % 100) + 300

            switch self {
            case .placekitten: return URL(string: "https://placekitten.com/\(width)/\(height)")
            case .placesloth: return URL(string: "https://placesloth.com/\(width)/\(height)")
            case .placeskull: return URL(string: "https://placeskull.com/\(width)/\(height)")
            case .placedog: return URL(string: "https://placedog.net/\(width)/\(height)")
            case .baconmockup: return URL(string: "https://baconmockup.com/\(width)/\(height)")
            case .placebear: return URL(string: "https://placebear.com/\(width)/\(height)")
            case .cageme: return URL(string: "https://cageme.herokuapp.com/\(width)/\(height)")
            case .placebeard: return URL(string: "https://placebeard.it/\(width)/\(height)")
            case .placecage: return URL(string: "https://www.placecage.com/\(width)/\(height)")
            case .fillmurray: return URL(string: "https://www.fillmurray.com/\(width)/\(height)")
            case .placekeanu: return URL(string: "https://placekeanu.com/\(width)/\(height)")
            }

        }
    }
}

class CatifyFloretViewController: UIViewController {
    var catifyFloret: CatifyFloret?

    @IBOutlet private weak var typeButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let catifyFloret = catifyFloret else { return }
        typeButton.setTitle(catifyFloret.type.name, for: .normal)
    }

    @IBAction private func didTapTypeButton(_ button: UIButton) {
        let controller = UIAlertController(title: "Type", message: "", preferredStyle: .actionSheet)
        for type in CatifyFloret.PlaceholderType.allCases {
            controller.addAction(UIAlertAction(title: type.name, style: .default) { [catifyFloret, button] _ in
                guard let catifyFloret = catifyFloret else {
                    return
                }
                catifyFloret.type = type
                button.setTitle(type.name, for: .normal)
            })
        }
        self.present(controller, animated: true)
    }

}
#endif
