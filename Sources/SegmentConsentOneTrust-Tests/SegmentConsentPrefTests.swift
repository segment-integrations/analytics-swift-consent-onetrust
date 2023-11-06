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

final class SegmentConsentPrefTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNoToAll() {
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
        
        // C0001 is always true
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0002", consentValue: false)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0003", consentValue: false)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0004", consentValue: false)
        OTPublishersHeadlessSDK.shared.saveConsent(type: .preferenceCenterConfirm)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        // You would think these two are incorrect.  However, onetrust marks C0001 as
        // `required`, so events will always go to Segment as well as Dest1.
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent != nil)
        
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
    }
    
    func testYesTo1() {
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
        // C0001 is always true
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0002", consentValue: true)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0002", consentValue: false)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0003", consentValue: false)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0004", consentValue: false)
        OTPublishersHeadlessSDK.shared.saveConsent(type: .preferenceCenterConfirm)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))

        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent != nil)
        
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
    }
    
    func testYesTo2() {
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
        
        // C0001 is always true
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0002", consentValue: true)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0003", consentValue: false)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0004", consentValue: false)
        OTPublishersHeadlessSDK.shared.saveConsent(type: .preferenceCenterConfirm)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
        
        XCTAssertEqual(OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: "C0002"), 1)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent != nil)
        
        XCTAssertTrue(output2.lastEvent != nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
    }
    
    func testConsentChange() {
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
        
        @Atomic var consentChangeFound = false
        let consentManager = ConsentManager(provider: consentProvider) {
            consentChangeFound = true
        }
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
        // C0001 is always true
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0002", consentValue: true)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0003", consentValue: false)
        OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: "C0004", consentValue: false)
    
        OTPublishersHeadlessSDK.shared.saveConsent(type: .preferenceCenterConfirm)
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
        
        XCTAssertEqual(OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: "C0002"), 1)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent != nil)
        
        XCTAssertTrue(output2.lastEvent != nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
        
        XCTAssertTrue(consentChangeFound)
    }
}
