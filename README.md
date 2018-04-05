This repository takes a look at a pattern that worked well
in Swift 3, but has since become less and less powerful due
to changes in both Swift 4.0 and Swift 4.1.


## Quick links

* [The actual code I am maintaining][real life]
* [The distilled example (Swift 3.0)][swift 3.0]
* [Changes necessary from 3.0 to 4.0][swift 3.0 to 4.0]
* [Changes necessary from 4.0 to 4.1][swift 4.0 to 4.1]

[real life]: https://github.com/blixt/swift-empty-tuple/blob/swift-3.0/event.swift
[swift 3.0]: https://github.com/blixt/swift-empty-tuple/blob/swift-3.0/example.swift
[swift 3.0 to 4.0]: https://github.com/blixt/swift-empty-tuple/compare/swift-3.0...swift-4.0
[swift 4.0 to 4.1]: https://github.com/blixt/swift-empty-tuple/compare/swift-4.0...swift-4.1


## Notes

In Swift 3.x, a tuple value could be used as an implicit stand-in for multiple
(or zero) arguments. In Swift 4.0 this changed ([SE-0110][]) to require the
tuple to be explicit except when the tuple/argument list is exactly 1 item.

In Swift 4.1 something else changed, so that functions called in a certain way
now no longer support tuples in place of arguments, even explicitly. Instead,
only a single argument must be provided, and the tuple values (if any) must
be accessed through indexed or named properties.

[SE-0110]: https://github.com/apple/swift-evolution/blob/master/proposals/0110-distingish-single-tuple-arg.md


## Usage of the Event class

To explain the purpose of the `Event` class, here’s an excerpt of its use:

```swift
class ChatService {
    static let instance = ChatService()

    let connected = Event<Void>()
    let disconnected = Event<Void>()
    let joinedChannel = Event<Channel>()
    let leftChannel = Event<String>()
    let newMessage = Event<(Channel, Channel.Entry)>()
    let participantsChanged = Event<Channel>()

    // ...
}
```

Emitting an event:

```swift
extension ChatService: WebSocketDelegate {
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let senderId = ..., let type = ..., let data = ... else {
            NSLog("%@", "WARNING: Failed to parse message: \(text)")
            return
        }
        switch type {
        case "join":
            guard let account = ..., let channel = ... else {
                NSLog("%@", "WARNING: Got invalid join message: \(data)")
                break
            }
            channel.accounts[senderId] = account
            self.participantsChanged.emit(channel)  // <---
            print("--- @\(account.username) joined #\(channel.id)")
        case "...":
            // ...
        }
    }

    // ...
}
```

Handling it:

```swift
class ProfileViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
	super.viewWillAppear(animated)
        ChatService.instance.participantsChanged.addListener(self, method: ProfileViewController.handleParticipantsChanged)
        // ...
    }

    override func viewWillDisappear(_ animated: Bool) {
	super.viewWillDisappear(animated)
        ChatService.instance.participantsChanged.removeListener(self)
        // ...
    }

    // ...

    private func handleParticipantsChanged(channel: ChatService.Channel) {
        guard channel.id == self.channelId else {
            return
        }
        self.chatAccounts = channel.accounts
        self.updateSegments()
    }
}
```
