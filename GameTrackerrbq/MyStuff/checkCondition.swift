//
//  checkCondition.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-07-30.
//

/*
 use a literal to get a result
    Text(checkCondition(123, "<", 456) ? "True" : "False")
*/

func checkCondition(_ lhs: Int, _ op: String, _ rhs: Int) -> Bool {
    switch op {
    case "<":
        return lhs < rhs
    case ">":
        return lhs > rhs
    case "==":
        return lhs == rhs
    case "<=":
        return lhs <= rhs
    case ">=":
        return lhs >= rhs
    case "!=":
        return lhs != rhs
    default:
        return false
    }
}
