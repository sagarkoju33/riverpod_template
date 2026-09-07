# flutter_template

A starter template for your next flutter projects

## Getting Started

```bash

git clone https://github.com/dartbucket/flutter_riverpod_template

cd flutter_riverpod_template

flutter pub get

dart run build_runner build --delete-conflicting-outputs

```

## Generate Asset Paths

```bash
dart run build_runner build
```

## Update Launcher Icons

update the flutter_launcher_icons.yaml

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
```

## Update Package Name

Update the package_rename_config.yaml

```bash
dart run package_rename --path="package_rename_config.yaml"
```

## Project Structure

```bash

└───src
    ├───common
    │   ├───provider
    │   └───widget
    ├───core
    ├───feature
    │   └───recipe
    │       ├───controller
    │       ├───repository
    │       ├───state
    │       ├───view
    │       └───widget
    ├───model
    │   ├───recipe
    │   └───user
    ├───network
    ├───resources
    └───utils

# Implementing WebRTC in Flutter — Complete Guide

A ground-up guide to building real-time audio/video calling in Flutter using
the `flutter_webrtc` plugin. Covers core concepts, project setup, signaling,
full implementation, testing, and production considerations.

---

## 1. What WebRTC Actually Is

WebRTC (Web Real-Time Communication) is a set of protocols and APIs that let
two devices stream audio, video, or arbitrary data **directly to each
other** (peer-to-peer) once a connection is established. It does **not**
include a way for the two peers to find each other in the first place —
that's left entirely up to you. This is the single most important thing to
understand before writing any code:

> **WebRTC has two halves: media transport (which it provides) and
> signaling (which you must build yourself).**

### The three problems WebRTC solves for media transport
1. **Capture** — grabbing camera/mic/screen input.
2. **Negotiation** — agreeing with the other peer on codecs, resolutions,
   and network paths (via SDP, the Session Description Protocol).
3. **Transport** — actually moving encrypted media/data packets between
   peers, working around NATs and firewalls (via ICE, STUN, and TURN).

### What you must build yourself
- **Signaling**: a channel (WebSocket, Socket.IO, Firebase, XMPP — anything)
  to pass SDP offers/answers and ICE candidates between peers before the
  direct connection exists.
- **Room/presence management**: who's online, who's in which call.
- **TURN relay** (for production): a fallback server that relays media when
  a direct peer-to-peer path can't be established (common on cellular
  networks and behind symmetric NATs).

---

## 2. Core Concepts Glossary

| Term | Meaning |
|---|---|
| `RTCPeerConnection` | The core object representing a connection to one remote peer. Manages negotiation, ICE, and media/data flow. |
| `MediaStream` | A collection of audio/video tracks, e.g. from `getUserMedia()`. |
| **SDP (Session Description Protocol)** | A text format describing a peer's supported media, codecs, and network info. Exchanged as "offer" and "answer." |
| **ICE (Interactive Connectivity Establishment)** | The process of discovering usable network paths between peers. |
| **ICE Candidate** | One possible network address (IP:port) a peer could be reached at. |
| **STUN server** | Tells a peer its own public IP/port as seen from outside its NAT. Free, lightweight, doesn't relay media. |
| **TURN server** | A relay server that forwards media when a direct path isn't possible. Required for reliable production use; needs bandwidth and hosting cost. |
| **Signaling server** | Your own server that relays SDP/ICE messages between peers before the P2P connection exists. |
| **SFU (Selective Forwarding Unit)** | A media server used for group calls (3+ participants) so each client only uploads once. |

---

## 3. Prerequisites

- Flutter SDK 3.x+ installed and working (`flutter doctor` clean).
- A physical device or emulator/simulator with camera+mic access (iOS
  Simulator has no camera — use a real device for full testing).
- Basic familiarity with async Dart and Streams.
- A signaling backend. This guide uses a minimal Node.js + Socket.IO server,
  but Firebase Realtime Database, Supabase Realtime, or plain WebSockets
  work equally well.

---

## 4. Project Setup

### 4.1 Create the project
```bash
flutter create webrtc_app
cd webrtc_app
```

### 4.2 Add dependencies
`pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_webrtc: ^0.11.7
  socket_io_client: ^2.0.3+1   # or your signaling transport of choice
```
Run:
```bash
flutter pub get
```

### 4.3 Platform configuration

**Android** — `android/app/src/main/AndroidManifest.xml`, add above
`<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```
In `android/app/build.gradle`, ensure `minSdkVersion 24` or higher (required
by `flutter_webrtc`).

