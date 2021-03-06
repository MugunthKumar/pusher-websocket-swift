//
//  PusherSwiftTests.swift
//  PusherSwiftTests
//
//  Created by Hamilton Chapman on 24/02/2015.
//
//

import Foundation
import UIKit
import Quick
import Nimble
import PusherSwift
import Starscream

// Setup mock objects that we will need
public class MockWebSocket: WebSocket {
    let stubber = StubberForMocks()
    var callbackCheckString: String = ""
    var objectGivenToCallback: AnyObject? = nil

    init() {
        super.init(url: NSURL(string: "test")!)
    }

    public func appendToCallbackCheckString(str: String) {
        self.callbackCheckString += str
    }

    public func storeDataObjectGivenToCallback(data: AnyObject) {
        self.objectGivenToCallback = data
    }

    override public func connect() {
        stubber.stub(
            "connect",
            args: nil,
            functionToCall: {
                self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher:connection_established\",\"data\":\"{\\\"socket_id\\\":\\\"45481.3166671\\\",\\\"activity_timeout\\\":120}\"}")
            }
        )
    }

    override public func disconnect() {
        stubber.stub(
            "disconnect",
            args: nil,
            functionToCall: {
                self.delegate?.websocketDidDisconnect(self, error: nil)
            }
        )
    }

    override public func writeString(str: String) {
        if str == "{\"data\":{\"channel\":\"test-channel\"},\"event\":\"pusher:subscribe\"}" || str == "{\"event\":\"pusher:subscribe\",\"data\":{\"channel\":\"test-channel\"}}" {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"channel\":\"test-channel\",\"data\":\"{}\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["key:6aae8814fabd5285245422096705abbed64ea59614648814ffb0bf2dc5d19168", "private-channel", "pusher:subscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"channel\":\"private-channel\",\"data\":\"{}\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["key:5ce61ee2b8594e22b66323913d7c7af9d8e815659365be3627733993f4ce3824", "presence-channel", "user_id", "45481.3166671", "pusher:subscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"data\":\"{\\\"presence\\\":{\\\"count\\\":1,\\\"ids\\\":[\\\"46123.486095\\\"],\\\"hash\\\":{\\\"46123.486095\\\":null}}}\",\"channel\":\"presence-channel\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["key:e1d0947a10d6ff1a25990798910b2505687bb096e3e8b6c97eef02c6b1abb4c7", "private-channel", "pusher:subscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"channel\":\"private-channel\",\"data\":\"{}\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["data", "testing client events", "private-channel", "client-test-event"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: nil
            )
        } else if stringContainsElements(str, elements: ["testKey123:12345678gfder78ikjbg", "private-test-channel", "pusher:subscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"channel\":\"private-test-channel\",\"data\":\"{}\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["key:0d0d2e7c2cd967246d808180ef0f115dad51979e48cac9ad203928141f9e6a6f", "private-test-channel", "pusher:subscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"channel\":\"private-test-channel\",\"data\":\"{}\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["test-channel", "pusher:unsubscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: nil
            )
        } else if stringContainsElements(str, elements: ["testkey123:e5ee520a16348ced21be557e14ae70fcd1ae89f79d32d14d22a19049eaf56881", "presence-test", "user_id", "123", "pusher:subscribe", "user_info", "twitter", "hamchapman"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"data\":\"{\\\"presence\\\":{\\\"count\\\":1,\\\"ids\\\":[\\\"123\\\"],\\\"hash\\\":{\\\"123\\\":{\\\"twitter\\\":\\\"hamchapman\\\"}}}}\",\"channel\":\"presence-test\"}")
                }
            )
        } else if stringContainsElements(str, elements: ["key:c2b53f001321bc088814f210fb63c259b464f590890eee2dde6387ea9b469a30", "presence-channel", "user_id", "123", "pusher:subscribe"]) {
            stubber.stub(
                "writeString",
                args: [str],
                functionToCall: {
                    self.delegate?.websocketDidReceiveMessage(self, text: "{\"event\":\"pusher_internal:subscription_succeeded\",\"data\":\"{\\\"presence\\\":{\\\"count\\\":1,\\\"ids\\\":[\\\"123\\\"],\\\"hash\\\":{\\\"123\\\":{}}}}\",\"channel\":\"presence-channel\"}")
                }
            )
        }
    }
}

