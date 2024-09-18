#  Coordinator

> This documentation is possibly out of date. Please read with a grain of salt.

- is responsible for the navigation between screens (within and across features). Coordinators are the only objects that are aware of navigation in the app
- can **delegate** navigation to **child** or **parent coordinators**
- **encapsulates and hides all screen navigation** (presentation & dismissal)
- is instantiated with a `UINavigationController` which is presented by another coordinator. The `UINavigationController` is used to initialize a `SectionedNavigationController` instance
- is held strongly by all presenters of the screens
- might have weak references to child coordinators, parent coordinators and presenters
- does **not** perform any **business logic** (incl. loading and transforming data; defining when or where to navigate to)
- instantiates view controllers, presenters and child coordinators and is resposible for injecting the required dependencies to them
- the dependencies injected by a coordinator to controllers, presenters and child coordinators sometimes vary based on the scenario, hence we can't always use DIKit (This is open for change in the future though)
- as a coordinator is there to coordinate something, it needs a `UINavigationController` to push or present view controllers to or on. Making it more generic makes the code more complex for no good reason
- A `UINavigationController` can be shared between multiple coordinators and that's why `SectionedNavigationController` is there

## Open Questions

- Should we define how a Coordinator remembers if a Child Coordinator is presenting something?
- If a Coordinator wants to present something modally (e.g. an alert) can it always do that? By just finding the top most View Controller? Does that make our lives harder? Or should only one Coordinator present something modally? Or something else?

## References

* http://khanlou.com/2015/01/the-coordinator/
* http://khanlou.com/tag/advanced-coordinators/
* https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps
* https://www.hackingwithswift.com/articles/175/advanced-coordinator-pattern-tutorial-ios
