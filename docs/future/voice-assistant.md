# Voice Assistant — Making AI Universally Accessible

Status: Future (V2+)

This document specifies the voice interface for Familiar. Voice is not an add-on feature — it's the **primary interface** that makes Familiar accessible to everyone, from grandma to developers.

---

## Why Voice is Essential

### The Universal Interface Problem

**Text interfaces require**:

- Technical vocabulary
- Comfort with typing commands
- Understanding of what's possible
- Computer literacy

**Voice interfaces require**:

- Just saying what you want
- Natural language (however you say it)
- No interface anxiety
- No technical knowledge

**Conclusion**: If Familiar is truly for everyone, voice must be primary.

### The "Code is Invisible" Model

Consider two experiences:

**Text interaction**:

```
User types: "organize my desktop"
Familiar shows: Code blocks, file paths, commands
Even if collapsed, the technical nature is visible
```

**Voice interaction**:

```
User: "Can you organize my desktop?"
Familiar: "Sure! I found 47 images, 23 PDFs, and 8 videos.
Should I put them in separate folders?"
User: "Yeah, that's fine"
Familiar: "Done! Your desktop is organized."
```

**No code visible. No technical details. Pure problem → solution.**

This is why voice enables the vision of "Familiar for everyone."

---

## Core Principles

### 1. Conversational, Not Command-Based

**Wrong** (Siri-like commands):

- "Hey Familiar, organize desktop files"
- Rigid syntax, specific phrasing required
- Feels robotic and transactional

**Right** (Natural conversation):

- "My desktop is a mess, can you help?"
- "I need to organize these photos"
- "What should I do with all these files?"
- Flexible, forgiving, human

### 2. Interruptible and Correctable

**The problem with many voice assistants**: You can't interrupt them.

**Familiar voice UX**:

- User can interrupt mid-response
- "Wait, stop" cancels immediately
- "Actually, I meant..." corrects understanding
- Back-and-forth feels natural

### 3. Privacy First

**Voice data handling**:

- Never stored (processed and discarded)
- Clear indication when microphone is active
- User chooses transcription method (local vs cloud)
- Can disable voice entirely

### 4. Optional but Recommended

**Voice should be**:

- Default enabled on first launch
- Easy to disable in settings
- Seamlessly switches to text-only
- Never forced on users

---

## Technical Architecture

### Input: Speech Recognition

**Option 1: macOS Native (SFSpeechRecognizer)**

**Pros**:

- Free, no API costs
- Works offline
- Respects system language preferences
- Privacy: on-device processing

**Cons**:

- Requires microphone permission
- Accuracy varies by accent/language
- Limited to macOS supported languages

**Implementation**:

```swift
import Speech

class VoiceInputManager {
    private let recognizer = SFSpeechRecognizer(locale: Locale.current)
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func startListening(onResult: @escaping (String) -> Void)
    func stopListening()
    func cancelListening()
}
```

**Option 2: OpenAI Whisper API**

**Pros**:

- Better accuracy for diverse accents
- Multilingual support
- Handles background noise well
- Continuous improvement

**Cons**:

- Requires API key and internet
- Costs money (but cheap: ~$0.006/minute)
- Audio sent to OpenAI

**Implementation**:

```python
# Backend endpoint
@app.post("/transcribe")
async def transcribe_audio(audio: UploadFile):
    result = openai.Audio.transcribe("whisper-1", audio.file)
    return {"text": result.text}
```

**Recommendation**:

- V2: Start with macOS native (free, fast, private)
- V3+: Add Whisper as option for users who want better accuracy
- User setting: "Transcription: On-device / Cloud (more accurate)"

### Output: Text-to-Speech

**Option 1: macOS Native (AVSpeechSynthesizer)**

**Pros**:

- Free, no API costs
- Many voices available
- System integration
- Works offline

**Cons**:

- Less natural than modern TTS
- Limited voice personality options
- Can sound robotic

