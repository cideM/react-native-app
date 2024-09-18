# Dependency Injection

> This documentation is possibly out of date. Please read with a grain of salt.

## Dependency Injection in the MVP Layer

Every element in the MVP layer expects dependencies to be either injected via *constructor injection* or *property injection*.

## Dependency Injection in the Coordinator Layer

A very simple [DI Framework](https://github.com/Liftric/DIKit) was added to the project but not all dependencies are replaced by DI resolve calls yet. The boy-scout-rule applies to improve this situation. 

## Additional Literature

* http://ilya.puchka.me/dependency-injection-in-swift/
* https://theswiftdev.com/2018/07/17/swift-dependency-injection-design-pattern/
* https://medium.com/@JoyceMatos/dependency-injection-in-swift-87c748a167be
