//  Write some awesome Swift code, or import libraries like "Foundation",
//  "Dispatch", or "Glibc"

// Helpers

func explain<T>(topic: String, _ body: @autoclosure () -> T) {
  print("---\n\(topic):\n\(body())\n\n")
}

// Paper

protocol ExpSym {
  static func lit(_ n: Int) -> Self
  var neg: Self { get }
  func add(_ e2: Self) -> Self
}

func addExpr<Repr: ExpSym>() -> Repr {
  return Repr.lit(1).neg.add(.lit(3))
}

extension Int: ExpSym {
  static func lit(_ n: Int) -> Int {
    return n
  }
  var neg: Int {
    return -1 * self
  }
  func add(_ e2: Int) -> Int {
    return self + e2
  }
}
func id<T>(t: T) -> T {
  return t
}
let eval: (Int) -> Int = id

explain(
  topic: "Eval add",
  eval(addExpr())
)

extension String: ExpSym {
  static func lit(_ n: Int) -> String {
    return String(n)
  }
  var neg: String {
    return "(-\(self))"
  }
  func add(_ e2: String) -> String {
    return "(\(self) + \(e2))"
  }
}

let view: (String) -> String = id

explain(
  topic: "View add:",
  view(addExpr())
)


protocol MulSym {
  func mul(_ e2: Self) -> Self
}
extension Int: MulSym {
  func mul(_ e2: Int) -> Int {
    return self * e2
  }
}
extension String: MulSym {
  func mul(_ e2: String) -> String {
    return "(\(self) * \(e2))"
  }
}

func mulExpr<Repr: ExpSym>() -> Repr where Repr: MulSym {
  return Repr.lit(1).neg.mul(.lit(3))
}

explain(
  topic: "Eval mul:",
    eval(mulExpr())
)

explain(
  topic: "View mul:",
    view(mulExpr())
)

// Swift has no pattern matching on arrays
indirect enum List<Element> {
  case empty
  case cons(Element, List<Element>)

  var array: [Element] {
    var arr: [Element] = []
    func loop(_ l: List) {
      switch l {
      case .empty:
        return
      case let .cons(head, tail):
        arr.append(head)
        loop(tail)
      }
    }
    loop(self)
    return arr
  }
}
extension List: ExpressibleByArrayLiteral {
    init(arrayLiteral: Element...) {
        self = .empty
    for element in arrayLiteral.reversed() {
            self = .cons(element, self)
        }
    }
}
// lists are printed as arrays
extension List: CustomDebugStringConvertible {
    var debugDescription: String {
    return self.array.debugDescription
    }
}

indirect enum Tree {
  case leaf(String)
  case node(String, List<Tree>)
}
// trees are printed as s-exps
extension Tree: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case let .leaf(s):
      return s
    case let .node(s, xs):
      return "(\(s) " + xs.array.map{ $0.debugDescription }.joined(separator: " ") + ")"
    }
  }
}

extension Tree: ExpSym {
  static func lit(_ n: Int) -> Tree {
    return .node("Lit", [.leaf(String(n))])
  }
  var neg: Tree {
    return .node("Neg", [self])
  }
  func add(_ e2: Tree) -> Tree {
    return .node("Add", [self, e2])
  }
}

let toTree: (Tree) -> Tree = id

explain(
  topic: "Serialize an expr",
  toTree(addExpr())
)

// just using option instead of either for reading

func from<Repr: ExpSym>(tree: Tree) -> Repr? {
  switch tree {
  case let .node("Lit", .cons(.leaf(str), .empty)):
    return Int(str).map{ Repr.lit($0) }
  case let .node("Neg", .cons(e, .empty)):
    let repOpt: Repr? = from(tree: e)
    return repOpt.map{ $0.neg }
  case let .node("Add", .cons(e1, .cons(e2, .empty))):
    let rep1Opt: Repr? = from(tree: e1)
    let rep2Opt: Repr? = from(tree: e2)
    return rep1Opt.flatMap{ rep1 in
      rep2Opt.map{ rep1.add($0) }
    }
  default:
    return nil
  }
}

// roundtrip
explain(
  topic: "Roundtrip toTree >>> fromTree",
  view(
    from(tree: toTree(addExpr()))!
  )
)

