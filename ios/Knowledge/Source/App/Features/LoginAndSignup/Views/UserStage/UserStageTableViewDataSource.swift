//
//  UserStageTableViewDataSource.swift
//  LoginAndSignup
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import DesignSystem
import Common
import Domain
import UIKit

internal final class UserStageTableViewDataSource: NSObject {

    private let viewData: UserStageViewData

    init(viewData: UserStageViewData) {
        self.viewData = viewData
    }

    func setup(_ tableView: UITableView) {
        tableView.register(SelectableDetailTableViewCell.self, forCellReuseIdentifier: SelectableDetailTableViewCell.reuseIdentifier)
    }

    func item(at index: Int) -> UserStageViewData.Item? {
        assert(index < viewData.items.count)
        return viewData.items[index]
    }

    func index(for userStage: UserStage) -> Int? {
        viewData.items.firstIndex { $0.stage == userStage }
    }

    var initialDisclaimerVisisbility: UserStageViewData.DisclaimerState {
        viewData.discalimerState
    }
}

extension UserStageTableViewDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewData.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableDetailTableViewCell.reuseIdentifier, for: indexPath)
        guard let selectableCell = cell as? SelectableDetailTableViewCell,
            let item = item(at: indexPath.row) else { return cell }
        selectableCell.set(title: item.title, description: item.description)
        return selectableCell
    }
}
