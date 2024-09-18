//
//  PharmaOptInDialog.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 15.06.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

enum PharmaOfflineOptInDialog {

    static func presentIfRequired(above view: PharmaViewType, using pharmaService: PharmaDatabaseApplicationServiceType, and pharmaRepository: PharmaRepositoryType) {

        // "var " is required in order to update the properties of these objects below ...
        var pharmaRepository = pharmaRepository
        var pharmaService = pharmaService

        if  pharmaService.pharmaDatabase == nil,
            pharmaRepository.shouldShowPharmaOfflineDialog,
            pharmaRepository.pharmaDialogWasDisplayedDate.daysAgo >= 1,
            pharmaRepository.pharmaResultWasDisplayedCount >= 5 {

            let message = PresentableMessage(title: L10n.Search.Pharma.Offline.Optin.Alert.title.description,
                                             description: L10n.Search.Pharma.Offline.Optin.Alert.description.description,
                                             logLevel: .debug)
            view.presentMessage(message, actions: [

                // Kick off database download ...
                MessageAction(title: L10n.Search.Pharma.Offline.Optin.Alert.Action.download.description, style: .primary) {
                    do {
                        // No need to show this any more now sicne the user opted in ...
                        pharmaRepository.shouldShowPharmaOfflineDialog = false

                        // Download the db ...
                        pharmaService.isBackgroundUpdatesEnabled = true
                        try pharmaService.startManualUpdate()

                        // Confirm that download will start. This just makes sure the user gets some extra confirmation.
                        // Otherwise the interaction feels odd cause after agreeing to download the db nothing else really happens on screen.
                        view.presentMessage(PresentableMessage(title: L10n.Search.Pharma.Offline.Optin.Confirmation.Alert.title.description,
                                                               description: L10n.Search.Pharma.Offline.Optin.Confirmation.Alert.description.description,
                                                               logLevel: .debug), actions: [
                            MessageAction(title: L10n.Search.Pharma.Offline.Confirmation.Alert.Action.ok.description, style: .normal) { true }
                        ])

                    } catch {
                        // The only error that could potentially be thrown here is: PharmaDatabaseApplicationServiceError.busy
                        // This is very very unlikely, but still show a generic error message in case it happens
                        // Also keep it generic cause the compiler can not guarantee this error and hence you never know ...
                        let title = L10n.Search.Pharma.Offline.Optin.ConfirmationError.Alert.title
                        view.presentMessage(PresentableMessage(title: title, description: "", logLevel: .debug), actions: [
                            MessageAction(title: L10n.Search.Pharma.Offline.ConfirmationError.Alert.Action.ok.description, style: .normal) { true }
                        ])

                        let monitor: Monitoring = resolve()
                        monitor.error(error, context: .pharma)
                    }

                    return true
                },

                // Skip and do nothing,
                // the default rules of display for the "opt in" dialog will still apply ...
                MessageAction(title: L10n.Search.Pharma.Offline.Optin.Alert.Action.notnow.description, style: .normal) {
                    true
                },

                // Never ask again ...
                MessageAction(title: L10n.Search.Pharma.Offline.Optin.Alert.Action.dontaskagain.description, style: .normal) {
                    pharmaRepository.shouldShowPharmaOfflineDialog = false
                    return true
                }
            ])
        }
    }
}
