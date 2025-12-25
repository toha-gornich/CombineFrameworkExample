import UIKit
import Foundation
import Combine


// MARK: - Custom operators in Combine and Debug
// Example: Creating custom Combine operators to chain map and filter operations
// Demonstrates how to extend Publisher protocol to add reusable transformation logic
/*
 extension Publisher {
 
 func mapAndFilter<T>(_ transform: @escaping (Output) -> T,
 _ isIncluded: @escaping (T) -> Bool)
 -> AnyPublisher<T, Failure> {
 return self
 .map{transform($0)}
 .filter{isIncluded($0)}
 .eraseToAnyPublisher()
 }
 }
 
 let publisher = [1,2,3,4,5,6,7,8].publisher
 
 publisher.handleEvents{_ in
 print("Subscription received")
 }receiveOutput: { value in
 print(value)
 }receiveCompletion: { completion in
 print("receiveCompletion")
 }receiveCancel: {
 print("receiveCancel")
 }receiveRequest: { _ in
 print("receiveCancel")
 }
 .mapAndFilter({$0 * 2}){value in
 return value % 2 == 0}
 .print("Debug")
 .sink{ value in
 print(value)
 }*/

// Example: Creating type-specific custom operators for filtering integers
// Shows how to add domain-specific methods to Publisher with constrained Output types
/*extension Publisher where Output == Int{
 
 func filterEvenNumbers() -> AnyPublisher<Int, Failure>{
 return self.filter{ $0 % 2 == 0 }
 .eraseToAnyPublisher()
 }
 
 func filterNumbersGreaterThan(_ value: Int) -> AnyPublisher<Int, Failure>{
 
 return self.filter{ $0 > value }
 .eraseToAnyPublisher()
 }
 
 
 }
 
 
 let publisher = [1,2,3,4,5,6,7,8].publisher
 
 let cancellable = publisher.filterEvenNumbers()
 .sink{ value in
 print(value)
 }
 
 let _ = publisher.filterNumbersGreaterThan(5)
 .sink{ value in
 print(value)
 }
 */


// MARK: - Combining Multiple Network Requests
// Demonstrates parallel execution of two API calls using CombineLatest
// Both movie searches run simultaneously and results are combined when both complete
/*
 struct MovieResponse: Decodable{
 let Search: [Movie]
 }
 
 struct Movie: Decodable{
 let title: String
 
 private enum CodingKeys: String, CodingKey {
 case title = "Title"
 }
 }
 
 func fetchMovies(_ searchTerm: String) -> AnyPublisher<MovieResponse, Error> {
 
 let url = URL(string: "https://www.omdbapi.com/?s=\(searchTerm)&page=2&apiKey=apiKey")!
 
 return URLSession.shared
 .dataTaskPublisher(for: url)
 .map(\.data)
 .decode(type: MovieResponse.self, decoder: JSONDecoder())
 .receive(on: DispatchQueue.main)
 .eraseToAnyPublisher()
 
 }
 
 var cancellables: Set<AnyCancellable> = []
 
 Publishers.CombineLatest(fetchMovies("Batman"), fetchMovies("Spiderman"))
 .sink{ _ in
 }receiveValue: { value1, value2 in
 print(value1.Search)
 print(value2.Search)
 }.store(in: &cancellables)
 */

// MARK: - Network Request with Error Handling and Retry
// Shows how to validate HTTP response, handle errors with tryMap, and automatically retry failed requests
// Includes proper error handling in sink with completion and value handlers
/*
 struct Post:Codable{
 let userId: Int
 let id: Int
 let title: String
 let body: String
 
 }
 
 enum NetworkError: Error{
 case badServerResponse
 }
 
 func fetchPosts() -> AnyPublisher<[Post], Error> {
 
 let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
 
 return URLSession.shared
 .dataTaskPublisher(for: url)
 .tryMap{data, response in
 guard let httpResponse = response as? HTTPURLResponse,
 httpResponse.statusCode == 200 else{
 throw NetworkError.badServerResponse
 }
 return data
 }
 .decode(type: [Post].self, decoder: JSONDecoder())
 .retry(3)
 .receive(on: DispatchQueue.main)
 .eraseToAnyPublisher()
 
 }
 
 var cancellables: Set<AnyCancellable> = []
 
 fetchPosts()
 .sink{completion in
 switch completion{
 case .finished:
 print("Update UI")
 case .failure(let error):
 print(error)
 }
 }receiveValue: { posts in
 print(posts)
 }.store(in: &cancellables)
 */

// MARK: - PassthroughSubject with Delayed Emission
// Demonstrates using @MainActor for thread safety and PassthroughSubject to emit values
// Shows how to manually trigger updates after a delay using DispatchQueue
/*
 @MainActor
 class WeatherClient {
 let updates = PassthroughSubject<Int, Never>()
 
 func fetchWeather() {
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[weak self] in
 self?.updates.send(Int.random(in: 32...100))
 }
 }
 }
 
 let client = WeatherClient()
 
 let cancellable = client.updates.sink{value in
 print(value)
 }
 client.fetchWeather()
 */

