//
//  BasicExampleApp.swift
//  BasicExample
//
//  Created by Brandon Sneed on 2/23/22.
//

import SwiftUI
import Segment
import SegmentConsent
import SegmentConsentOneTrust

#if os(tvOS)
import OTPublishersHeadlessSDKtvOS
#else
import OTPublishersHeadlessSDK
#endif

@main
struct BasicExampleApp: App {
    var body: some Scene {
        WindowGroup {
            // necessary to get us a viewcontroller for onetrust to use.
            UIHostingController(rootView: ContentView()).rootView
        }
    }
}

extension UIApplication {
    // get the view controller we set up in swiftUI to give to onetrust.
    // maybe they'll support SwiftUI at some point.  :man-shrugging:
    var mainViewController: UIViewController? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let activeScene = windowScenes.first
        let keyWindow = activeScene?.keyWindow
        return keyWindow?.rootViewController
    }
}

extension Analytics {
    static var main: Analytics = {
        Analytics.debugLogsEnabled = true
        
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
        analytics.add(plugin: consentManager)
        // Optionally add the IDFAConsent plugin if ATT is to be used.
        // It will capture ATT changes and notify the consent manager.
        // You'll need to copy this code into YOUR codebase and modify it
        // to suit your needs.
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
        
        return analytics
    }()
}
