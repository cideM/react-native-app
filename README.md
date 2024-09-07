## MDF reading experiences POC 

This project implements a React native view into an IOS Swift app. I have followed the steps outlined in [Integrating a react native view in an existing app](https://reactnative.dev/docs/integration-with-existing-apps)

### Get started
Set up your environment as per instructions above.
In the root directory, run 
```
npm ci
npm start
```
to start the React native application server at http://localhost:8081. This serves the application bundle that is launched into a Javascript virtual machine within IOS application.

The `ios` folder contains the sample IOS application that contains a link that lauches the react native view. Within `ios` folder, run 

```
pod install
```
Open `ios` project in `xcode` and build and run it within `IOS simulator`. 