# Privacy Policy for DevUtilities

**Last Updated:** October 2025

## Overview

DevUtilities ("the App") is a native macOS developer utility application created by Hengfei Yang. This privacy policy explains how the App handles your information.

## Information Collection and Use

### Anonymous Usage Analytics

**DevUtilities collects anonymous usage analytics to improve the app and understand which features are most valuable to users.**

#### What We Collect

We collect **anonymous usage events only**:
- **App Start Events**: When you launch the app
- **Feature Usage**: Which tools you use (e.g., JSON Formatter, Base64, JWT)
- **Navigation Patterns**: How you navigate between different tools
- **Session Information**: App version, anonymous session ID

#### What We DO NOT Collect

We do **not** collect any personal or sensitive information:
- ❌ No personal information (name, email, phone number)
- ❌ No device identifiers (UDID, serial numbers, MAC address)
- ❌ No IP addresses or location data
- ❌ No file contents or data you process in the tools
- ❌ No API keys or credentials
- ❌ No chat messages or translation content
- ❌ No advertising tracking or third-party analytics services

#### Anonymous Identifiers

- **User ID**: A randomly generated UUID stored locally on your device. This is NOT linked to your Apple ID, email, or any personal information. It helps us understand unique users and retention.
- **Session ID**: A temporary UUID generated each time you launch the app. This helps us understand session duration and feature usage patterns within a single session.

Both identifiers are completely anonymous and cannot be used to identify you personally.

### Local Data Storage

The App stores the following information **locally on your device only**:

1. **User Preferences:** Your customization settings (enabled/disabled tools, tool order)
2. **API Configuration:** AI feature API keys and endpoints (stored in macOS UserDefaults)
3. **Chat History:** AI Chat conversation history (stored locally in app container)
4. **Recent History:** Recent conversions, requests, or inputs for convenience

**All this data:**
- Remains on your device
- Is never transmitted to our servers
- Can be deleted by removing the app
- Is protected by macOS sandboxing

## Network Usage

DevUtilities requires network access for specific features only:

### 1. AI Features (AI Chat, AI Translate)
- **Purpose:** Connect to user-configured AI API endpoints
- **User Control:** Users must provide their own API keys
- **Data Sent:** Chat messages and translation text to user's chosen API provider
- **We Do Not:** Store, log, or have access to API keys or conversation content
- **Third Party:** Your data is subject to your chosen AI provider's privacy policy

### 2. IP Query Tool
- **Purpose:** Lookup IP address geolocation information
- **Services Used:** ipinfo.io and ip.sb public APIs
- **Data Sent:** IP addresses you choose to query
- **We Do Not:** Log or store queried IP addresses

### 3. HTTP Request Tool
- **Purpose:** Developer testing tool for making HTTP requests
- **Data Sent:** Only to endpoints you explicitly specify
- **We Do Not:** Log, monitor, or intercept your requests

### 4. Usage Analytics
- **Purpose:** Understand feature usage and improve the app
- **Service Used:** Our analytics server (api.devutilities.feiliwu.com)
- **Data Sent:** Anonymous events (see "Anonymous Usage Analytics" section above)
- **Data Format:** GET requests with query parameters (version, module, submodule, anonymous user_id, session_id)
- **Opt-Out:** You can disable analytics in app preferences (coming soon)

### 5. Update Checking
- **Purpose:** Check for new app versions on GitHub
- **Service Used:** GitHub Releases API
- **Data Sent:** Standard HTTP request (no personal information)

## Offline Functionality

The following tools work completely offline without any network access:
- Timestamp Converter
- Unit Converter
- JSON Formatter
- Base64 Encode/Decode
- Hex String Converter
- Regex Test
- UUID Generator
- URL Tools
- QR Code Generator/Scanner
- SQL Formatter
- HTML Formatter
- JWT Encoder/Decoder
- Parquet Viewer
- Crypto Tools

## Cryptographic Features

