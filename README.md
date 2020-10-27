# Introduction

A swift implementation of concurrent (thread-safe) skip list.  
This package is mostly based on [sean-public/fast-skiplist](https://github.com/sean-public/fast-skiplist).

## What is Skip List?

To simply put, skip list is a data structure to represent an ordered set.  
This package provides API similar to swift's `Set`.  
It is a probabilistic data structure and the average complexity of `search`, `insert` and `delete` are O(logn) respectively, while O(n) in worst cases.  

| | Average | Worst case |
| - | - | - |
| Search | O(logn) | O(n) |
| Insert | O(logn) | O(n) |
| Delete | O(logn) | O(n) |

# Installation

## Swift Package Manager

Add the following to `Package.swift`.

```
dependencies: [
  .package(url: "https://github.com/takumatt/ConcurrentSkipList.git", from: "1.0.0"),
]
```
