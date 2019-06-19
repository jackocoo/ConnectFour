//
//  ConnectColumn.swift
//  ConnectFohre
//
//  Created by joconnor on 6/14/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import UIKit
import QuartzCore

class ConnectColumn: UIStackView {
    
    private var cellList = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.spacing = 10.0
        self.distribution = UIStackView.Distribution.fillEqually
        self.cellList = [UIView]() //maybe dont need this
        populateColumn()
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.axis = .vertical
        self.spacing = 10.0
        self.distribution = UIStackView.Distribution.fillEqually
        self.cellList = [UIView]() //maybe dont need this 
        populateColumn()
    }
    
    
    private func populateColumn() {
        for _ in 0..<6 {
            let cell =  UILabel()
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.blue.cgColor
            cell.layer.borderWidth = 3.0
            cell.layer.cornerRadius = 16.0
            cell.layer.masksToBounds = true
            self.cellList.append(cell)
            
            cell.translatesAutoresizingMaskIntoConstraints = false
            //cell.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            cell.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
            cell.widthAnchor.constraint(equalToConstant: 34.0).isActive = true
            addArrangedSubview(cell)
        }
    }
    /*
     changes color of the appropriate cell 
    */
    public func changeCellColor(row: Int, player: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            let cell: UIView = self.cellList[row]
            self.removeArrangedSubview(cell)
            if (player == "red") {
                cell.backgroundColor = UIColor.red
            } else if (player == "black") {
                cell.backgroundColor = UIColor.black
            } else {
                cell.backgroundColor = UIColor.white
            }
            self.insertArrangedSubview(cell, at: (5 - row))
            self.cellList[row] = cell
        })
    }
    
    
    public func gamePieceDrop(targetRow: Int, currentCount: Int, player: Player, delay: Int) {
        var num = currentCount
        if(num == targetRow) {
            self.changeCellColor(row: currentCount, player: player.rawValue)
            return
        } else {
            self.changeCellColor(row: currentCount, player: player.rawValue)
            num -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay), execute: {
                self.changeCellColor(row: currentCount, player: Player.empty.rawValue)
                self.gamePieceDrop(targetRow: targetRow, currentCount: num, player: player, delay: delay)
            })
        }
    }
    
    
    public func resetColumnColor() {
        for i in 0..<6 {
            self.gamePieceDrop(targetRow: i, currentCount: 5, player: Player.empty, delay: 50)
            //self.changeCellColor(row: i, player: "empty")
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