**iOS** — `ios/Runner/Info.plist`, add:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for audio calls</string>
```
In `ios/Podfile`, inside the `post_install` block, ensure permissions
aren't stripped:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'PERMISSION_CAMERA=1', 'PERMISSION_MICROPHONE=1']
    end
  end
end
```

**Web** — no extra config needed, but WebRTC over `flutter run -d chrome`
requires HTTPS or `localhost` (browsers block camera/mic on insecure
origins).

**Desktop (macOS/Windows/Linux)** — supported by `flutter_webrtc`, but
verify current native build requirements in the package's README, since
desktop support matures faster than this guide is updated.

---

## 5. Architecture Overview

```
 ┌───────────┐        signaling (SDP + ICE)        ┌───────────┐
 │  Peer A   │ ───────────────────────────────────►│  Peer B   │
 │ (Flutter) │◄─────────────────────────────────── │ (Flutter) │
 └─────┬─────┘         via your server               └─────┬─────┘
       │                                                    │
       │                 direct P2P media/data              │
       └───────────────────────────────────────────────────┘
                 (audio/video/data — after negotiation)
```

Flow:
1. Both peers connect to your signaling server and join a shared "room."
2. Each peer captures local media and creates an `RTCPeerConnection`.
3. Caller creates an **offer**, sends it via signaling.
4. Callee sets it as remote description, creates an **answer**, sends it back.
5. Both sides exchange **ICE candidates** as they're discovered.
6. Once ICE completes, media flows peer-to-peer (or via TURN if needed).

---

## 6. Step-by-Step Implementation

### 6.1 Capture local media
```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<MediaStream> getLocalMedia() async {
  final constraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'width': {'ideal': 640},
      'height': {'ideal': 480},
    },
  };
  return await navigator.mediaDevices.getUserMedia(constraints);
}
```

### 6.2 Render it
Attach an `RTCVideoRenderer` (must be initialized and disposed):
```dart
final renderer = RTCVideoRenderer();
await renderer.initialize();
renderer.srcObject = localStream;
// In the widget tree:
RTCVideoView(renderer, mirror: true);
```

### 6.3 Create the peer connection
```dart
final config = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    // Add a TURN server for production reliability:
    // {'urls': 'turn:your.turn.server:3478', 'username': 'u', 'credential': 'p'},
  ]
};

final peerConnection = await createPeerConnection(config);

for (final track in localStream.getTracks()) {
  await peerConnection.addTrack(track, localStream);
}

peerConnection.onTrack = (RTCTrackEvent event) {
  if (event.streams.isNotEmpty) {
    remoteRenderer.srcObject = event.streams[0];
  }
};

peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
  signalingChannel.send('ice-candidate', candidate.toMap());
};
```

### 6.4 Create and send an offer (caller side)
```dart
final offer = await peerConnection.createOffer();
await peerConnection.setLocalDescription(offer);
signalingChannel.send('offer', {'sdp': offer.sdp, 'type': offer.type});
```

### 6.5 Receive an offer and answer (callee side)
```dart
signalingChannel.on('offer', (data) async {
  await peerConnection.setRemoteDescription(
    RTCSessionDescription(data['sdp'], data['type']),
  );
  final answer = await peerConnection.createAnswer();
  await peerConnection.setLocalDescription(answer);
  signalingChannel.send('answer', {'sdp': answer.sdp, 'type': answer.type});
});
```

### 6.6 Complete the handshake (caller side)
```dart
signalingChannel.on('answer', (data) async {
  await peerConnection.setRemoteDescription(
    RTCSessionDescription(data['sdp'], data['type']),
  );
});
```

### 6.7 Exchange ICE candidates (both sides)
```dart
signalingChannel.on('ice-candidate', (data) async {
  final c = data['candidate'];
  await peerConnection.addCandidate(
    RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
  );
});
```

### 6.8 Monitor connection state
```dart
peerConnection.onConnectionState = (state) {
  switch (state) {
    case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
      // media is flowing
      break;
    case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
    case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
      // handle reconnect/cleanup
      break;
    default:
      break;
  }
};
```

### 6.9 Clean up
```dart
Future<void> hangUp() async {
  await localStream.dispose();
  await peerConnection.close();
  localRenderer.srcObject = null;
  remoteRenderer.srcObject = null;
}
```
Always call `dispose()` on renderers in `State.dispose()` to avoid leaks.