// In Swift, we can't extension on Tuples
struct Tuple2<A, B>: ExpSym where A: ExpSym, B: ExpSym {
  let a: A
  let b: B

  init(_ a: A, _ b: B) {
    self.a = a
    self.b = b
  }

  static func lit(_ n: Int) -> Tuple2<A, B> {
    return Tuple2(A.lit(n), B.lit(n))
  }
  var neg: Tuple2<A, B> {
    return Tuple2(self.a.neg, self.b.neg)
  }
  func add(_ e2: Tuple2<A, B>) -> Tuple2<A, B> {
    return Tuple2(
      self.a.add(e2.a),
      self.b.add(e2.b)
    )
  }
}
infix operator <>: AdditionPrecedence
protocol Monoid {
  static var empty: Self { get }
  static func <>(lhs: Self, rhs: Self) -> Self
}

// Writer Monad to accumulate information in dupConsume
struct Writer<M: Monoid, A> {
  var data: M
  var a: A

  init(a: A, data: M) {
    self.a = a
    self.data = data
  }

  init(_ a: A) {
    self.a = a
    self.data = M.empty
  }

  func map<B>(_ f: (A) -> B) -> Writer<M, B> {
    return Writer<M, B>(a: f(a), data: data)
  }

  func flatMap<B>(_ f: (A) -> Writer<M, B>) -> Writer<M, B> {
    let newWriter = f(a)
    return Writer<M, B>(a: newWriter.a, data: data <> newWriter.data)
  }

  mutating func tell(_ m: M) {
    data = data <> m
  }
}
extension Array: Monoid {
  static var empty: Array {
    return []
  }
  static func <>(lhs: Array, rhs: Array) -> Array {
    return lhs + rhs
  }
}

func duplicate<Repr1: ExpSym, Repr2: ExpSym>(_ t: Tuple2<Repr1, Repr2>) -> Tuple2<Repr1, Repr2> {
  return t
}

func dupConsume<Repr1: ExpSym, Repr2: ExpSym>(_ ev: (Repr1) -> Repr1, _ x: Tuple2<Repr1, Repr2>) -> Writer<[String], Repr2> {
  let dupped = duplicate(x)
  let x1 = dupped.a
  let x2 = dupped.b

  var w = Writer<[String], Repr2>(x2)
  w.tell(["\(ev(x1))"])
  return w
}

typealias Triple<A: ExpSym, B: ExpSym, C: ExpSym> = Tuple2<A, Tuple2<B, C>>
func thrice(_ x: Triple<Int, String, Tree>) -> Writer<[String], ()> {
  var w = dupConsume(eval, x).flatMap {
    dupConsume(view, $0)
  }
  w.tell(["\(toTree(w.a))"])
  return w.map{ _ in () }
}

explain(
  topic: "Consume thrice",
  thrice(
    Tuple2(addExpr(), Tuple2(addExpr(), addExpr()))
  ).data
)

// fromTreeExt

func fromTreeExt<Repr: ExpSym>(parse: (Tree) -> Repr?) -> (Tree) -> Repr? {
  return { t in
    switch t {
    case let .node("Lit", .cons(.leaf(str), .empty)):
      return Int(str).map{ Repr.lit($0) }
    case let .node("Neg", .cons(e, .empty)):
      let repOpt: Repr? = from(tree: e)
      return repOpt.map{ $0.neg }
    case let .node("Add", .cons(e1, .cons(e2, .empty))):
      let rep1Opt: Repr? = from(tree: e1)
      let rep2Opt: Repr? = from(tree: e2)
      return rep1Opt.flatMap{ rep1 in
        rep2Opt.map{ rep1.add($0) }
      }
    default:
      return nil
    }
  }
}

// from http://antitypical.com/swift/2015/07/01/pattern-matching-over-recursive-values-in-swift/
public func fix<A, B>(_ f: @escaping ((A) -> B) -> (A) -> B) -> (A) -> B {
  return { f(fix(f))($0) }
}

func fromTree_<Repr: ExpSym>(_ t: Tree) -> Repr? {
  return fix(fromTreeExt)(t)
}

explain(
  topic: "fromTree_ still works like fromTree",
  view(
    fromTree_(toTree(addExpr()))!
  )
)

