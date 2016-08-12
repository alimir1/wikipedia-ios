

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MWKSavedPageList.h"
#import "MWKHistoryEntry+MWKRandom.h"
#import "MWKDataStore+TemporaryDataStore.h"

#define MOCKITO_SHORTHAND 1
#import <OCMockito/OCMockito.h>

#define HC_SHORTHAND 1
#import <OCHamcrest/OCHamcrest.h>

@interface MWKSavedPageList (WMFSavedPageListTests)

- (MWKHistoryEntry*)addEntry:(MWKHistoryEntry*)entry;

@end

@interface MWKSavedPageListTogglingTests : XCTestCase
@property (nonatomic, strong) MWKSavedPageList* list;
@property (nonatomic, strong) MWKDataStore* dataStore;

@end

@implementation MWKSavedPageListTogglingTests

- (void)setUp {
    self.dataStore = [MWKDataStore temporaryDataStore];
    self.list      = [[MWKSavedPageList alloc] initWithDataStore:self.dataStore];
}

#pragma mark - Manual Saving

- (void)testAddedTitlesArePrepended {
    MWKHistoryEntry* e1 = [MWKHistoryEntry random];
    MWKHistoryEntry* e2 = [MWKHistoryEntry random];
    [self.list addEntry:e1];
    [self.list addEntry:e2];

    XCTAssertTrue([self.list numberOfItems] == 2);
    assertThat(self.list.mostRecentEntry, is(e2));
}

- (void)testAddingExistingSavedPageIsIgnored {
    MWKHistoryEntry* entry = [MWKHistoryEntry random];
    [self.list addEntry:entry];
    [self.list addEntry:[[MWKHistoryEntry alloc] initWithURL:entry.url]];
    XCTAssertTrue([self.list numberOfItems] == 1);
    assertThat(self.list.mostRecentEntry, is(entry));
}

#pragma mark - Toggling

- (void)testTogglingSavedPageReturnsNoAndRemovesFromList {
    MWKHistoryEntry* savedEntry = [MWKHistoryEntry random];
    [self.list addEntry:savedEntry];
    [self.list toggleSavedPageForURL:savedEntry.url];
    XCTAssertFalse([self.list isSaved:savedEntry.url]);
    XCTAssertNil([self.list entryForURL:savedEntry.url]);
}

- (void)testToggleUnsavedPageReturnsYesAndAddsToList {
    MWKHistoryEntry* unsavedEntry = [MWKHistoryEntry random];
    [self.list toggleSavedPageForURL:unsavedEntry.url];
    XCTAssertTrue([self.list isSaved:unsavedEntry.url]);
    XCTAssertEqualObjects([self.list entryForURL:unsavedEntry.url], unsavedEntry);
}

- (void)testTogglePageWithEmptyTitleReturnsNilWithError {
    NSURL* url = [[NSURL wmf_URLWithDefaultSiteAndlanguage:@"en"] wmf_URLWithTitle:@""];
    [self.list toggleSavedPageForURL:url];
    XCTAssertFalse([self.list isSaved:url]);
}

@end
