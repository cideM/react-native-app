//
//  LibraryDownloadStateViewMock.swift
//  KnowledgeTests
//
//  Created by Azadeh Richter on 28.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
@testable import Knowledge_DE

class LibraryDownloadStateViewMock: LibraryDownloadStateViewType {

    private(set) var setProgressCallCount = 0
    private(set) var progress: Double?
    func setProgress(_ progress: Double) {
        setProgressCallCount += 1
        self.progress = progress
    }

    private(set) var setInstallingCallCount = 0
    func setInstalling() {
        setInstallingCallCount += 1
    }

    private(set) var setIsUpToDateCallCount = 0
    func setIsUpToDate() {
        setIsUpToDateCallCount += 1
    }

    private(set) var setIsFailedCallCount = 0
    func setIsFailed() {
        setIsFailedCallCount += 1
    }

}
