//
//  PharmaViewController+CellDelegates.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

extension PharmaViewController: PharmaSubstanceCellDelegate, PharmaFeedbackCellDelegate {

    func otherPreparationsTapped() {
        presenter.otherPreparationsTapped()
    }

    func sendFeedback() {
        presenter.sendFeedback()
    }
}

extension PharmaViewController: PharmaDrugCellDelegate {
    func showAllPricesAndPackageSizes() {
        presenter.showPricesAndPackageSizes()
    }
}