---

## 7. Minimal Signaling Server (Node.js + Socket.IO)

```js
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

io.on('connection', (socket) => {
  socket.on('join', (room) => socket.join(room));
  socket.on('offer', (data) => socket.to(data.room).emit('offer', data));
  socket.on('answer', (data) => socket.to(data.room).emit('answer', data));
  socket.on('ice-candidate', (data) => socket.to(data.room).emit('ice-candidate', data));
});

server.listen(3000, () => console.log('Signaling server on :3000'));
```
Any transport works as long as it can push messages to a specific peer or
room in near-real-time — Socket.IO, raw WebSockets, Firebase, MQTT, and
Ably are all common choices.

---

## 8. Testing

- **Two physical devices on the same Wi-Fi** is the easiest first test —
  it avoids NAT traversal issues entirely.
- **Two devices on different networks** (e.g. one on Wi-Fi, one on
  cellular) is a better test of real-world ICE/STUN/TURN behavior.
- Use `chrome://webrtc-internals` (Flutter Web) or platform logs to inspect
  ICE candidate types (`host`, `srflx`, `relay`) and confirm negotiation
  is completing.
- Log `onIceConnectionState` and `onConnectionState` during development;
  most "call doesn't connect" bugs show up there first.

---

## 9. Common Pitfalls

| Symptom | Likely Cause |
|---|---|
| Black remote video, audio works | `onTrack` not wiring the stream to the renderer, or video track disabled |
| Works on same Wi-Fi, fails on cellular/different networks | No TURN server configured — STUN alone can't traverse symmetric NATs |
| "Permission denied" on `getUserMedia` | Missing platform permission entries (see §4.3) or user denied the OS prompt |
| Call connects then drops after ~30s | ICE restart not handled, or a proxy/firewall killing idle UDP; add `oniceconnectionstatechange` handling and reconnection logic |
| Works in debug, fails in release (Android) | ProGuard/R8 stripping WebRTC native symbols — add keep rules for `org.webrtc.**` |
| iOS Simulator shows no camera | Simulators don't have camera hardware — test on a physical device |

---

## 10. Moving to Production

1. **Add a TURN server.** STUN alone typically fails for roughly 10–20% of
   real-world connections depending on network types. Options: self-hosted
   [coturn](https://github.com/coturn/coturn), or managed services like
   Twilio Network Traversal Service or Xirsys.
2. **Group calls (3+ people)**: a full mesh of peer connections doesn't
   scale past a handful of participants (each client uploads N-1 streams).
   Use an SFU such as LiveKit, mediasoup, Janus, or Jitsi Videobridge —
   each client uploads once, and the SFU forwards to everyone else.
3. **Reconnection handling**: implement ICE restart
   (`peerConnection.restartIce()`) and reattempt signaling on network
   changes (e.g. Wi-Fi → cellular handoff).
4. **Bandwidth adaptation**: WebRTC does adaptive bitrate automatically,
   but you can cap resolutions/bitrates via `RTCRtpSender.setParameters()`
   for predictable data usage.
5. **Security**: signaling messages should travel over TLS (`wss://`,
   `https://`); authenticate users before letting them join a room; WebRTC
   media itself is encrypted by default (DTLS-SRTP).
6. **Background/lock-screen behavior**: mobile OSes suspend apps
   aggressively; for calls that must survive backgrounding, integrate
   native call-kit style plugins (`flutter_callkit_incoming` on iOS,
   foreground services on Android).

---

## 11. Reference

- Package: [`flutter_webrtc` on pub.dev](https://pub.dev/packages/flutter_webrtc)
- Spec: [W3C WebRTC 1.0](https://www.w3.org/TR/webrtc/)
- TURN server: [coturn](https://github.com/coturn/coturn)
- SFU options: [LiveKit](https://livekit.io/), [mediasoup](https://mediasoup.org/), [Jitsi Videobridge](https://jitsi.org/jitsi-videobridge/)

---

## 12. Where the Working Example Lives

A complete runnable implementation of everything in this guide (Flutter app
+ Node signaling server) was provided earlier in this conversation as the
`webrtc_flutter_example` project — use it alongside this documentation as
a reference implementation.



```


## 📺 Demo Video

[![Watch on YouTube](https://img.youtube.com/vi/q8dh4FB4WAE/maxresdefault.jpg)](https://www.youtube.com/watch?v=q8dh4FB4WAE)

> Click the image above to watch the full video on YouTube.

