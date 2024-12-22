# GlobalKeyCategoryManager

The `GlobalKeyCategoryManager` class is a utility for managing `GlobalKey` instances in Flutter applications. It allows
you to categorize keys, retrieve them by category, and access their debug labels for easier debugging and organization.

## Class Overview

### GlobalKeyCategoryManager

- **Static Map to Store Keys by Category**: `_keyCategories` stores lists of `GlobalKey` instances, categorized by a
  string key.
- **Static Map to Store Debug Labels**: `_keyDebugLabels` maps each `GlobalKey` to a debug label string.

### Methods

- **addKey(String category)**: Adds a new `GlobalKey` to the specified category and assigns it a debug label.
- **getKeys(String category)**: Retrieves all `GlobalKey` instances for the specified category.
- **getDebugLabels(String category)**: Retrieves all debug labels for the `GlobalKey` instances in the specified
  category.
- **getDebugLabel(GlobalKey key)**: Retrieves the debug label for a specific `GlobalKey`.

## Key Categories and Actions

1. **Blocked Users Screen**
    - **Menu Icon to Unblock User**: `Category: unblockUserMenuIcon`
    - **Menu Key to Confirm Unblock**: `Category: unblockUserMenuConfirm`
    - **Action**: Unblocks the user immediately and navigates to the block screen.

2. **Block Users**
    - **Button to Go to Block User Screen**: `Category: goToBlockUserScreenButton`

3. **Block Users Screen**
    - **Tile to Block or Cancel Action**: `Category: blockUserTile`
    - **Cancel Action Key**: `Category: blockUserCancel`
    - **Block Action Key**: `Category: blockUserConfirm`

4. **Audio and Media Controls**
    - **Audio Waveform**: `Category: audioWaveform`
    - **Audio Message Toggle**: `Category: audioMessageToggle`
    - **Emoji Picker Toggle**: `Category: emojiPickerToggle`
    - **Delete Recording**: `Category: deleteRecording`
    - **Cancel Recording**: `Category: cancelRecording`
    - **Send Media with Caption**: `Category: sendMediaWithCaption`
    - **Deactivate Button**: `Category: deactivateButton`
    - **Ban Button**: `Category: banButton`
    - **Cancel Action Button**: `Category: cancel${action}Button`
    - **Confirm Action Button**: `Category: confirm${action}Button`
    - **Open Document Message Button**: `Category: openDocumentMessageButton`
    - **Download Media Button**: `Category: downloadMediaButton`
    - **Emoji Picker**: `Category: emojiPicker`
    - **GIF Picker**: `Category: gifPicker`
    - **Sticker Picker**: `Category: stickerPicker`
    - **Emoji Picker Tab Bar**: `Category: emojiPickerTabBar`
    - **Toggle Audio Recording**: `Category: toggleAudioRecording`
    - **Send Audio Message While Recording**: `Category: sendAudioMessageWhileRecording`
    - **Toggle Video Message Button**: `Category: toggleVideoMessageButton`

```