//
//  ContentView.swift
//  BasicExample
//
//  Created by Brandon Sneed on 2/23/22.
//

import SwiftUI
import Segment
#if os(tvOS)
import OTPublishersHeadlessSDKtvOS
#else
import OTPublishersHeadlessSDK
#endif

struct ContentView: View {
    var body: some View {
        VStack {
            Button {
                OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
            } label: {
                Text("Show Consent UI")
            }
            Button {
                Analytics.main.reset()
            } label: {
                Text("Reset")
            }

            HStack {
                Button(action: {
                    Analytics.main.track(name: "Track Tapped")
                }, label: {
                    Text("Track")
                }).padding(6)
                Button(action: {
                    Analytics.main.screen(title: "Screen appeared")
                }, label: {
                    Text("Screen")
                }).padding(6)
            }.padding(8)
            HStack {
                Button(action: {
                    Analytics.main.group(groupId: "12345-Group")
                    Analytics.main.log(message: "Started group")
                }, label: {
                    Text("Group")
                }).padding(6)
                Button(action: {
                    Analytics.main.identify(userId: "X-1234567890")
                }, label: {
                    Text("Identify")
                }).padding(6)
            }.padding(8)
        }.onAppear {
            Analytics.main.track(name: "onAppear")
            print("Executed Analytics onAppear()")
        }.onDisappear {
            Analytics.main.track(name: "onDisappear")
            print("Executed Analytics onDisappear()")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
