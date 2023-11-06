//
//  Provider.swift
//  
//
//  Created by Brandon Sneed on 9/12/23.
//

import Foundation
import Segment
import SegmentConsent
#if os(tvOS)
import OTPublishersHeadlessSDKtvOS
#else
import OTPublishersHeadlessSDK
#endif

enum OneTrustCategories: Error {}

public class OneTrustProvider: NSObject, ConsentCategoryProvider {
    public var changeCallback: ConsentChangeCallback? = nil
    
    internal let oneTrust = OTPublishersHeadlessSDK.shared
    internal weak var plugin: ConsentManager? = nil
    internal var oneTrustCategories: [String] {
        get {
            var result = [String]()
            let domainData = OTPublishersHeadlessSDK.shared.getDomainGroupData()
            guard let groups = domainData?["Groups"] as? [[String: Any]] else { return result }
            for group in groups {
                if let groupId = group["OptanonGroupId"] as? String {
                    result.append(groupId)
                }
            }
            return result
        }
    }
    
    public var categories: [String: Bool] {
        var categoryValues = [String: Bool]()
        
        oneTrustCategories.forEach { category in
            let consent = oneTrust.getConsentStatus(forCategory: category)
            if consent == 1 {
                categoryValues[category] = true
            } else if consent == 0 {
                categoryValues[category] = false
            } else if consent == -1 {
                // this category isn't actually defined for this onetrust setup, so ignore it.
            }
        }
        
        return categoryValues
    }
    
    @objc func oneTrustConsentUpdated(_ notification: Notification) {
        guard let changeCallback else { return }
        
        changeCallback()
        print("OT Consent Changed to: \(categories)")
    }
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(oneTrustConsentUpdated(_:)), name: Notification.Name("OTConsentUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(NSNotification.Name("OTConsentUpdated"))
    }
}
