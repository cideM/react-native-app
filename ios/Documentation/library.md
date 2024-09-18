### Testing Out of Storage Errors

We need to make sure that the app behaves in the expected way when the device goes out of storage. The following scenarios need to be covered:

1- The device goes out of storage while downloading a library update.
2- The device goes out of storage while unzipping a library update.
3- The device goes out of storage while preprocessing an unzipped library update.

To trigger the 1st kind of out of storage error, create a small disk image (2 megabytes for example) and mount it to the Caches directory. Here are the steps:

- Add a breakpoint before starting the library update.
- Create a 2 megabytes disk image use: `hdiutil create -size 2m -fs HFS+ /tmp/2meg.dmg`.
- Mount the image to the Caches directory: `hdiutil attach /tmp/2meg.dmg -mountpoint .../Library/Developer/CoreSimulator/Devices/.../data/Containers/Data/Application/.../Library/Caches`.
- Release the breakpoint to start the update.

To trigger the 2nd kind of out of storage error, create a small disk image (2 megabytes for example) also and mount it to the tmp directory. Here are the steps:

- Add a breakpoint before starting the unzipping process.
- Create a 2 megabytes disk image use: `hdiutil create -size 2m -fs HFS+ /tmp/2meg.dmg`.
- Mount the image to the tmp folder (where the unzipping actually takes place): `hdiutil attach /tmp/2meg.dmg -mountpoint .../Library/Developer/CoreSimulator/Devices/.../data/Containers/Data/Application/.../tmp`.
- Release the breakpoint to start the unzipping process.

To trigger the 3rd kind of out of storage error, create a small disk image (2 megabytes for example) also and mount it to the tmp directory. Here are the steps:

- Add a breakpoint before starting the preprocessing.
- Create a 2 megabytes disk image use: `hdiutil create -size 2m -fs HFS+ /tmp/2meg.dmg`.
- Mount the image to the tmp folder (where the unzipping actually takes place): `hdiutil attach /tmp/2meg.dmg -mountpoint .../Library/Developer/CoreSimulator/Devices/.../data/Containers/Data/Application/.../tmp`.
- Release the breakpoint to start the unzipping process.
