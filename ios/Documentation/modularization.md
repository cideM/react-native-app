#  Modularization

> This documentation is possibly out of date. Please read with a grain of salt.

We dediced to start with vertical (layers) modularization and will refrain from using horizontal (features) modularization for the time being.

## Interfaces

The `Interfaces` library is a static library that contains all interfaces and models that need to be known by multiple modules. For example a model that can be fetched from a server and can be stored.

## Common

The `Common` interface is still a leftover of the old modularization. This should eventually be split up and moved into the "correct" modules, such as the module for the views, and such.

## Networking

The `Networking` component holds all logic for performing network related tasks and should abstract and hide the "how" the network calls are made.

## DeveloperOverlay

The `DeveloperOverlay` is the only leftover feature component. It is a reimplementation of the [TBODeveloperOverlay](https://github.com/tbointeractive/TBODeveloperOverlay) since it wasn't implemented in swift back then. It should just be replaced by that.
