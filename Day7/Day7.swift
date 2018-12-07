import Cocoa

let tInput = """
C, A
C, F
A, B
A, D
B, E
D, E
F, E
""".components(separatedBy: "\n")
let input = try! String(contentsOfFile: "day7.txt").components(separatedBy: "\n")

struct Rule {
    
    init(_ string: String) {
        let comps = string.components(separatedBy: ", ")
        self.step = comps[1]
        self.dependency = comps[0]
    }
    
    var step: String
    var dependency: String
}

let rules = input.map { Rule($0) }
let allSteps = Set(rules.flatMap { [$0.step, $0.dependency] })

var stepsCompleted = [String]()

func isStepReady(_ step: String) -> Bool {
    let relevantRules = rules.filter { $0.step == step }
    for dep in relevantRules.map({ $0.dependency}) {
        if !stepsCompleted.contains(dep) { return false }
    }
    return true
}

var remainingSteps = allSteps

while remainingSteps.count > 0 {
    let readySteps = remainingSteps.filter(isStepReady).sorted()
    if readySteps.count == 0 {
        print("Done")
    }
    remainingSteps.remove(readySteps[0])
    stepsCompleted.append(readySteps[0])
}
print(stepsCompleted.joined())

// Part 2

extension Character {
    var uint8: UInt8 {
        return Array(String(self).utf8)[0]
    }
}

func timeForStep(_ step: String) -> Int {
    let val = step.first!.uint8
    return Int(val) - 4
}

remainingSteps = allSteps
stepsCompleted = [String]()

class Worker {
    
    init(index: Int) {
        self.index = index
    }
    
    let index: Int
    
    private var timeLeft: Int = 0
    var step: String? {
        didSet {
            guard let step = step else { timeLeft = 0; return }
            timeLeft = timeForStep(step)
        }
    }
    func tick() {
        guard let step = step else { return }
        timeLeft -= 1
        if timeLeft == 0 {
            stepsCompleted.append(step)
            self.step = nil
        }
    }
    
    var isReady: Bool { return timeLeft == 0 }    
}

let workers = Array(1...5).map { Worker(index: $0) }
var timeTaken = 0
while true { /* remainingSteps.count > 0 || (workers.filter({ !$0.isReady }).count == 0) { */
    let readyWorkers = workers.filter { $0.isReady }
    
    let readySteps = remainingSteps.filter(isStepReady).sorted()
    for (index, worker) in readyWorkers.enumerated() {
        guard index < readySteps.count else { break }
        let step = readySteps[index]
        worker.step = step
        remainingSteps.remove(step) 
    }
    
    let workerStates = workers.map({ "\($0.step ?? ".")" }).joined(separator: "    ")
    print("\(timeTaken)    \(workerStates)    \(stepsCompleted.joined())")
    
    workers.forEach { $0.tick() }
    timeTaken += 1
    
    if remainingSteps.count == 0 && workers.filter({ !$0.isReady }).count == 0 {
        break
    }
}
print(timeTaken)