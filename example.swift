class ExampleOne<T> {
    func oneArgument(_ value: T) {
        print("This is ExampleOne<T>.oneArgument")
    }
}

let example1 = ExampleOne<Void>()
example1.oneArgument()



class ExampleTwo<T> {
    let closure: (T) -> ()

    init<Class: AnyObject>(instance: Class, method: @escaping (Class) -> (T) -> ()) {
        self.closure = {
            [weak instance] (value: T) in
            guard let instance = instance else { return }
            method(instance)(value)
        }
    }
}

class OrdinaryClass {
    func zeroArguments() { print("This is OrdinaryClass.zeroArguments") }
    func oneArgument(x: Int) { print("This is OrdinaryClass.oneArgument (\(x))") }
    func twoArguments(x: Int, y: Int) { print("This is OrdinaryClass.twoArguments (x * y = \(x * y))") }
}

let oc = OrdinaryClass()

let example2a = ExampleTwo(instance: oc, method: OrdinaryClass.zeroArguments)
example2a.closure()

let example2b = ExampleTwo(instance: oc, method: OrdinaryClass.oneArgument)
example2b.closure(1337)

let example2c = ExampleTwo(instance: oc, method: OrdinaryClass.twoArguments)
example2c.closure(7, 191)