public func stringContainsElements(str: String, elements: [String]) -> Bool {
    var allElementsPresent = true
    for e in elements {
        if str.rangeOfString(e) == nil {
            allElementsPresent = false
        }
    }

    return allElementsPresent
}

public class MockPusherConnection: PusherConnection {
    let stubber = StubberForMocks()

    init(options: Dictionary<String, Any>? = nil) {
        let pusherClientOptions = PusherClientOptions(options: options)
        super.init(key: "key", socket: MockWebSocket(), url: "ws://blah.blah:80", options: pusherClientOptions)
    }

    override public func handleEvent(eventName: String, jsonObject: Dictionary<String,AnyObject>) {
        stubber.stub(
            "handleEvent",
            args: [eventName, jsonObject],
            functionToCall: { super.handleEvent(eventName, jsonObject: jsonObject) }
        )
    }
}

public class MockPusherChannel: PusherChannel {
    let stubber = StubberForMocks()

    init(name: String, connection: MockPusherConnection) {
        super.init(name: name, connection: connection)
    }

    override public func handleEvent(eventName: String, eventData: String) {
        stubber.stub(
            "handleEvent",
            args: [eventName, eventData],
            functionToCall: { super.handleEvent(eventName, eventData: eventData) }
        )
    }
}

public class StubberForMocks {
    public var calls:[FunctionCall]
    public var responses:[String:AnyObject]

    init() {
        self.calls = []
        self.responses = [:]
    }

    public func stub(functionName:String, args:[Any]?, functionToCall: (() -> Any?)?) -> AnyObject? {
        calls.append(FunctionCall(name: functionName, args: args))
        if let response: AnyObject = responses[functionName] {
            return response
        } else if let functionToCall = functionToCall {
            functionToCall()
        }
        return nil
    }
}

public class FunctionCall {
    public let name:String
    public let args:[Any]?

    init(name:String, args:[Any]?) {
        self.name = name
        self.args = args
    }
}

class PusherClientInitializationSpec: QuickSpec {
    override func spec() {
        describe("creating the connection") {
            var key: String!
            var pusher: Pusher!

            beforeEach({
                key = "testKey123"
                pusher = Pusher(key: key)
            })

            it("has the connection object") {
                expect(pusher.connection).toNot(beNil())
            }

            context("with default config") {
                it("has the correct conection url") {
                    expect(pusher.connection.url).to(equal("wss://ws.pusherapp.com:443/app/testKey123?client=pusher-swift&version=0.0.1&protocol=7"))
                }

                it("has auth endpoint as nil") {
                    expect(pusher.connection.options.authEndpoint).to(beNil())
                }

                it("has secret as nil") {
                    expect(pusher.connection.options.secret).to(beNil())
                }

                it("has userDataFetcher as nil") {
                    expect(pusher.connection.options.userDataFetcher).to(beNil())
                }

                it("has attemptToReturnJSONObject as true") {
                    expect(pusher.connection.options.attemptToReturnJSONObject).to(beTruthy())
                }

                it("has auth method of none") {
                    expect(pusher.connection.options.authMethod).to(equal(AuthMethod.NoMethod))
                }
            }

            context("passing in configuration options") {
                context("unencrypted") {
                    it("has the correct conection url") {
                        pusher = Pusher(key: key, options: ["encrypted": false])
                        expect(pusher.connection.url).to(equal("ws://ws.pusherapp.com:80/app/testKey123?client=pusher-swift&version=0.0.1&protocol=7"))
                    }
                }

                context("an auth endpoint") {
                    it("has one set") {
                        pusher = Pusher(key: key, options: ["authEndpoint": "http://myapp.com/auth-endpoint"])
                        expect(pusher.connection.options.authEndpoint).to(equal("http://myapp.com/auth-endpoint"))
                    }
                }

                context("a secret") {
                    it("has one set") {
                        pusher = Pusher(key: key, options: ["secret": "superSecret"])
                        expect(pusher.connection.options.secret).to(equal("superSecret"))
                    }
                }

                context("a userDataFetcher function") {
                    it("has one function set") {
                        func fetchFunc() -> PusherUserData {
                            return PusherUserData(userId: "1")
                        }
                        pusher = Pusher(key: key, options: ["userDataFetcher": fetchFunc])
                        expect(pusher.connection.options.userDataFetcher).toNot(beNil())
                    }
                }

                context("attemptToReturnJSONObject as false") {
                    it("is false") {
                        pusher = Pusher(key: key, options: ["attemptToReturnJSONObject": false])
                        expect(pusher.connection.options.attemptToReturnJSONObject).to(beFalsy())
                    }
                }
            }
        }
    }
}

