# Segment Consent Management - OneTrust Integration

Add Segment + OneTrust driven consent management support for your application via this plugin for [Analytics-Swift](https://github.com/segmentio/analytics-swift) 

Read more about Segment's Consent Management solutions [here](https://segment.com/docs/privacy/configure-consent-management/), as well as enabling it for your workspace.

## Getting Started

### via Xcode
In the Xcode `File` menu, click `Add Packages`.  You'll see a dialog where you can search for Swift packages.  In the search field, enter the URL to these repos.

https://github.com/segment-integrations/analytics-swift-consent
https://github.com/segment-integrations/analytics-swift-consent-onetrust

You'll then have the option to pin to a version, or specific branch, as well as which project in your workspace to add it to.  Once you've made your selections, click the `Add Package` button.  

### via Package.swift

Open your Package.swift file and add the following to your `dependencies` section:

```
.package(
            name: "SegmentConsent",
            url: "https://github.com/segment-integrations/analytics-swift-consent.git",
            from: "1.0.0"
        ),
.package(
            name: "SegmentConsentOneTrust",
            url: "https://github.com/segment-integrations/analytics-swift-consent-onetrust.git",
            from: "1.0.0"
        ),
```

Next you'll need to write some setup/init code where you have your
Analytics setup:

```swift
import Segment
import SegmentConsent
import SegmentConsentOneTrust

...

let analytics = Analytics(configuration: Configuration(writeKey: "<your write key>")
            .flushAt(1)
            .trackApplicationLifecycleEvents(true))

// Add the Segment Consent Manager plugin.
// We'll need the value of this so we can call
// start(), to once OneTrust is configured.
let consentManager = ConsentManager(provider: OneTrustProvider()) {
    // we were notified (optionally) that consent changed.
    print("Consent Changed")
}

// Optionally add the IDFAConsent plugin if ATT is to be used.
// It will capture ATT changes and notify the consent manager.
// You'll need to copy this code into YOUR codebase and modify it
// to suit your needs.
// NOTE: The code for this plugin can be found in the example app.
analytics.add(plugin: IDFAConsent())

// once we do the setup, onetrust triggers the consent UI to pop up on
// it's own.  you can do it manually if you prefer though, but any way
// you slice it, you'll need a uiviewcontroller.
if let mainViewController = UIApplication.shared.mainViewController {
    OTPublishersHeadlessSDK.shared.setupUI(mainViewController, UIType: .preferenceCenter)
}

// Tell OneTrush SDK to start.
OTPublishersHeadlessSDK.shared.startSDK(
    storageLocation: "cdn.cookielaw.org",
    domainIdentifier: "<your domain identifier>",
    languageCode: "en"
) { response in
    // Tell the Semgnet consent manager to start.  Until this happens,
    // all events are queued so they can get the proper stamps and treatment.
    consentManager.start()
}

```

The Consent Manager plugin will automatically add a ConsentBlockingPlugin to any device mode destinations, so there's no extra steps for you to do in your code. Blocking for cloud mode destinations will be handled server-side at Segment.
