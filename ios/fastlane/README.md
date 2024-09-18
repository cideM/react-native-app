fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios certificates

```sh
[bundle exec] fastlane ios certificates
```

Syncs code signing. Execute `fastlane certificates` and keys, certs and profiles for all targets will be synced.

### ios regenerate_development_certificates_and_profiles

```sh
[bundle exec] fastlane ios regenerate_development_certificates_and_profiles
```

Revokes development certificates and profiles and generates new ones

### ios regenerate_certificates_and_profiles

```sh
[bundle exec] fastlane ios regenerate_certificates_and_profiles
```

Revokes all certificates and profiles and generates new ones

### ios test_unittests

```sh
[bundle exec] fastlane ios test_unittests
```

Perform all unit tests

### ios build_and_upload_qa

```sh
[bundle exec] fastlane ios build_and_upload_qa
```

Builds a QA build and uploads it to firebase app distribution.

### ios build_and_upload_release

```sh
[bundle exec] fastlane ios build_and_upload_release
```

Builds a Release version and uploads to Appstore Connect for TestFligt testing

### ios update_partial_archive

```sh
[bundle exec] fastlane ios update_partial_archive
```

Updates partial archive

### ios update_graphql_schema

```sh
[bundle exec] fastlane ios update_graphql_schema
```

Executes the Apolloscript schema which will update the API.swift based on the schema.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