class PusherTopLevelApiSpec: QuickSpec {
    override func spec() {
        var key: String!
        var pusher: Pusher!
        var socket: MockWebSocket!

        beforeEach({
            key = "testKey123"
            pusher = Pusher(key: key)
            socket = MockWebSocket()
            socket.delegate = pusher.connection
            pusher.connection.socket = socket
        })

        describe("creating the connection") {
            it("calls connect on the socket") {
                pusher.connect()
                expect(socket.stubber.calls[0].name).to(equal("connect"))
            }

            it("connected is set to true when connection connects") {
                pusher.connect()
                expect(pusher.connection.connected).to(beTruthy())
            }
        }

        describe("closing the connection") {
            it("calls disconnect on the socket") {
                pusher.connect()
                pusher.disconnect()
                expect(socket.stubber.calls[1].name).to(equal("disconnect"))
            }

            it("connected is set to false when connection is disconnected") {
                pusher.connect()
                expect(pusher.connection.connected).to(beTruthy())
                pusher.disconnect()
                expect(pusher.connection.connected).to(beFalsy())
            }

            it("sets the subscribed property of channels to false") {
                pusher.connect()
                let chan = pusher.subscribe("test-channel")
                expect(chan.subscribed).to(beTruthy())
                pusher.disconnect()
                expect(chan.subscribed).to(beFalsy())
            }
        }

        describe("subscribing to channels") {
            describe("after connection has been made") {
                beforeEach({
                    pusher.connect()
                })

                it("sends subscribe to Pusher over the Websocket") {
                    _ = pusher.subscribe("test-channel")
                    expect(socket.stubber.calls.last?.name).to(equal("writeString"))
                    expect(socket.stubber.calls.last?.args!.first as? String).to(equal("{\"data\":{\"channel\":\"test-channel\"},\"event\":\"pusher:subscribe\"}"))
                }

                it("subscribes to a public channel") {
                    pusher.subscribe("test-channel")
                    let testChannel = pusher.connection.channels.channels["test-channel"]
                    expect(testChannel?.subscribed).to(beTruthy())
                }

                it("sets up the channel correctly") {
                    let chan = pusher.subscribe("test-channel")
                    expect(chan.name).to(equal("test-channel"))
                    expect(chan.eventHandlers).to(beEmpty())
                }

                describe("that require authentication") {
                    beforeEach({
                        pusher = Pusher(key: "key", options: ["secret": "secret"])
                        socket.delegate = pusher.connection
                        pusher.connection.socket = socket
                        pusher.connect()
                    })

                    it("subscribes to a private channel") {
                        pusher.subscribe("private-channel")
                        let privateChannel = pusher.connection.channels.channels["private-channel"]
                        expect(privateChannel?.subscribed).to(beTruthy())
                    }

                    it("subscribes to a presence channel") {
                        pusher.subscribe("presence-channel")
                        let presenceChannel = pusher.connection.channels.channels["presence-channel"]
                        expect(presenceChannel?.subscribed).to(beTruthy())
                    }

                    it("sets up the channel correctly") {
                        let chan = pusher.subscribe("private-channel")
                        expect(chan.name).to(equal("private-channel"))
                        expect(chan.eventHandlers).to(beEmpty())
                    }
                }
            }

            describe("before connection has been made") {
                it("subscribes to a public channel") {
                    pusher.subscribe("test-channel")
                    let testChannel = pusher.connection.channels.channels["test-channel"]
                    pusher.connect()
                    expect(testChannel?.subscribed).to(beTruthy())
                }

                it("sets up the channel correctly") {
                    let chan = pusher.subscribe("test-channel")
                    expect(chan.name).to(equal("test-channel"))
                    expect(chan.eventHandlers).to(beEmpty())
                }

                describe("that require authentication") {
                    beforeEach({
                        pusher = Pusher(key: "key", options: ["secret": "secret"])
                        socket.delegate = pusher.connection
                        pusher.connection.socket = socket
                    })

                    it("subscribes to a private channel") {
                        pusher.subscribe("private-channel")
                        let privateChannel = pusher.connection.channels.channels["private-channel"]
                        pusher.connect()
                        expect(privateChannel?.subscribed).to(beTruthy())
                    }

                    it("subscribes to a presence channel") {
                        pusher.subscribe("presence-channel")
                        let presenceChannel = pusher.connection.channels.channels["presence-channel"]
                        pusher.connect()
                        expect(presenceChannel?.subscribed).to(beTruthy())
                    }

                    it("sets up the channel correctly") {
                        let chan = pusher.subscribe("private-channel")
                        expect(chan.name).to(equal("private-channel"))
                        expect(chan.eventHandlers).to(beEmpty())
                    }
                }
            }
        }

        describe("unsubscribing from a channel") {
            it("removes the channel from the connection's channels property") {
                pusher.connect()
                pusher.subscribe("test-channel")
                expect(pusher.connection.channels.channels["test-channel"]).toNot(beNil())
                pusher.unsubscribe("test-channel")
                expect(pusher.connection.channels.channels["test-channel"]).to(beNil())
            }

            it("sends unsubscribe to Pusher over the Websocket") {
                pusher.connect()
                pusher.subscribe("test-channel")
                pusher.unsubscribe("test-channel")
                expect(socket.stubber.calls.last?.name).to(equal("writeString"))
                expect(socket.stubber.calls.last?.args!.first as? String).to(equal("{\"data\":{\"channel\":\"test-channel\"},\"event\":\"pusher:unsubscribe\"}"))
            }
        }

        describe("binding to events globally") {
            it("adds a callback to the globalChannel's list of callbacks") {
                pusher.connect()
                let callback = { (data: AnyObject?) -> Void in print(data) }
                expect(pusher.connection.globalChannel?.globalCallbacks.count).to(equal(0))
                pusher.bind(callback)
                expect(pusher.connection.globalChannel?.globalCallbacks.count).to(equal(1))
            }
        }

        describe("unbinding a global callback") {
            it("unbinds the callback from the globalChannel's list of callbacks") {
                pusher.connect()
                let callback = { (data: AnyObject?) -> Void in print(data) }
                let callBackId = pusher.bind(callback)
                expect(pusher.connection.globalChannel?.globalCallbacks.count).to(equal(1))
                pusher.unbind(callBackId)
                expect(pusher.connection.globalChannel?.globalCallbacks.count).to(equal(0))
            }
        }

        describe("unbinding all global callbacks") {
            it("unbinds the callback from the globalChannel's list of callbacks") {
                pusher.connect()
                let callback = { (data: AnyObject?) -> Void in print(data) }
                pusher.bind(callback)
                let callbackTwo = { (someData: AnyObject?) -> Void in print(someData) }
                pusher.bind(callbackTwo)
                expect(pusher.connection.globalChannel?.globalCallbacks.count).to(equal(2))
                pusher.unbindAll()
                expect(pusher.connection.globalChannel?.globalCallbacks.count).to(equal(0))
            }
        }
    }
}

