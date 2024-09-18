//
//  GalleryDatasource.swift
//  Knowledge
//
//  Created by CSH on 03.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

final class GalleryDatasource: NSObject {

    private let presenters: [GalleryImageViewPresenterType]

    init(presenters: [GalleryImageViewPresenterType]) {
        self.presenters = presenters
    }

    func presenter(at index: Int) -> GalleryImageViewPresenterType? {
        guard index < presenters.count, index >= 0 else { return nil }
        return presenters[index]
    }

    func index(for presenter: GalleryImageViewPresenterType) -> Int? {
        presenters.firstIndex { $0 === presenter }
    }

    func index(for image: ImageResourceType) -> Int? {
        presenters.firstIndex { $0.image.imageResourceIdentifier == image.imageResourceIdentifier }
    }

    func viewController(at index: Int) -> UIViewController? {
        guard let presenter = presenter(at: index) else { return nil }

        let viewController = GalleryImageViewController(presenter: presenter)
        viewController.title = "\(index + 1)/\(presenters.count)"
        return viewController
    }

}

extension GalleryDatasource: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.index(of: viewController) else { return nil }

        return self.viewController(at: index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.index(of: viewController) else { return nil }

        return self.viewController(at: index + 1)
    }

    func index(of viewController: UIViewController) -> Int? {
        guard let nextViewController = viewController as? GalleryImageViewController else { return nil }
        let nextPresenter = nextViewController.presenter
        return index(for: nextPresenter)
    }
}
