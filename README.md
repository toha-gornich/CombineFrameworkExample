# CombineFrameworkExample

Examples of using **Combine Framework** in Swift for reactive programming.

## 📚 Table of Contents

- [What is Combine?](#what-is-combine)
- [Core Concepts](#core-concepts)
- [Examples](#examples)
  - [Publisher](#publisher)
  - [Operators](#operators)
  - [Subjects](#subjects)
  - [Practical Use Cases](#practical-use-cases)
- [Requirements](#requirements)

---

## What is Combine?

**Combine** is Apple's official framework for reactive programming in Swift. It allows you to handle asynchronous events and data streams declaratively.

### Core Idea
```swift
Publisher → Operator → Subscriber
```

---

## Core Concepts

### 1. Publisher
A source of data that emits values over time.

```swift
let publisher = Just(42)
let arrayPublisher = [1, 2, 3, 4, 5].publisher
let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
```

### 2. Operator
Transforms data between Publisher and Subscriber.

```swift
publisher
    .map { $0 * 2 }
    .filter { $0 > 10 }
    .sink { print($0) }
```

### 3. Subscriber
Receives data from Publisher.

```swift
let cancellable = publisher.sink { value in
    print("Received: \(value)")
}
```

---

## Examples

### Publisher

#### Just — single value
```swift
let publisher = Just("Hello World")

let cancellable = publisher.sink { value in
    print(value)  // Hello World
}
```

#### Sequence — multiple values
```swift
let numbers = [1, 2, 3, 4, 5].publisher

numbers.sink { print($0) }
// Output: 1, 2, 3, 4, 5
```

#### Timer — periodic events
```swift
var cancellables = Set<AnyCancellable>()

Timer.publish(every: 1.0, on: .main, in: .default)
    .autoconnect()
    .sink { date in
        print("Tick: \(date)")
    }
    .store(in: &cancellables)
```

---

### Operators

#### map — transformation
```swift
[1, 2, 3, 4, 5].publisher
    .map { $0 * 2 }
    .sink { print($0) }
// Output: 2, 4, 6, 8, 10
```

#### filter — filtering
```swift
[1, 2, 3, 4, 5, 6].publisher
    .filter { $0 % 2 == 0 }
    .sink { print($0) }
// Output: 2, 4, 6
```

#### debounce — delay
```swift
searchTextField.textPublisher
    .debounce(for: 0.5, scheduler: RunLoop.main)
    .removeDuplicates()
    .sink { text in
        performSearch(text)
    }
    .store(in: &cancellables)
```

#### flatMap — flattening Publishers
```swift
[1, 2, 3].publisher
    .flatMap { userId in
        fetchUser(id: userId)  // Returns Publisher<User>
    }
    .sink { user in
        print(user.name)
    }
    .store(in: &cancellables)
```

---

### Subjects

#### PassthroughSubject — for events
```swift
let subject = PassthroughSubject<Int, Never>()

let cancellable = subject.sink { value in
    print("Received value: \(value)")
}

subject.send(1)  // Received value: 1
subject.send(2)  // Received value: 2
```

#### CurrentValueSubject — for state
```swift
let subject = CurrentValueSubject<Int, Never>(0)

let cancellable = subject.sink { value in
    print("Received value: \(value)")
}
// Received value: 0 (immediately receives current value)

subject.send(5)  // Received value: 5

print(subject.value)  // 5 — readable
```

---

### Practical Use Cases

#### 1. ViewModel with Timer
```swift
import Combine
import Foundation

class CounterViewModel: ObservableObject {
    @Published var count = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Timer.publish(every: 1.0, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.count += 1
            }
            .store(in: &cancellables)
    }
}
```

#### 2. Search with Debounce
```swift
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { text -> AnyPublisher<[String], Never> in
                self.search(text: text)
            }
            .assign(to: &$results)
    }
    
    func search(text: String) -> AnyPublisher<[String], Never> {
        Just(["Result 1", "Result 2", "Result 3"])
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
```

#### 3. Network Request
```swift
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUser(id: Int) {
        isLoading = true
        
        URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://api.example.com/user/\(id)")!)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] user in
                    self?.user = user
                }
            )
            .store(in: &cancellables)
    }
}
```

#### 4. Combining Multiple Publishers
```swift
class FormViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isValid = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                !email.isEmpty && 
                email.contains("@") && 
                password.count >= 6
            }
            .assign(to: &$isValid)
    }
}
```

#### 5. Login → Fetch Profile (sequential requests)
```swift
func login(email: String, password: String) -> AnyPublisher<User, Error> {
    loginAPI(email: email, password: password)
        .flatMap { token in
            fetchProfile(token: token)
        }
        .eraseToAnyPublisher()
}

login(email: "test@test.com", password: "123456")
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { user in
            print("Welcome, \(user.name)!")
        }
    )
    .store(in: &cancellables)
```

---

## Useful Operators

| Operator | Description |
|----------|-------------|
| `map` | Transforms values |
| `filter` | Filters values |
| `flatMap` | Flattens nested Publishers |
| `debounce` | Delays execution |
| `removeDuplicates` | Removes duplicates |
| `combineLatest` | Combines latest values |
| `merge` | Merges streams |
| `catch` | Handles errors |
| `retry` | Retries on failure |

---

## sink vs assign

### sink — universal
```swift
publisher.sink { value in
    // Full control
    self.property = value
    print("Updated!")
}
```

### assign — automatic assignment
```swift
// Old way (retain cycle!)
publisher.assign(to: \.property, on: self)

// New way iOS 14+ (safe)
publisher.assign(to: &$property)
```

---

## Memory Management

### Always store cancellable!
```swift
var cancellables = Set<AnyCancellable>()

publisher
    .sink { print($0) }
    .store(in: &cancellables)  // IMPORTANT!
```

### Use [weak self] to avoid retain cycles
```swift
publisher
    .sink { [weak self] value in
        self?.updateUI(value)
    }
    .store(in: &cancellables)
```

---

## Requirements

- iOS 13.0+
- macOS 10.15+
- Xcode 11.0+
- Swift 5.1+

---

## Useful Links

- [Apple Official Documentation](https://developer.apple.com/documentation/combine)
- [Using Combine](https://heckj.github.io/swiftui-notes/)
- [Combine Community](https://github.com/CombineCommunity)

---

## Author

Created for learning Combine Framework

## License

MIT License