**Implementation**:

```swift
import AVFoundation

class VoiceOutputManager {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, voice: AVSpeechSynthesisVoice? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Adjust for natural pace
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
```

**Option 2: OpenAI TTS API**

**Pros**:

- Very natural sounding
- Multiple voice options (alloy, echo, fable, onyx, nova, shimmer)
- Consistent quality
- Can stream for low latency

**Cons**:

- Requires API key and internet
- Costs money (~$15/1M characters)
- Latency (network dependent)

**Recommendation**:

- V2: Start with native (fast, free, offline)
- V3+: Add OpenAI TTS as premium option
- User setting: "Voice: System / Natural (premium)"

### Wake Word Detection

**For hands-free activation**: "Hey Familiar"

**Technical Approaches**:

**Option 1: Porcupine (Picovoice)**

- On-device wake word detection
- Low latency (~1 second)
- Free tier available
- Works offline

**Option 2: Snowboy (Deprecated)**

- Previously popular, now unmaintained
- Not recommended

**Option 3: Custom ML Model**

- Train Core ML model for "Hey Familiar"
- Most privacy-preserving
- Requires ML expertise

**Recommendation**:

- V3-V4: Add wake word detection
- Start with Porcupine (proven solution)
- User setting: "Activation: Hotkey only / 'Hey Familiar' / Both"

---

## UX Patterns

### Activation

**Method 1: Hotkey + Voice (V2)**

1. User presses Cmd+Space (or configured hotkey)
2. Window appears with listening indicator
3. Familiar: "What can I help you with?"
4. User speaks their request
5. Visual transcription appears as they speak

**Method 2: Wake Word (V3+)**

1. User says "Hey Familiar"
2. Chime sound indicates activation
3. Listening indicator appears
4. User states their request
5. No window needed (voice-only mode)

### Listening Indicators

**Visual**:

- Pulsing circle (breathes while listening)
- Color: Accent color
- Size: Grows slightly with voice volume
- Position: Center of window or floating orb

**Audio**:

- Activation: Brief ascending chime
- Listening: Subtle ambient pulse (optional)
- Understood: Confirmation tone
- Error: Apologetic descending tone

**Text**:

