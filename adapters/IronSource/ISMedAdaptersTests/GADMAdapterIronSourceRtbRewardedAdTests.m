// GADMAdapterIronSourceRtbRewardedAdTests.m
// ISMedAdaptersTests

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "GADMAdapterIronSourceRtbRewardedAd.h"
#import "GADMAdapterIronSourceUtils.h"
#import "GADMAdapterIronSourceConstants.h"
#import <OCMock/OCMock.h>

@interface GADMAdapterIronSourceRtbRewardedAdTests : XCTestCase
typedef void (^GADMediationAdapterSetUpCompletionBlock)(NSError *_Nullable error);
@property (nonatomic, strong) GADMAdapterIronSourceRtbRewardedAd *rewardedAd;
@property (nonatomic, strong) GADMediationAdapterIronSource *mediationAdapter;
@property (nonatomic, strong) GADMediationRewardedAdConfiguration *mockAdConfiguration;
@property (nonatomic, strong) GADMediationServerConfiguration *mockInitConfiguration;


@property (nonatomic, copy) GADMediationRewardedLoadCompletionHandler completionHandler;
@property (nonatomic, copy) GADMediationAdapterSetUpCompletionBlock initCompletionHandler;
@property(nonatomic, strong) GADMAdapterIronSourceRtbRewardedAd *adapter;
@property(nonatomic, strong) id mockBiddingISARewardedAd;
@property(nonatomic, strong) id mockRewardedAdEventDelegate;
@property (nonatomic, strong) id mockCredentials;
@end

@implementation GADMAdapterIronSourceRtbRewardedAdTests

- (void)setUp {
    [super setUp];
    self.rewardedAd = [[GADMAdapterIronSourceRtbRewardedAd alloc] init];
    // Create a mock for GADMediationRewardedAdConfiguration
    self.mockAdConfiguration = OCMClassMock([GADMediationRewardedAdConfiguration class]);
    self.mockInitConfiguration = OCMClassMock([GADMediationServerConfiguration class]);
    // Create a mock for credentials and stub the settings method
    self.mockCredentials = OCMClassMock([GADMediationCredentials class]);
    NSDictionary *credentialsDict = @{GADMAdapterIronSourceAppKey : @"8bb6af0d",
                                      GADMAdapterIronSourceInstanceId : @"validInstanceID"};
    OCMStub([self.mockCredentials settings]).andReturn(credentialsDict);
    
    // Stub the credentials property on the adConfiguration mock
    OCMStub([self.mockAdConfiguration credentials]).andReturn(self.mockCredentials);
    OCMStub([self.mockInitConfiguration credentials]).andReturn([NSSet setWithObject:self.mockCredentials]);

    // Stub the bidResponse property
    OCMStub([self.mockAdConfiguration bidResponse]).andReturn(@"a_bidding_response");
    
    self.adapter = [[GADMAdapterIronSourceRtbRewardedAd alloc] init];
    self.mockBiddingISARewardedAd = OCMClassMock([ISARewardedAd class]);
    
    self.mockRewardedAdEventDelegate = OCMProtocolMock(@protocol(GADMediationRewardedAdEventDelegate));
    self.adapter.rewardedAdEventDelegate = self.mockRewardedAdEventDelegate;
}

- (void)tearDown {
    self.rewardedAd = nil;
    self.mockAdConfiguration = nil;
    self.mockCredentials = nil;
    self.completionHandler = nil;
    [super tearDown];
}

- (void)testRewardedAdDidLoad {
    // Create a mock completion handler
    GADMediationRewardedLoadCompletionHandler completionHandler = ^id<GADMediationRewardedAdEventDelegate>(id<GADMediationRewardedAd> ad, NSError *error) {
        XCTAssertNotNil(ad);
        XCTAssertNil(error);
        return nil;
    };
    
    // Set the completion handler in the adapter
    self.adapter.rewardedAdLoadCompletionHandler = completionHandler;
    
    // Call the method to test
    [self.adapter rewardedAdDidLoad:self.mockBiddingISARewardedAd];
    
    // Verify the behavior
    XCTAssertEqual(self.adapter.biddingISARewardedAd, self.mockBiddingISARewardedAd, @"The rewarded ad should be set correctly.");
}

- (void)testRewardedAdDidLoadWithoutRewardedAdLoadCompletionHandler {
    // Create a mock completion handler
    GADMediationRewardedLoadCompletionHandler completionHandler = ^id<GADMediationRewardedAdEventDelegate>(id<GADMediationRewardedAd> ad, NSError *error) {
        XCTFail(@"Completion handler should not be called.");
          return nil;
    };
    
     // Call the method to test
    [self.adapter rewardedAdDidLoad:self.mockBiddingISARewardedAd];
}


- (void)testRewardedAdDidShow {
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Set expectations
    OCMExpect([self.mockRewardedAdEventDelegate willPresentFullScreenView]);
    OCMExpect([self.mockRewardedAdEventDelegate didStartVideo]);
    OCMExpect([self.mockRewardedAdEventDelegate reportImpression]);

    // Call the method to test
    [self.adapter rewardedAdDidShow:mockRewardedAd];

    // Verify all expected methods were called
    OCMVerifyAll(self.mockRewardedAdEventDelegate);
}

