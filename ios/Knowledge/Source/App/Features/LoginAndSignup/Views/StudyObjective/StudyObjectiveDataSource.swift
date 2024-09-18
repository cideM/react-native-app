//
//  StudyObjectiveDataSource.swift
//  Knowledge
//
//  Created by Silvio Bulla on 16.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

final class StudyObjectiveDataSource: NSObject {

    private let studyObjectives: [StudyObjective]

    init(studyObjectives: [StudyObjective]) {
        self.studyObjectives = studyObjectives
    }

    func studyObjectiveAtIndex(_ index: Int) -> StudyObjective? {
        guard index >= 0, index < studyObjectives.count else { return nil }
        return studyObjectives[index]
    }

    func indexOfStudyObjectiveWithId(_ id: String) -> Int? {
        studyObjectives.firstIndex { $0.eid == id }
    }

    func setupTableView(_ tableView: UITableView) {
        tableView.register(SelectableTableViewCell.self, forCellReuseIdentifier: SelectableTableViewCell.reuseIdentifier)
    }
}

extension StudyObjectiveDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studyObjectives.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableTableViewCell.reuseIdentifier, for: indexPath)
        guard let selectableCell = cell as? SelectableTableViewCell else { return cell }
        guard let studyObjective = studyObjectiveAtIndex(indexPath.row) else {
            assert(false, "requested a cell out of bounds")
            return selectableCell
        }
        selectableCell.textLabel?.text = studyObjective.name
        return selectableCell
    }
}
