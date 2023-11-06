//
//  NoUnmappedDestinationsTests.swift
//  
//
//  Created by Brandon Sneed on 10/24/23.
//

import XCTest
import Segment
@testable import SegmentConsent
@testable import SegmentConsentOneTrust

#if os(tvOS)
import OTPublishersHeadlessSDKtvOS
#else
import OTPublishersHeadlessSDK
#endif

final class ConsentPrefsNotAvailableTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNoConsentPrefs() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "SegmentConsentPref.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        
        let consentProvider = OneTrustProvider()
        
        let consentManager = ConsentManager(provider: consentProvider)
        analytics.add(plugin: consentManager)
        
        @Atomic var otStarted = false
        
        OTPublishersHeadlessSDK.shared.startSDK(
            storageLocation: "cdn.cookielaw.org",
            domainIdentifier: secrets.oneTrustAPIKey,
            languageCode: "en"
        ) { response in
            consentManager.start()
            otStarted = true
        }
        
        while otStarted == false {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        waitUntilStarted(analytics: analytics)
        
        // reject all categories in OneTrust
        OTPublishersHeadlessSDK.shared.clearOTSDKData()

        RunLoop.main.run(until: Date.distantPast)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        // We have no consent preferences at all.  All data blocked.
        XCTAssertTrue(segmentOutput.lastEvent == nil)
        XCTAssertTrue(output1.lastEvent == nil)
        
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
    }
    
}