- (void)testRewardedAdDidShowWithNilDelegate {
    self.adapter.rewardedAdEventDelegate = nil;
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // No expectations to set because delegate is nil

    // Call the method to test
    [self.adapter rewardedAdDidShow:mockRewardedAd];

    // Normally, OCMock would have caught unexpected calls, so reaching here means success
    XCTAssertTrue(true);
}

// Test case for rewardedAdDidFailToLoadWithError when completion handler is set
- (void)testRewardedAdDidFailToLoadWithError {
    NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];

    // Create a mock completion handler
    GADMediationRewardedLoadCompletionHandler mockCompletionHandler = ^id<GADMediationRewardedAdEventDelegate>(id<GADMediationRewardedAd> ad, NSError *error) {
        XCTAssertNil(ad);
        XCTAssertEqualObjects(error, testError);
        return nil;
    };

    // Assign the mock completion handler to the adapter
    self.adapter.rewardedAdLoadCompletionHandler = mockCompletionHandler;

    // Call the method to test
    [self.adapter rewardedAdDidFailToLoadWithError:testError];
}

// Test case for rewardedAdDidFailToLoadWithError when completion handler is nil
- (void)testRewardedAdDidFailToLoadWithErrorWithNilCompletionHandler {
    // Assign nil to the completion handler
    self.adapter.rewardedAdLoadCompletionHandler = nil;

    NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];

    // Call the method to test
    [self.adapter rewardedAdDidFailToLoadWithError:testError];

    // Since the completion handler is nil, no further action is necessary
    XCTAssertTrue(true); // Reaching this point without crashing means success
}

// Test case for rewardedAd:didFailToShowWithError: when event delegate is set
- (void)testRewardedAdDidFailToShowWithError {
    NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Set expectation for the delegate method
    OCMExpect([self.mockRewardedAdEventDelegate didFailToPresentWithError:testError]);

    // Call the method to test
    [self.adapter rewardedAd:mockRewardedAd didFailToShowWithError:testError];

    // Verify all expectations
    OCMVerifyAll(self.mockRewardedAdEventDelegate);
}

// Test case for rewardedAd:didFailToShowWithError: when event delegate is nil
- (void)testRewardedAdDidFailToShowWithErrorWithNilDelegate {
    // Set the delegate to nil
    self.adapter.rewardedAdEventDelegate = nil;
    NSError *testError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Call the method to test
    [self.adapter rewardedAd:mockRewardedAd didFailToShowWithError:testError];

    // Since the delegate is nil, no further action is necessary
    XCTAssertTrue(true); // Reaching this point without crashing means success
}

- (void)testRewardedAdDidClick {
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Set expectation for the delegate method
    OCMExpect([self.mockRewardedAdEventDelegate reportClick]);

    // Call the method to test
    [self.adapter rewardedAdDidClick:mockRewardedAd];

    // Verify all expectations
    OCMVerifyAll(self.mockRewardedAdEventDelegate);
}

// Test case for rewardedAdDidClick: when event delegate is nil
- (void)testRewardedAdDidClickWithNilDelegate {
    // Set the delegate to nil
    self.adapter.rewardedAdEventDelegate = nil;
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Call the method to test
    [self.adapter rewardedAdDidClick:mockRewardedAd];

    // Since the delegate is nil, no further action is necessary
    XCTAssertTrue(true); // Reaching this point without crashing means success
}

- (void)testRewardedAdDidDismiss {
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Set expectations for the delegate methods
    OCMExpect([self.mockRewardedAdEventDelegate willDismissFullScreenView]);
    OCMExpect([self.mockRewardedAdEventDelegate didDismissFullScreenView]);

    // Call the method to test
    [self.adapter rewardedAdDidDismiss:mockRewardedAd];

    // Verify all expectations
    OCMVerifyAll(self.mockRewardedAdEventDelegate);
}

// Test case for rewardedAdDidDismiss: when event delegate is nil
- (void)testRewardedAdDidDismissWithNilDelegate {
    // Set the delegate to nil
    self.adapter.rewardedAdEventDelegate = nil;
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Call the method to test
    [self.adapter rewardedAdDidDismiss:mockRewardedAd];

    // Since the delegate is nil, no further action is necessary
    XCTAssertTrue(true); // Reaching this point without crashing means success
}

// Test case for rewardedAdDidUserEarnReward: when event delegate is set
- (void)testRewardedAdDidUserEarnReward {
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Set expectations for the delegate methods
    OCMExpect([self.mockRewardedAdEventDelegate didRewardUser]);
    OCMExpect([self.mockRewardedAdEventDelegate didEndVideo]);

    // Call the method to test
    [self.adapter rewardedAdDidUserEarnReward:mockRewardedAd];

    // Verify all expectations
    OCMVerifyAll(self.mockRewardedAdEventDelegate);
}

// Test case for rewardedAdDidUserEarnReward: when event delegate is nil
- (void)testRewardedAdDidUserEarnRewardWithNilDelegate {
    // Set the delegate to nil
    self.adapter.rewardedAdEventDelegate = nil;
    ISARewardedAd *mockRewardedAd = OCMClassMock([ISARewardedAd class]);

    // Call the method to test
    [self.adapter rewardedAdDidUserEarnReward:mockRewardedAd];

    // Since the delegate is nil, no further action is necessary
    XCTAssertTrue(true); // Reaching this point without crashing means success
}

@end
