// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// OneTrust only supports iOS and tvOS, and weirdly.  Y U SO SAD?

let package = Package(
    name: "SegmentConsentOneTrust",
    platforms: [
        .iOS("13.0"),
        .tvOS("11.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SegmentConsentOneTrust",
            targets: ["SegmentConsentOneTrust"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Zentrust/OTPublishersHeadlessSDKtvOS.git", from: "202309.1.0"),
        .package(url: "https://github.com/Zentrust/OTPublishersHeadlessSDK.git", from: "202309.1.0"),
        .package(url: "https://github.com/segmentio/analytics-swift.git", from: "1.4.8"),
        .package(url: "https://github.com/segment-integrations/analytics-swift-consent.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SegmentConsentOneTrust",
            dependencies: [
                .product(name: "Segment", package: "analytics-swift"),
                .product(name: "SegmentConsent", package: "analytics-swift-consent"),
                .product(name: "OTPublishersHeadlessSDK", package: "OTPublishersHeadlessSDK", condition: .when(platforms: [.iOS])),
                .product(name: "OTPublishersHeadlessSDKtvOS", package: "OTPublishersHeadlessSDKtvOS", condition: .when(platforms: [.tvOS])),
            ]),
        .testTarget(
            name: "SegmentConsentOneTrust-Tests",
            dependencies: [
                "SegmentConsentOneTrust",
                .product(name: "OTPublishersHeadlessSDK", package: "OTPublishersHeadlessSDK", condition: .when(platforms: [.iOS])),
                .product(name: "OTPublishersHeadlessSDKtvOS", package: "OTPublishersHeadlessSDKtvOS", condition: .when(platforms: [.tvOS])),
                ],
            resources: [
                .process("Resources"),
            ]),
    ]
)