class PusherChannelSpec: QuickSpec {
    override func spec() {
        describe("creating the channel") {
            it("sets up the channel with the correct name and no callbacks") {
                let chan = PusherChannel(name: "test-channel", connection: MockPusherConnection())
                expect(chan.name).to(equal("test-channel"))
                expect(chan.eventHandlers).to(beEmpty())
            }
        }

        describe("binding to an event") {
            it("adds an eventName, callback pair to a channel's callbacks") {
                let chan = PusherChannel(name: "test-channel", connection: MockPusherConnection())
                expect(chan.eventHandlers["test-event"]).to(beNil())
                chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                expect(chan.eventHandlers["test-event"]).toNot(beNil())
            }
        }

        describe("unbinding an eventHandler") {
            it("should remove the eventHandler for the given eventName and eventHandler id") {
                let chan = PusherChannel(name: "test-channel", connection: MockPusherConnection())
                expect(chan.eventHandlers["test-event"]).to(beNil())
                let idOne = chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                expect(chan.eventHandlers["test-event"]?.count).to(equal(2))
                chan.unbind("test-event", callbackId: idOne)
                expect(chan.eventHandlers["test-event"]?.count).to(equal(1))
            }
        }

        describe("unbinding all eventHandlers for an eventName") {
            it("should remove the eventHandlers for the given eventName") {
                let chan = PusherChannel(name: "test-channel", connection: MockPusherConnection())
                expect(chan.eventHandlers["test-event"]).to(beNil())
                chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                expect(chan.eventHandlers["test-event"]?.count).to(equal(2))
                chan.unbindAllForEventName("test-event")
                expect(chan.eventHandlers["test-event"]?.count).to(equal(0))
            }
        }

        describe("unbinding all eventHandlers") {
            it("should remove the eventHandler for the given eventName and eventHandler id") {
                let chan = PusherChannel(name: "test-channel", connection: MockPusherConnection())
                expect(chan.eventHandlers["test-event"]).to(beNil())
                chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                chan.bind("test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                chan.bind("another-test-event", callback: { (data: AnyObject?) -> Void in print(data) })
                expect(chan.eventHandlers.count).to(equal(2))
                chan.unbindAll()
                expect(chan.eventHandlers.count).to(equal(0))
            }
        }

        describe("triggering a client event") {
            var connection: MockPusherConnection!
            var socket: MockWebSocket!

            beforeEach({
                socket = MockWebSocket()
                connection = MockPusherConnection(options: ["secret": "superSecretSecret"])
                socket.delegate = connection
                connection.socket = socket
            })

            it("should not result in the socket writing a string if the channel isn't a private or presence channel") {
                let chan = PusherChannel(name: "test-channel", connection: connection)
                chan.subscribed = true
                chan.trigger("client-test-event", data: ["data": "testing client events"])
                expect(socket.stubber.calls).to(beEmpty())
            }

            it("should result in the socket writing a string if the channel is a private or presence channel") {
                let chan = PusherChannel(name: "private-channel", connection: connection)
                chan.subscribed = true
                chan.trigger("client-test-event", data: ["data": "testing client events"])
                expect(socket.stubber.calls.first?.args?.first as? String).to(equal("{\"data\":{\"data\":\"testing client events\"},\"event\":\"client-test-event\",\"channel\":\"private-channel\"}"))
            }

            it("should send any client events that were triggered before subscription was successful") {
                let chan = PusherChannel(name: "private-channel", connection: connection)
                connection.channels.channels["private-channel"] = chan
                expect(chan.unsentEvents).to(beEmpty())
                chan.trigger("client-test-event", data: ["data": "testing client events"])
                expect(chan.unsentEvents.keys).to(contain("client-test-event"))
                expect(socket.stubber.calls).to(beEmpty())
                connection.connect()
                expect(socket.stubber.calls.last?.args?.first as? String).to(equal("{\"data\":{\"data\":\"testing client events\"},\"event\":\"client-test-event\",\"channel\":\"private-channel\"}"))
            }
        }
    }
}

class HandlingIncomingEventsSpec: QuickSpec {
    override func spec() {
        describe("receiving an event") {
            var key: String!
            var pusher: Pusher!
            var socket: MockWebSocket!

            beforeEach({
                key = "testKey123"
                pusher = Pusher(key: key)
                socket = MockWebSocket()
                socket.delegate = pusher.connection
                pusher.connection.socket = socket
            })

            it("should call any callbacks setup on the globalChannel") {
                let callback = { (data: AnyObject?) -> Void in socket.appendToCallbackCheckString("testingIWasCalled") }
                pusher.bind(callback)
                expect(socket.callbackCheckString).to(equal(""))
                pusher.connection.handleEvent("test-event", jsonObject: ["event": "test-event", "channel": "my-channel", "data": "stupid data"])
                expect(socket.callbackCheckString).to(equal("testingIWasCalled"))
            }

            it("should call the relevant callback(s) setup on the relevant channel(s)") {
                let callback = { (data: AnyObject?) -> Void in socket.appendToCallbackCheckString("channelCallbackCalled") }
                let chan = pusher.subscribe("my-channel")
                chan.bind("test-event", callback: callback)
                expect(socket.callbackCheckString).to(equal(""))
                pusher.connection.handleEvent("test-event", jsonObject: ["event": "test-event", "channel": "my-channel", "data": "stupid data"])
                expect(socket.callbackCheckString).to(equal("channelCallbackCalled"))
            }

            it("should call the relevant callback(s) setup on the relevant channel(s) and on the globalChannel") {
                let callback = { (data: AnyObject?) -> Void in socket.appendToCallbackCheckString("globalCallbackCalled") }
                pusher.bind(callback)
                let chan = pusher.subscribe("my-channel")
                let callbackForChannel = { (data: AnyObject?) -> Void in socket.appendToCallbackCheckString("channelCallbackCalled") }
                chan.bind("test-event", callback: callbackForChannel)
                expect(socket.callbackCheckString).to(equal(""))
                pusher.connection.handleEvent("test-event", jsonObject: ["event": "test-event", "channel": "my-channel", "data": "stupid data"])
                expect(socket.callbackCheckString).to(equal("globalCallbackCalledchannelCallbackCalled"))
            }

            it("should return a JSON object to the callbacks if the string can be parsed and the user wanted to get a JSON object") {
                let callback = { (data: AnyObject?) -> Void in socket.storeDataObjectGivenToCallback(data!) }
                let chan = pusher.subscribe("my-channel")
                chan.bind("test-event", callback: callback)
                expect(socket.objectGivenToCallback).to(beNil())
                pusher.connection.handleEvent("test-event", jsonObject: ["event": "test-event", "channel": "my-channel", "data": "{\"test\":\"test string\",\"and\":\"another\"}"])
                expect(socket.objectGivenToCallback as? Dictionary<String, String>).to(equal(["test": "test string", "and": "another"]))
            }

            it("should return a JSON string to the callbacks if the string cannot be parsed and the user wanted to get a JSON object") {
                let callback = { (data: AnyObject?) -> Void in socket.storeDataObjectGivenToCallback(data!) }
                let chan = pusher.subscribe("my-channel")
                chan.bind("test-event", callback: callback)
                expect(socket.objectGivenToCallback).to(beNil())
                pusher.connection.handleEvent("test-event", jsonObject: ["event": "test-event", "channel": "my-channel", "data": "test"])
                expect(socket.objectGivenToCallback as? String).to(equal("test"))
            }

            it("should return a JSON string to the callbacks if the string can be parsed but the user doesn't want to get a JSON object") {
                pusher = Pusher(key: key, options: ["attemptToReturnJSONObject": "false"])
                socket.delegate = pusher.connection
                pusher.connection.socket = socket
                let callback = { (data: AnyObject?) -> Void in socket.storeDataObjectGivenToCallback(data!) }
                let chan = pusher.subscribe("my-channel")
                chan.bind("test-event", callback: callback)
                expect(socket.objectGivenToCallback).to(beNil())
                pusher.connection.handleEvent("test-event", jsonObject: ["event": "test-event", "channel": "my-channel", "data": "{\"test\":\"test string\",\"and\":\"another\"}"])
                expect(socket.objectGivenToCallback as? String).to(equal("{\"test\":\"test string\",\"and\":\"another\"}"))
            }
        }
    }
}

class MockSession: NSURLSession {
    var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?