- "I'm listening..." (fades in after 2s if user hasn't spoken)
- Transcription appears live as user speaks
- "I heard: [transcription]" (confirms understanding)

### Transcription Feedback

**Real-time display**:

```
┌─────────────────────────────────┐
│  🎤  Listening...               │
│                                 │
│  "Can you organize my desk..."  │
│   ▌ (cursor blinks)             │
└─────────────────────────────────┘
```

**After completion**:

```
┌─────────────────────────────────┐
│  I heard:                       │
│  "Can you organize my desktop?" │
│                                 │
│  [That's right]  [Let me fix it]│
└─────────────────────────────────┘
```

User can:

- Confirm ("That's right" or just wait 2s → auto-confirm)
- Correct ("Let me fix it" → shows editable text field)

### Conversation Flow

**Standard flow**:

```
User: "Can you organize my desktop?"
Familiar: [thinks for 1-2 seconds]
Familiar: "Sure! I found 47 images, 23 PDFs, and 8 videos.
Should I put them in separate folders?"

User: "Yeah, that's fine"
Familiar: [working]
Familiar: "Done! Your desktop is organized. The images are in
'Images', PDFs in 'Documents', and videos in 'Videos'."

User: "Thanks!"
Familiar: "Happy to help!"
```

**With clarification**:

```
User: "Help me with the photos"
Familiar: "Sure! I can see you have photos in several places.
Should I organize your desktop photos, or photos from your
Downloads folder, or both?"

User: "Just desktop"
Familiar: "Got it, organizing desktop photos now..."
```

**With interruption**:

```
Familiar: "I'll organize all 150 files on your desktop into—"
User: "Wait, stop"
Familiar: [stops immediately]
Familiar: "Okay, stopped. What would you like to do instead?"
```

### Permissions via Voice

**Voice-based approval**:

```
Familiar: "To organize your desktop, I'll create three folders
and move files around. Is that okay?"

User: "Yes" / "Go ahead" / "Sounds good"
→ Approved

User: "Wait, will you delete anything?"
→ Familiar explains, then asks again

User: "No" / "Not right now" / "Cancel"
→ Cancelled
```

**Visual backup**:

- While waiting for voice approval, show visual approval sheet
- User can approve via voice OR click button
- Whichever comes first

### Error Handling

**Didn't understand**:

```
Familiar: "Sorry, I didn't catch that. Could you say it again?"
```

**Ambiguous request**:

```
User: "Fix it"
Familiar: "I'm not sure what you'd like me to fix. Can you be
more specific?"
```

**Permission denied**:

```
Familiar: "Hmm, I can't access that folder - it seems I don't
have permission. Should I try something else?"
```

**Background noise**:

```
Familiar: "Sorry, there's a lot of background noise. Can you
try again in a quieter place, or would you like to type instead?"
```

---

## Voice + Visual Modes

### Mode 1: Voice + Visual (Default)

**Window shows**:

- Transcription of what user said
- Familiar's responses (text + voice)
- Visual progress for long operations
- Results with links/buttons
- Can click anything while voice is active

**Best for**:

- First-time users
- Complex tasks
- When you want to see results
- Office/shared environments

### Mode 2: Voice-Only (Advanced)

**No window needed**:

- "Hey Familiar" → starts listening
- Entire conversation via voice
- Notification for completion
- Results announced verbally

**Best for**:

- Power users
- Quick tasks
- Hands-free situations
- Driving, cooking, etc.

### Mode 3: Text-Only (Fallback)

**Voice disabled**:

- Type requests in prompt field
- No voice input or output
- Everything else works normally

**Best for**:

- Quiet environments (library, late night)
- Users who prefer typing
- Accessibility (some deaf users may prefer text)
- When microphone unavailable

**User setting**:

```
Interface Mode:
● Voice + Visual (recommended)
○ Voice-only (hands-free)
○ Text-only (silent)

□ Show transcription
□ Enable voice output
```

---

## Privacy & Security

### Voice Data Handling

**Input (User speech)**:

- Audio captured temporarily in memory
- Transcribed to text (on-device OR via Whisper)
- Audio immediately discarded after transcription
- Text sent to Claude for processing
- User can review transcription before sending

**Output (Familiar speech)**:

- Generated text-to-speech on demand
- No audio stored
- No logging of voice content

**Settings**:

```
Privacy Settings:

Transcription Method:
● On-device (private, works offline)
○ Cloud (more accurate, requires internet)

Voice Storage:
□ Never store voice recordings
□ Show transcription before sending

Microphone:
● Only active when listening
○ Always active (wake word detection)

Clear Voice History: [Button]
```

### Permissions

**macOS Permissions Required**:

- Microphone access (for speech input)
- Speech recognition (for on-device transcription)

**User Control**:

- Can revoke permissions anytime in System Settings
- Familiar gracefully falls back to text-only mode
- Clear explanation of why each permission is needed

---

## Example Conversations

### Example 1: Grandma Organizing Photos

```
Grandma: [presses hotkey grandson set up]
Familiar: "Hi! What can I help you with?"

Grandma: "I took a bunch of photos at my grandson's birthday
and I want to send them to the family"

Familiar: "That's sweet! Are the photos on your computer or
your phone?"

Grandma: "I already put them on the computer, they're on the
desktop"

Familiar: "Perfect! I found 47 photos from this weekend.
Should I make an album you can share with everyone?"

Grandma: "Yes please"

Familiar: "I can create a nice photo album as a PDF, or put
them in a folder you can email, or upload them to share online.
Which sounds best?"

Grandma: "What's easiest for them to see?"

Familiar: "Probably a PDF - everyone can open it, and it'll
look nice like a photo book. Want me to make that?"

Grandma: "Yes, that sounds good"

Familiar: "Great! I'll arrange them by time and add the date.
Is that okay?"

Grandma: "Yes"

Familiar: [20 seconds pass]
Familiar: "All done! I made 'Birthday Photos 2025.pdf' on your
desktop. It has all 47 photos arranged by when you took them.
Ready to email!"

Grandma: "Thank you!"

Familiar: "You're welcome! Enjoy sharing the memories."
```

**Key observations**:

- Natural back-and-forth
- Familiar asks clarifying questions
- Options explained in human terms
- No technical jargon
- Warm, helpful tone

### Example 2: Developer Debugging

```
Dev: "Hey Familiar, review my changes for security issues"

Familiar: "Sure! Let me look at your uncommitted changes..."
[analyzes]

Familiar: "I found a potential issue in your authentication
code - you're storing tokens in local storage instead of httpOnly
cookies. Want me to explain the security implications?"

Dev: "Yeah, and show me the code"

Familiar: [window opens with code highlighted]
Familiar: "Here's the concern: local storage is accessible to
any JavaScript, including XSS attacks. Should I refactor this
to use secure cookies?"

Dev: "Yeah, do it"

Familiar: "I'll need to modify auth.js and server.js. Is that
okay?"

Dev: "Go ahead"

Familiar: [makes changes]
Familiar: "Done! I moved token storage to httpOnly cookies and
updated the server to handle them. Want me to run the tests?"

Dev: "Sure"

Familiar: [runs tests]
Familiar: "All tests pass. You're good to commit."
```

**Key observations**:

- Technical user gets technical details
- Voice + visual works together
- Can reference code while talking
- Fast interaction (minimal confirmations)
- Familiar adapts to user's expertise level

### Example 3: Small Business Owner

```
Owner: "I need to send invoices to all my clients"

Familiar: "I can help with that. Do you have a list of clients
I should use?"

Owner: "Yeah, it's in a spreadsheet on my desktop"

Familiar: "Got it. I found 'clients.csv' with 23 clients. Should
I create invoices for all of them?"

Owner: "Yes"

Familiar: "And do you have an invoice template, or should I make
one?"

Owner: "Make one, just something simple"

Familiar: "No problem. I'll create a simple invoice with your
business name and each client's details. Is that okay?"

Owner: "Perfect"

Familiar: "Great! This will take about 30 seconds..." [works]

Familiar: "All done! I created 23 invoices in a folder called
'Invoices 2025' on your desktop. Want me to email them to clients
or just save them for now?"

Owner: "Just save them, I'll review first"

Familiar: "Smart! They're ready when you need them."
```

**Key observations**:

- Business context, not technical
- Familiar offers to do more (email invoices)
- User stays in control (reviews first)
- Clear outcomes described
- Professional but friendly tone

---

## Implementation Roadmap

### V2: Basic Voice Input/Output

**Goal**: Speak requests, hear responses

**Features**:

- Hotkey activates voice input
- macOS native speech recognition
- Visual transcription feedback
- macOS native TTS for responses
- Voice + visual mode only

**Implementation**:

- 2-3 weeks
- SwiftUI voice input component
- Integration with existing conversation flow
- Settings toggle for voice on/off

### V3: Enhanced Voice Experience

**Goal**: Polished voice interaction

**Features**:

- OpenAI Whisper option (better accuracy)
- OpenAI TTS option (natural voice)
- Improved conversation flow
- Better error handling
- Voice interruption support

**Implementation**:

- 2-3 weeks after V2
- Backend transcription endpoint
- TTS generation service
- Enhanced UX patterns

### V4: Wake Word & Voice-Only Mode

**Goal**: Hands-free operation

**Features**:

- "Hey Familiar" wake word detection
- Voice-only mode (no window needed)
- Background operation
- Continuous conversation

**Implementation**:

- 3-4 weeks after V3
- Wake word detection integration
- Voice-only UI mode
- Background audio handling

### V5+: Advanced Features

**Possible future enhancements**:

- Multiple voice personalities
- Voice customization (pitch, speed, style)
- Emotion detection (adapt responses)
- Multi-language support
- Voice-based shortcuts ("Quick action: organize desktop")

---

## Technical Challenges

### Challenge 1: Latency

**Problem**: Voice interaction feels slow if there's latency

**Solutions**:

- Transcribe while user is still speaking
- Start processing before user finishes
- Stream TTS output (don't wait for full response)
- Show visual feedback immediately

**Target**: < 500ms from user stops speaking to Familiar starts responding

### Challenge 2: Ambiguity

**Problem**: Voice requests can be imprecise

**Solutions**:

- Ask clarifying questions
- Show visual options to choose from
- Learn from corrections
- Default to safest interpretation

**Example**:

```
User: "Help me with the files"
Familiar: "Which files? I can see your desktop, downloads, and
documents folder. Or did you mean something specific?"
```

### Challenge 3: Background Noise

**Problem**: Poor transcription in noisy environments

**Solutions**:

- Use Whisper (better noise handling)
- Detect poor audio quality → suggest quiet place
- Show confidence score → confirm if low
- Graceful fallback to text input

### Challenge 4: Interruption

**Problem**: User needs to interrupt Familiar

**Technical solution**:

- Continuous microphone monitoring
- Detect voice activity during TTS
- Immediate stop on interruption
- Resume capability

**UX pattern**:

```
Familiar: "I'll organize all 150 files on your—"
User: "Wait" [detected]
Familiar: [stops immediately]
Familiar: "Okay, what would you like instead?"
```

---

## Integration with Hidden Delights

Voice opens unique opportunities for easter eggs and surprises.

### Voice-Only Secrets

**"Tell me a secret"**:

```
User: "Tell me a secret"
Familiar: "Okay, here's one: If you say 'midnight mode' between
12-1am, I'll change to a special night theme."
```

**"Who made you?"**:

```
User: "Who made you?"
Familiar: "I was created by someone who believes AI should be
magical but accessible. Want to hear the full story?"
```

**"Sing me a song"**:

```
User: "Sing me a song"
Familiar: "I'm better at organizing files than singing, but I
appreciate the confidence! Want me to find some music for you
instead?"
```

### Voice Personality

Familiar can develop personality through voice:

- Slight humor in responses
- Warmth in error messages
- Enthusiasm for success
- Empathy when user is stuck

**Not cutesy, but human.**

---

## Success Metrics

### V2 Launch Goals

- **Activation rate**: 40%+ of users try voice in first session
- **Retention**: 60%+ continue using voice after first try
- **Accuracy**: 90%+ transcription accuracy for clear speech
- **Satisfaction**: Voice users rate experience 4+/5 stars

### V4 Goals (Voice-Only Mode)

- **Adoption**: 20%+ of voice users try voice-only mode
- **Task completion**: 80%+ successfully complete tasks via voice only
- **Preference**: 30%+ prefer voice-only for quick tasks

---

## Open Questions

1. Should voice output be on by default, or opt-in?
2. What should the default voice be (gender, accent, personality)?
3. How do we handle multiple languages and accents?
4. Should wake word be "Hey Familiar" or something shorter?
5. How much personality should the voice have?
6. Should there be different voice modes (professional, casual, etc.)?

---

## Related Documents

- **`aesthetic-system.md`**: Design system including voice UX principles
- **`hidden-delights.md`**: Voice-specific easter eggs and secrets
- **`intelligent-zero-state.md`**: Voice integration with zero state

---

_Voice isn't just a feature - it's how Familiar becomes universally accessible._

**Last Updated**: September 30, 2025
**Status**: Future (V2+) — Essential for universal accessibility vision
