//
//  SplashScreenViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 27.07.23.
//

import UIKit
import DesignSystem

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        dismissSplashScreen()
    }

    private func setup() {
        let image = UIImage(named: "Splash-Icon")!
        let imageView = UIImageView(frame: CGRectZero)
        imageView.frame = CGRectMake(0.0, 0.0, image.size.width / 2.0, image.size.height / 2.0)
        imageView.image = image
        imageView.constrainSize(imageView.frame.size)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.center(in: view)
        view.backgroundColor = UIColor(0xff067c89)
    }

    private func dismissSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.alpha = 0.0
            } completion: { _ in
                self?.view.removeFromSuperview()
                self?.view = nil
            }
        }
    }
}