// MARK: - Custom Subject Implementation (Even Numbers Filter)
// Creates a custom Subject that only emits even numbers by wrapping PassthroughSubject
// Demonstrates how to implement the Subject protocol with filtering logic
/*
 class EvenSubject<Failure: Error>:Subject{
 
 typealias Output = Int
 
 private let wrapped: PassthroughSubject<Int, Failure>
 
 init(initialValue: Int) {
 self.wrapped = PassthroughSubject()
 let evenInitialValue = initialValue % 2 == 0 ? initialValue : 0
 send(initialValue)
 }
 
 func send(_ value: Int) {
 if value % 2 == 0 {
 
 wrapped.send(value)
 }
 }
 func send(subscription: any Subscription) {
 wrapped.send(subscription: subscription)
 }
 
 func send(completion: Subscribers.Completion<Failure>) {
 wrapped.send(completion: completion)
 }
 
 func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Int == S.Input {
 wrapped.receive(subscriber: subscriber)
 }
 
 }
 
 let subject = EvenSubject<Never>(initialValue: 4)
 
 let cancellable = subject
 .sink { value in
 print("Received value: \(value)")
 }
 
 subject.send(1)
 subject.send(2)
 subject.send(3)
 subject.send(4)
 subject.send(5)
 */

// MARK: - PassthroughSubject Basic Usage
// Simple example of PassthroughSubject that doesn't store current value
// Only subscribers receive values sent after they subscribe
/*
 let subject = PassthroughSubject<Int, Never>()
 
 let cancellable = subject
 .sink { value in
 print("Received value: \(value)")
 }
 
 subject.send(1)
 subject.send(2)
 */

// MARK: - CurrentValueSubject Basic Usage
// Unlike PassthroughSubject, CurrentValueSubject stores and immediately emits its current value to new subscribers
// New subscribers get the initial value (1) immediately upon subscription
/*
 let subject = CurrentValueSubject<Int, Never>(1)
 
 let cancellable = subject
 .sink { value in
 print("Received value: \(value)")
 }
 
 subject.send(1)
 subject.send(2)
 */

// MARK: - Error Handling with tryMap and catch
// Shows how to throw errors in a pipeline using tryMap and recover with catch
// When error is thrown, catch replaces the error with a fallback value (0)
/*
 let numbersPublisher = [1,2,3,4,5,6].publisher
 
 let transformedPublisher = numbersPublisher
 .tryMap{value in
 if value == 3{
 throw SampleError.operationFailed
 }
 return value
 }.catch{error in
 print(error)
 return Just(0)
 }
 
 transformedPublisher.sink{value in
 print(value)
 }
 */

// MARK: - Replace Error with Single Value
// Alternative error handling: replaceError substitutes a default value when an error occurs
// Stream continues with the replacement value instead of completing with failure
/*
 let numbersPublisher = [1,2,3,4,5,6].publisher
 let transformedPublisher = numbersPublisher.tryMap{value in
 if value == 3{
 throw SampleError.operationFailed
 }
 return value * 2
 }.replaceError(with: -1)
 transformedPublisher.sink{value in
 print(value)
 }
 */

// MARK: - Retry Failed Operations
// Demonstrates automatic retry mechanism: when an error occurs, retry(2) will attempt the operation 2 more times
// Useful for transient network failures or temporary issues
/*
 let publisher = PassthroughSubject<Int, Error>()
 
 let retriedPublisher = publisher.tryMap{
 value in
 if value == 3{
 throw SampleError.operationFailed
 }
 return value
 }.retry(2)
 
 let cancellable = retriedPublisher.sink{
 completion in
 switch completion{
 case .failure(let error):
 print("Error: \(error)")
 case .finished:
 print("Finished")
 }
 }receiveValue: { value in
 print(value)
 
 }
 publisher.send(1)
 publisher.send(2)
 publisher.send(3)
 publisher.send(4)
 */

// MARK: - CombineLatest Operator
// Emits a tuple whenever ANY of the publishers emits, combining latest values from both
// First emission happens when both publishers have emitted at least once
/*
 let publisher1 = CurrentValueSubject<Int, Never>(1)
 let publisher2 = CurrentValueSubject<Int, Never>(2)
 
 let combinedPublisher = publisher1.combineLatest(publisher2)
 
 let cancellable = combinedPublisher.sink{ value1, value2 in
 print("Value 1: \(value1), Value 2: \(value2)")
 }
 
 publisher1.send(3)
 publisher2.send(4)
 */

// MARK: - Zip Operator (Pairing Values)
// Zip pairs elements from multiple publishers in lockstep - waits for all publishers to emit before emitting a tuple
// If publishers emit different numbers of values, zip stops when the shortest completes
/*
 let publisher1 = [1...4].publisher
 let publisher2 = ["A","B","C","D","E"].publisher
 let publisher3 = ["John","Mary","Alice"].publisher
 
 //let zippedPublisher = publisher1.zip(publisher2)
 
 let zippedPublisher = Publishers.Zip3(publisher1, publisher2,publisher3)
 
 let cancellable2 = zippedPublisher.sink{ value in
 print("Value 1: \(value.1), Value 2: \(value.2)")
 }
 */