The App provides cryptographic tools (hash functions, encryption/decryption) for developer use:
- All cryptographic operations are performed locally on your device
- The App uses standard Apple frameworks (CryptoKit, Security)
- No encryption keys are transmitted or stored by us
- Users are responsible for securing their own keys

## Third-Party Services

### Analytics Server
DevUtilities sends anonymous usage events to our own analytics server to understand feature usage. No third-party analytics services (Google Analytics, Mixpanel, etc.) are used. We control the data and do not share it with any third parties.

### No Advertising or Tracking
- No advertising networks
- No cross-site tracking
- No data brokers
- No data sales to third parties

### AI Features
When you use AI Chat or AI Translate with your own API keys, you are directly connecting to third-party AI services (OpenAI, DeepSeek, or custom providers). Your usage is subject to those providers' privacy policies and terms of service.

## Children's Privacy

DevUtilities is not directed to children under 13. We do not knowingly collect information from children. If you believe a child has used the App, please contact us.

## Data Security

- All user data is stored locally using macOS sandboxing
- API keys are stored in UserDefaults on your device only
- Anonymous analytics transmitted over HTTPS with TLS encryption
- Events queued locally if network unavailable, sent later
- Standard macOS security protections apply
- We do not store, log, or have access to your processed data (JSON, text, files, etc.)

## Your Rights

You have complete control over your data:
- **Access:** All personal data is stored locally and accessible via standard macOS file locations
- **Deletion:** Remove the App to delete all local data and stop sending analytics events
- **Portability:** Export any data using standard macOS tools
- **Opt-Out:** Analytics can be disabled in app preferences (feature in development)
- **Anonymous Data:** Since analytics are anonymous and not linked to you personally, we cannot retrieve or delete specific analytics data upon request

## Changes to This Privacy Policy

We may update this privacy policy from time to time. Updates will be posted on this page with a new "Last Updated" date. Continued use of the App after changes constitutes acceptance of the updated policy.

## Contact Information

If you have questions or concerns about this privacy policy:

**Issues:** https://github.com/hengfeiyang/devutilities/issues
**GitHub:** https://github.com/hengfeiyang/devutilities
**Website:** https://hengfeiyang.github.io/devutilities

## Analytics Data Details

### Example Analytics Event
```
GET https://api.devutilities.feiliwu.com/event?
    user_id=550e8400-e29b-41d4-a716-446655440000&
    session_id=6ba7b810-9dad-11d1-80b4-00c04fd430c8&
    version=2.5.0&
    module=json_formatter&
    submodule=format
```

**What this tells us:**
- An anonymous user (identified by random UUID) used the JSON Formatter feature
- They're running version 2.5.0 of the app
- This was during a specific app session

**What this does NOT tell us:**
- Who you are or any identifying information
- What data you formatted (your actual JSON content)
- Your location or IP address
- Any other apps you use or personal information

### Data Retention
- **Local Queue:** Anonymous events stored locally for up to 7 days before automatic cleanup
- **Server Storage:** Anonymous usage statistics retained for analytics and product improvement
- **No Personal Data:** Since no personal information is collected, there's nothing personally identifiable to delete

## Compliance

This privacy policy complies with:
- Apple App Store Review Guidelines
- General Data Protection Regulation (GDPR) principles
- California Consumer Privacy Act (CCPA) principles
- macOS App Sandbox requirements

**GDPR Note:** While we collect analytics data, it is completely anonymous and cannot be linked to any individual. The random UUID user_id is not personal data under GDPR as it cannot be used to identify a natural person.

## Developer Information

**Developer:** Hengfei Yang
**App Name:** DevUtilities
**Version:** 2.5.0
**Bundle ID:** com.hengfeiyang.DevUtilities

---

**Summary:** DevUtilities respects your privacy. We collect only anonymous usage analytics to improve the app - no personal information, no tracking, no data sales. Your actual work data (JSON, files, API keys, etc.) stays on your device. Network features require explicit user action and configuration.