    static var mockResponse: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) = (data: nil, urlResponse: nil, error: nil)

    override class func sharedSession() -> NSURLSession {
        return MockSession()
    }
        
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        self.completionHandler = completionHandler
        return MockTask(response: MockSession.mockResponse, completionHandler: completionHandler)
    }

    class MockTask: NSURLSessionDataTask {
        typealias Response = (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
        var mockResponse: Response
        let completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?

        init(response: Response, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
            self.mockResponse = response
            self.completionHandler = completionHandler
        }
        override func resume() {
            completionHandler!(mockResponse.data, mockResponse.urlResponse, mockResponse.error)
        }
    }
}

class AuthenticationSpec: QuickSpec {
    override func spec() {
        var pusher: Pusher!
        var socket: MockWebSocket!

        beforeEach({
            pusher = Pusher(key: "testKey123", options: ["authEndpoint": "http://localhost:9292/pusher/auth"])
            socket = MockWebSocket()
            socket.delegate = pusher.connection
            pusher.connection.socket = socket
        })

        describe("subscribing to a private channel") {
            it("should make a request to the authEndpoint") {
                let jsonData = "{\"auth\":\"testKey123:12345678gfder78ikjbg\"}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "\(pusher.connection.options.authEndpoint!)?channel_name=private-test-channel&socket_id=45481.3166671")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
                MockSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
                pusher.connection.URLSession = MockSession.sharedSession()

                let chan = pusher.subscribe("private-test-channel")
                expect(chan.subscribed).to(beFalsy())
                pusher.connect()
                expect(chan.subscribed).toEventually(beTruthy())
            }

            it("should create the auth signature internally") {
                pusher = Pusher(key: "key", options: ["secret": "secret"])
                socket.delegate = pusher.connection
                pusher.connection.socket = socket

                let chan = pusher.subscribe("private-test-channel")
                expect(chan.subscribed).to(beFalsy())
                pusher.connect()
                expect(chan.subscribed).to(beTruthy())
            }

            it("should not subscribe successfully to a private or presence channel if no auth method provided") {
                pusher = Pusher(key: "key")
                socket.delegate = pusher.connection
                pusher.connection.socket = socket

                let chan = pusher.subscribe("private-test-channel")
                expect(chan.subscribed).to(beFalsy())
                pusher.connect()
                expect(chan.subscribed).to(beFalsy())
            }
        }
    }
}