// MARK: - SwitchToLatest Operator
// Automatically switches to the latest inner publisher and cancels subscription to previous ones
// Essential for search scenarios where you only want results from the most recent query
/*
 let outerPublisher = PassthroughSubject<AnyPublisher<Int, Never>, Never>()
 let innerPublisher1 = CurrentValueSubject<Int, Never>(1)
 let innerPublisher2 = CurrentValueSubject<Int, Never>(2)
 
 let cancellable = outerPublisher
 .switchToLatest()
 .sink{
 value in
 print(value)
 }
 
 outerPublisher.send(AnyPublisher(innerPublisher1))
 innerPublisher1.send(40)
 
 outerPublisher.send(AnyPublisher(innerPublisher2))
 innerPublisher2.send(10)
 innerPublisher1.send(30)
 */

// MARK: - Filter Operator
// Filters values based on a predicate - only even numbers pass through
// Simple but powerful way to reduce stream to only relevant values
/*
 let numbersPublisher = (1...10).publisher
 
 let evenNumberPublisher = numbersPublisher.filter{ $0 % 2 == 0}
 
 evenNumberPublisher.sink{ value in
 print(value)
 }
 */

// MARK: - CompactMap Operator (Filtering nil values)
// CompactMap transforms and filters out nil values in one operation
// Here it converts strings to integers, automatically removing non-numeric strings
/*
 let strignsPublisher = ["1","2","3","4","A"].publisher
 let intPublisher = strignsPublisher.compactMap(Int.init)
 
 intPublisher.sink{ value in
 print(value)
 }
 */

// MARK: - Debounce Operator (Delayed Emission)
// Debounce waits for a pause in emissions before passing the latest value through
// Perfect for search fields - only triggers after user stops typing for 0.5 seconds
/*
 let textPublisher = PassthroughSubject<String, Never>()
 let debouncedPublisher = textPublisher.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
 
 let cancellebles = debouncedPublisher.sink{value in
 print(value)
 }
 textPublisher.send("Hello")
 DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
 textPublisher.send("Worlds")
 }
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
 textPublisher.send("Worlds2")
 }
 */

// MARK: - Map Operator (Basic Transformation)
// Map transforms each value in the stream using the provided closure
// Simple example of converting numbers to formatted strings
/*
 let numberPublishr = (1...5).publisher
 let squarePublisher = numberPublishr.map{"Item \($0)"}
 squarePublisher.sink{ value in
 print(value)
 }
 */

// MARK: - FlatMap Operator (Flattening Nested Publishers)
// FlatMap transforms each element into a publisher and flattens the results into a single stream
// Here it breaks each name string into individual character publishers
/*
 let namePublisher = ["John", "Jane", "Jim", "Jill"].publisher
 
 let flattedNamePublisher = namePublisher.flatMap{ name in
 name.publisher
 }
 
 flattedNamePublisher.sink{ char in
 print(char)
 }
 */

// MARK: - Merge Operator (Combining Multiple Streams)
// Merge combines multiple publishers into one stream, emitting values as they arrive from any publisher
// Unlike combineLatest, it doesn't wait or pair values - just merges them into one flow
/*
 let publisher1 = [1,2,3].publisher
 let publisher2 = [4,5,6].publisher
 
 let mergedPublisher = Publishers.Merge(publisher1, publisher2)
 
 mergedPublisher.sink{ value in
 print(value)
 }
 */

// MARK: - Timer Publisher (Periodic Emissions)
// Timer publisher emits at regular intervals - useful for polling, animations, or periodic updates
// autoconnect() starts the timer immediately when subscribed
/*
 let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
 let cancellable = timerPublisher.autoconnect().sink{timestamp in
 print("Timestamp: \(timestamp)")
 
 }
 */

// MARK: - Basic Publisher with Manual Cancellation
// Demonstrates subscription lifecycle: creating a subscription and manually cancelling it after a delay
// Important for preventing memory leaks and stopping unwanted updates
/*
 let numbersPublisher = (1...10).publisher
 
 let cancellable = numbersPublisher.sink{value in
 print("Value: \(value)")
 }
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
 cancellable.cancel()
 }
 */

// MARK: - Protocol with Mutating Method Example
// Unrelated to Combine - demonstrates Swift protocol with mutating method for enums
// Shows how value types (enums) can modify themselves using mutating functions
/*
 protocol Togglable {
 mutating func toggle()
 }
 
 enum OnOffSwitch: Togglable {
 case off, on
 mutating func toggle() {
 switch self {
 case .off:
 self = .on
 case .on:
 self = .off
 }
 }
 }
 var lightSwitch = OnOffSwitch.off
 lightSwitch.toggle()
 // lightSwitch is now equal to .on
 */




//4408e2b10534fcae2468bc3ec1f76e83
//
//https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
