//
//  CalloutViewPresenter.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 21.11.23.
//

import DesignSystem
import UIKit

extension CalloutView.ViewData: GenericListViewData { }

class CalloutViewPresenter: GenericListViewPresenterType {
    typealias View = GenericListTableViewController<CalloutViewDataSource, CalloutViewPresenter>

    var view: View? {
        didSet {
            view?.title = "Callout View"
            view?.update(with: dummy())
        }
    }

    func dummy() -> [CalloutView.ViewData] {
        return [CalloutView.ViewData(title: "Title", description: "Information", calloutType: .informational),
                CalloutView.ViewData(title: "Title", description: "Information", calloutType: .success),
                CalloutView.ViewData(title: "Title", description: "Information", calloutType: .warning),
                CalloutView.ViewData(title: "Title", description: "Information", calloutType: .error),

                CalloutView.ViewData(title: nil, description: "Information", calloutType: .informational),
                CalloutView.ViewData(title: nil, description: "Information", calloutType: .success),
                CalloutView.ViewData(title: nil, description: "Information", calloutType: .warning),
                CalloutView.ViewData(title: nil, description: "Information", calloutType: .error),

                CalloutView.ViewData(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non iaculis ipsum. Donec tellus nisi, mattis sit amet ligula ut, ultrices imperdiet quam. Vivamus sagittis magna nec dui pretium porta at eget justo. Curabitur feugiat est tristique, laoreet sapien id, molestie velit. In nec mi malesuada, condimentum orci non, ultrices massa. Mauris ac semper nunc. Quisque placerat porttitor metus non rutrum. Mauris cursus orci vel tortor maximus, in pellentesque arcu tincidunt. Phasellus convallis ex sit amet congue euismod.",
                                     calloutType: .informational),
                CalloutView.ViewData(title: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", calloutType: .informational),

                CalloutView.ViewData(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non iaculis ipsum. Donec tellus nisi, mattis sit amet ligula ut, ultrices imperdiet quam. Vivamus sagittis magna nec dui pretium porta at eget justo. Curabitur feugiat est tristique, laoreet sapien id, molestie velit. In nec mi malesuada, condimentum orci non, ultrices massa. Mauris ac semper nunc. Quisque placerat porttitor metus non rutrum. Mauris cursus orci vel tortor maximus, in pellentesque arcu tincidunt. Phasellus convallis ex sit amet congue euismod.",
                                     calloutType: .success),
                CalloutView.ViewData(title: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", calloutType: .success),

                CalloutView.ViewData(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non iaculis ipsum. Donec tellus nisi, mattis sit amet ligula ut, ultrices imperdiet quam. Vivamus sagittis magna nec dui pretium porta at eget justo. Curabitur feugiat est tristique, laoreet sapien id, molestie velit. In nec mi malesuada, condimentum orci non, ultrices massa. Mauris ac semper nunc. Quisque placerat porttitor metus non rutrum. Mauris cursus orci vel tortor maximus, in pellentesque arcu tincidunt. Phasellus convallis ex sit amet congue euismod.",
                                     calloutType: .warning),
                CalloutView.ViewData(title: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", calloutType: .warning),

                CalloutView.ViewData(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non iaculis ipsum. Donec tellus nisi, mattis sit amet ligula ut, ultrices imperdiet quam. Vivamus sagittis magna nec dui pretium porta at eget justo. Curabitur feugiat est tristique, laoreet sapien id, molestie velit. In nec mi malesuada, condimentum orci non, ultrices massa. Mauris ac semper nunc. Quisque placerat porttitor metus non rutrum. Mauris cursus orci vel tortor maximus, in pellentesque arcu tincidunt. Phasellus convallis ex sit amet congue euismod.",
                                     calloutType: .error),
                CalloutView.ViewData(title: nil, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", calloutType: .error)
        ]
    }
}
