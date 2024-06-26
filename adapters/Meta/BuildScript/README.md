# Steps to generate universal static library and framework

**Note:** These build scripts are intended only for publishers who want to
modify and rebuild the Meta Audience Network adapter framework. If you just want to use the
Meta Audience Network adapter, simply add `pod 'GoogleMobileAdsMediationFacebook'` to
your Podfile and run `pod install --repo-update`.

## Prerequisites
- Xcode 6.0 or higher
- Deployment target of 6.0 or higher
- Google Mobile Ads SDK
- Meta Audience Network Audience Network SDK
- Meta Audience Network Adapter Source Code

## Setup Instructions
- Drop GoogleMobileAds framework to
  Project Directory->Drop_Framework_And_Headers.
- Drop FacebookAudienceNetwork framework to
  Project Directory->Drop_Framework_And_Headers.

## Build Instructions
- To build a static library, select target scheme (FatAdapter). Edit scheme to
  Release OR Build.
- Clean and Run/Archive.
- To build a framework, select target scheme (Framework). Edit scheme to
  Release OR Build.
- Clean and Run/Archive.

**Note:** New adapter file and/or framework will be generated in your
Project Directory->Library folder.