class PusherPresenceChannelSpec: QuickSpec {
    override func spec() {
        var pusher: Pusher!
        var socket: MockWebSocket!

        beforeEach({
            socket = MockWebSocket()
        })

        describe("the members object") {
            it("stores the userId if a userDataFetcher is provided") {
                pusher = Pusher(key: "key", options: [
                    "secret": "secret",
                    "userDataFetcher": { () -> PusherUserData in
                        return PusherUserData(userId: "123")
                    }
                ])
                socket.delegate = pusher.connection
                pusher.connection.socket = socket
                pusher.connect()
                let chan = pusher.subscribe("presence-channel") as? PresencePusherChannel
                expect(chan?.members.first!.userId).to(equal("123"))
            }

            it("stores the socketId if no userDataFetcher is provided") {
                pusher = Pusher(key: "key", options: ["secret": "secret"])
                socket.delegate = pusher.connection
                pusher.connection.socket = socket
                pusher.connect()
                let chan = pusher.subscribe("presence-channel") as? PresencePusherChannel
                expect(chan?.members).toNot(beEmpty())
                expect(chan?.members.first!.userId).to(equal("46123.486095"))
            }

            it("stores userId and userInfo if a userDataFetcher that returns both is provided") {
                pusher = Pusher(key: "testKey123", options: [
                    "secret": "secret",
                    "userDataFetcher": { () -> PusherUserData in
                        return PusherUserData(userId: "123", userInfo: ["twitter": "hamchapman"])
                    }
                ])
                socket.delegate = pusher.connection
                pusher.connection.socket = socket
                pusher.connect()
                let chan = pusher.subscribe("presence-test") as? PresencePusherChannel
                expect(chan?.members).toNot(beEmpty())
                expect(chan?.members.first!.userInfo as? Dictionary<String, String>).to(equal(["twitter": "hamchapman"]))
            }
        }
    }
}