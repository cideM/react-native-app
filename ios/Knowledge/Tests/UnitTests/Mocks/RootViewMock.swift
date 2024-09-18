//
//  RootViewMock.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 11.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE

class RootViewMock: RootViewType {

    var selectedIndex: Int = 0

    var onPresentWifAutoUpdateAlertCount = 0
    var onPresentWifiAutoUpdateAlert: () -> Void = { }
    func presentWifiAutoUpdateAlert() {
        onPresentWifAutoUpdateAlertCount += 1
        onPresentWifiAutoUpdateAlert()
    }

    var onPresentLoadingLibraryErrorCount = 0
    var onPresentLoadingLibraryError: (_ error: PresentableMessageType) -> Void = { _ in }
    func presentLoadingLibraryError(_ error: PresentableMessageType) {
        onPresentLoadingLibraryErrorCount += 1
        onPresentLoadingLibraryError(error)
    }

    var onUpdateProgressViewCount = 0
    var onUpdateProgressView: (Float) -> Void = { _ in }
    func updateProgressView(with progress: Float) {
        onUpdateProgressViewCount += 1
        onUpdateProgressView(progress)
    }

    var onHideProgressViewCount = 0
    var onHideProgressView: () -> Void = { }
    func hideProgressView() {
        onHideProgressViewCount += 1
        onHideProgressView()
    }

    var onShowLibraryUpdateErrorCount = 0
    var onShowLibraryUpdateError: () -> Void = { }
    func showLibraryUpdateError() {
        onShowLibraryUpdateErrorCount += 1
        onShowLibraryUpdateError()
    }
}
