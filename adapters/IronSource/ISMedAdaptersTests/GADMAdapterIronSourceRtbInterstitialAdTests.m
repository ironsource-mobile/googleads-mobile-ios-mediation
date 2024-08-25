#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "GADMAdapterIronSourceRtbInterstitialAd.h"
#import "GADMAdapterIronSourceUtils.h"
#import "GADMAdapterIronSourceConstants.h"
#import <IronSource/IronSource.h>

@interface GADMAdapterIronSourceRtbInterstitialAdTests : XCTestCase

@property(nonatomic, strong) GADMAdapterIronSourceRtbInterstitialAd *interstitialAd;
@property(nonatomic, strong) id mockEventDelegate;
@property(nonatomic, strong) id mockISAInterstitialAd;
@property(nonatomic, strong) id mockAdConfiguration;
@property(nonatomic, strong) id mockAdRequest;
@property(nonatomic, strong) GADMAdapterIronSourceRtbInterstitialAd *adapter;
@property(nonatomic, strong) id mockInterstitialAdEventDelegate;
@property(nonatomic, strong) id mockInterstitialAd;
@property (nonatomic, copy) GADMediationInterstitialLoadCompletionHandler interstitalAdLoadCompletionHandler;
@end

@implementation GADMAdapterIronSourceRtbInterstitialAdTests

- (void)setUp {
    [super setUp];
    self.adapter = [[GADMAdapterIronSourceRtbInterstitialAd alloc] init];
    // Create a mock for the GADMediationInterstitialAdEventDelegate protocol
    self.mockInterstitialAdEventDelegate = OCMProtocolMock(@protocol(GADMediationInterstitialAdEventDelegate));
    self.adapter.interstitialAdEventDelegate = self.mockInterstitialAdEventDelegate;
    self.mockInterstitialAd = OCMClassMock([ISAInterstitialAd class]);
}

- (void)testInterstitialAdDidLoad {
    // Create a mock completion handler
    GADMediationInterstitialLoadCompletionHandler completionHandler = ^id<GADMediationInterstitialAdEventDelegate>(id<GADMediationInterstitialAd> ad, NSError *error) {
        XCTAssertNotNil(ad);
        XCTAssertNil(error);
        return nil;
    };
    
    // Set the completion handler in the adapter
    self.adapter.interstitalAdLoadCompletionHandler = completionHandler;
    
    // Call the method to test
    [self.adapter interstitialAdDidLoad:self.mockInterstitialAd];
    
    // Verify the behavior
    XCTAssertEqual(self.adapter.biddingISAInterstitialAd, self.mockInterstitialAd, @"The Interstitial ad should be set correctly.");
}

// Test case for interstitialAd:didFailToShowWithError: when event delegate is set
- (void)testInterstitialAdDidFailToShowWithError {
    NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];

    // Set expectations for the delegate method
    OCMExpect([self.mockInterstitialAdEventDelegate didFailToPresentWithError:testError]);

    // Call the method to test
    [self.adapter interstitialAd:self.mockInterstitialAd didFailToShowWithError:testError];

    // Verify all expectations
    OCMVerifyAll(self.mockInterstitialAdEventDelegate);
}

// Test case for interstitialAd:didFailToShowWithError: when event delegate is nil
- (void)testInterstitialAdDidFailToShowWithErrorWithNilDelegate {
    // Set the delegate to nil
    self.adapter.interstitialAdEventDelegate = nil;
    NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];

    // Call the method to test
    [self.adapter interstitialAd:self.mockInterstitialAd didFailToShowWithError:testError];

    // Since the delegate is nil, no further action is necessary
    XCTAssertTrue(true); // Reaching this point without crashing means success
}

    // Test case for rewardedAdDidFailToLoadWithError when completion handler is set
    - (void)testInterstitialAdDidFailToLoadWithError {
        NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];

        // Create a mock completion handler
        GADMediationInterstitialLoadCompletionHandler mockCompletionHandler = ^id<GADMediationInterstitialAdEventDelegate>(id<GADMediationInterstitialAd> ad, NSError *error) {
            XCTAssertNil(ad);
            XCTAssertEqualObjects(error, testError);
            return nil;
        };

        // Assign the mock completion handler to the adapter
        self.adapter.interstitalAdLoadCompletionHandler = mockCompletionHandler;

        // Call the method to test
        [self.adapter interstitialAdDidFailToLoadWithError:testError];
    }



@end
