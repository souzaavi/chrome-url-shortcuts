// Listen for messages from the Flutter app
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'REDIRECT') {
    chrome.tabs.update({ url: request.url });
  }
  return true;
});

// Set up the omnibox keyword
chrome.omnibox.setDefaultSuggestion({
  description: 'Type a shortcut key followed by your search query'
});

// Handle omnibox input
chrome.omnibox.onInputEntered.addListener(async (text) => {
  try {
    // Split input into shortcut key and query
    const [shortcutKey, ...queryParts] = text.trim().split(' ');
    const query = queryParts.join(' ');

    // Get shortcuts from storage
    const result = await chrome.storage.sync.get(['shortcuts']);
    const shortcuts = result.shortcuts ? JSON.parse(result.shortcuts) : [];
    
    // Find matching shortcut
    const shortcut = shortcuts.find(s => s.key === shortcutKey);
    
    if (shortcut) {
      // Replace {query} with the actual query
      const url = shortcut.url.replace('{query}', encodeURIComponent(query));
      // Navigate to the URL
      chrome.tabs.update({ url });
    } else {
      // If no shortcut found, default to Google search
      chrome.tabs.update({
        url: `https://www.google.com/search?q=${encodeURIComponent(text)}`
      });
    }
  } catch (error) {
    console.error('Error handling omnibox input:', error);
    // Default to Google search on error
    chrome.tabs.update({
      url: `https://www.google.com/search?q=${encodeURIComponent(text)}`
    });
  }
});

// Handle omnibox input changes for suggestions
chrome.omnibox.onInputChanged.addListener(async (text, suggest) => {
  try {
    const result = await chrome.storage.sync.get(['shortcuts']);
    const shortcuts = result.shortcuts ? JSON.parse(result.shortcuts) : [];
    
    const [shortcutKey] = text.trim().split(' ');
    
    // Filter shortcuts that match the input
    const suggestions = shortcuts
      .filter(s => s.key.toLowerCase().includes(shortcutKey.toLowerCase()))
      .map(s => ({
        content: `${s.key} `,
        description: `${s.key} - ${s.description}`
      }));
    
    suggest(suggestions);
  } catch (error) {
    console.error('Error getting suggestions:', error);
  }
});
