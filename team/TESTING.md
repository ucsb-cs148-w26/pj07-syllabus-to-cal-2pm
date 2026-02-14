# Testing Documentation - Plannr

## Testing Library Selection

### Frameworks Explored

**1. Jest**
- **Background**: I have prior experience with Jest from previous JavaScript/React projects and work
- **Consideration**: Familiar syntax and workflow
- **Decision**: Not suitable for Swift/iOS development - Jest is JavaScript-specific

**2. XCTest**  *Selected*
- **Why XCTest?**
  - Native to iOS/Swift development - no setup required
  - Integrated directly into Xcode
  - Industry standard for iOS apps
  - Zero external dependencies
  - Recommended by Claude for Apple's framework

**Final Choice**: Based on Claude's recommendation and research, I chose **XCTest** because it's specifically made for Apple's frameworks and doesn't require any additional configuration or external dependencies.

## Approaches Tested

I did unit testing using the AAA testing pattern for our event management logic in the CalendarPreviewView component.

## Unit Tests Implemented

### Test File: `CalendarPreviewViewTests.swift`

We implemented the following unit tests for the `CalendarPreviewView` component:

#### 1. **testFilterAcceptedEvents()**
- **What it tests**: Filters events by "accepted" status
- **Why it matters**: The sync functionality only syncs accepted events to Google Calendar. This test ensures we're filtering correctly.
- **Test data**: Mix of pending, accepted, and declined events
- **Expected result**: Only 2 accepted events returned

#### 2. **testFilterAcceptedEventsWhenNoneAccepted()**
- **What it tests**: Edge case when no events are accepted
- **Why it matters**: Prevents sync errors when user hasn't accepted anything
- **Expected result**: Empty array returned

#### 3. **testToggleAcceptedEventToPending()**
- **What it tests**: Toggling an accepted event back to pending
- **Why it matters**: Tests the accept/decline button toggle functionality
- **Expected result**: Event status changes from accepted to pending

#### 4. **testAcceptAllEvents()**
- **What it tests**: "Accept All" button functionality
- **Why it matters**: Ensures bulk operations work correctly
- **Expected result**: All events have accepted status

#### 5. **testDeclineAllEvents()**
- **What it tests**: "Decline All" button functionality
- **Expected result**: All events have declined status

## Running the Tests

### In Xcode:
1. Open your project in Xcode
2. Press `Cmd + U` to run all tests
3. Or click the diamond icon next to individual test methods

### Viewing Results:
- Open Test Navigator: `Cmd + 6`
- Green checkmarks = passing tests
- Red X = failing tests