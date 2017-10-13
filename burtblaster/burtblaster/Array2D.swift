//
//  Array2D.swift
//  burtblaster
//
//  Created by Alex Burt on 10/4/17.
//  Copyright © 2017 Bloc. All rights reserved.
//

// #1

class Array2D<T> {
    let columns: Int
    let rows: Int
    
    // #2
    
    var array: Array <T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        
        
        // #3
        
        array = Array<T?>(count:rows * columns, repeatedValue:nil)
        
    }
    
    
    //#4
    
    subscript(column: Int, row:Int) -> T? {
        
        get {
            
            return array[(row * columns) + column]
        }
        
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
        
    }
    
}



