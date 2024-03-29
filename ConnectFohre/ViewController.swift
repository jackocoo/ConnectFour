//
//  ViewController.swift
//  ConnectFohre
//
//  Created by joconnor on 6/14/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UITextFieldDelegate  {
    
    var tapRecognizers: [UITapGestureRecognizer] = []
    var pressDownRecognizers: [UITapGestureRecognizer] = []

    var columnList: [ConnectColumn] = []
    let boardData: BoardData = BoardData()
    //let playerLabel: UILabel = PaddingLabel()
    let playerButton: UIButton = UIButton()
    let resetButton: UIButton = UIButton()
    let weatherLabel: PaddingLabel = PaddingLabel()
    let cityInput: UITextField = UITextField()
    let connectedLabel: PaddingLabel = PaddingLabel()
    let connectedImage: UIImageView = UIImageView()


    let connectService = ConnectService()
    
    

    override func viewDidLoad() {
        connectService.delegate = self
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1.00, green: 0.90, blue: 0.0, alpha: 1.0)
        
        Weather.getWeatherFromWeb(forCity: "Boston") { (result: Weather) in
            DispatchQueue.main.async {
                self.weatherLabel.text = "\(result.city) - \(result.temp)˚F - \(result.description)"
            }
        }
        
        //creates the board
        let fullBoard = UIStackView()
        fullBoard.axis = .horizontal
        fullBoard.distribution = .fillEqually
        fullBoard.spacing = 12.0
        view.addSubview(fullBoard)
        
        //populate board with columns
        for _ in 0..<7 {
            let currentColumn = ConnectColumn()
            currentColumn.isUserInteractionEnabled = true
            fullBoard.addArrangedSubview(currentColumn)
            columnList.append(currentColumn)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            let down = UITapGestureRecognizer(target: self, action: #selector(self.handlePress))
            tapRecognizers.append(tap)
            pressDownRecognizers.append(down)
            currentColumn.addGestureRecognizer(tap)
            
        }
        
        //board constraints
        fullBoard.translatesAutoresizingMaskIntoConstraints = false
        fullBoard.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let topConstraint = fullBoard.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 110)
        topConstraint.priority = .defaultLow
        topConstraint.isActive = true
        
        fullBoard.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -50).isActive = true
        // Do any additional setup after loading the view.
        
        //sets up button which displays current player and eventually the winner
        playerButton.isEnabled = false
        playerButton.backgroundColor = UIColor.white
        playerButton.setTitle("\(boardData.getCurrentPlayer().rawValue) is current player", for: UIControl.State.disabled)
        playerButton.setTitleColor(UIColor.blue, for: UIControl.State.disabled)
        playerButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        playerButton.titleLabel?.font = UIFont(name: "American Typewriter", size: 20)
        playerButton.titleLabel?.backgroundColor = UIColor.white
        playerButton.layer.borderColor = UIColor.blue.cgColor
        playerButton.layer.borderWidth = 1.0
        playerButton.layer.cornerRadius = 16.0
        playerButton.contentEdgeInsets.left = 10
        playerButton.contentEdgeInsets.right = 10
        playerButton.contentEdgeInsets.bottom = 10
        playerButton.contentEdgeInsets.top = 10
        playerButton.layer.masksToBounds = true
        playerButton.titleLabel?.textAlignment = .center

        view.addSubview(playerButton)
        
        playerButton.translatesAutoresizingMaskIntoConstraints = false
        //playerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        playerButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        playerButton.topAnchor.constraint(equalTo: fullBoard.bottomAnchor, constant: 10).isActive = true

        //creates button that resets the board
        resetButton.isEnabled = true
        resetButton.backgroundColor = UIColor.white
        resetButton.setTitle("reset", for: UIControl.State.normal)
        resetButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        resetButton.titleLabel?.font = UIFont(name: "American Typewriter", size: 20)
        resetButton.layer.borderColor = UIColor.blue.cgColor
        resetButton.layer.borderWidth = 1.0
        resetButton.layer.cornerRadius = 16.0
        resetButton.contentEdgeInsets.left = 10
        resetButton.contentEdgeInsets.right = 10
        resetButton.contentEdgeInsets.top = 10
        resetButton.contentEdgeInsets.bottom = 10
        resetButton.layer.masksToBounds = true
        resetButton.titleLabel?.textAlignment = .center
        resetButton.addTarget(self, action: #selector(pressedReset), for: UIControl.Event.touchUpInside)
        resetButton.addTarget(self, action: #selector(pressedDown), for: UIControl.Event.touchDown)
        
        view.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConstraint = resetButton.leadingAnchor.constraint(equalTo: fullBoard.leadingAnchor)
        buttonConstraint.priority = .defaultLow
        buttonConstraint.isActive = true
        resetButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        resetButton.trailingAnchor.constraint(equalTo: playerButton.leadingAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: playerButton.topAnchor).isActive = true
        
        //creates label that says ConnectForecast
        let gameName = PaddingLabel()
        gameName.backgroundColor = UIColor.blue
        gameName.text = "ConnectForecast"
        gameName.textColor = UIColor.white
        gameName.textAlignment = .center
        gameName.layer.borderColor = UIColor.white.cgColor
        gameName.layer.borderWidth = 1.0
        gameName.layer.cornerRadius = 5.0
        gameName.layer.masksToBounds = true
        //gameName.font = gameName.font.withSize(24)
        gameName.font = UIFont(name:"American Typewriter", size: 30.0)
        gameName.frame = CGRect(x: 0, y: 0, width: gameName.intrinsicContentSize.width, height: gameName.intrinsicContentSize.width)
        
        view.addSubview(gameName)
        
        gameName.translatesAutoresizingMaskIntoConstraints = false
        gameName.bottomAnchor.constraint(equalTo: fullBoard.topAnchor, constant: -15).isActive = true
        gameName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
    
        
        
        //label that refelects whether or not the device is connected to another one for gameplay
        connectedLabel.backgroundColor = UIColor(red: 1.00, green: 0.90, blue: 0.0, alpha: 1.0)
        connectedLabel.textColor = UIColor.blue
        connectedLabel.text = "Searching for connection..."
        connectedLabel.font = UIFont(name: "American Typewriter", size: 16)
        
        view.addSubview(connectedLabel)
        
        connectedLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        connectedLabel.topAnchor.constraint(equalTo: playerButton.bottomAnchor, constant: 20).isActive = true
        
        //let image: UIImage = UIImage(named: "connecting")!
        connectedImage.image = UIImage(named: "celltower")
        
        view.addSubview(connectedImage)
        connectedImage.translatesAutoresizingMaskIntoConstraints = false
        connectedImage.topAnchor.constraint(equalTo: connectedLabel.bottomAnchor, constant: 5).isActive = true
        connectedImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        connectedImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        connectedImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        //creates label that displays the city, temperature, and description of weather
        weatherLabel.backgroundColor = UIColor.blue
        weatherLabel.text = "I wonder what the weather is... "
        weatherLabel.textColor = UIColor.white
        weatherLabel.layer.borderColor = UIColor.white.cgColor
        weatherLabel.layer.borderWidth = 1.0
        weatherLabel.layer.cornerRadius = 5.0
        weatherLabel.layer.masksToBounds = true
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont(name: "American Typewriter", size: 20)
        weatherLabel.adjustsFontSizeToFitWidth = true
        
        view.addSubview(weatherLabel)
        
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        weatherLabel.topAnchor.constraint(equalTo: connectedImage.bottomAnchor, constant: 50).isActive = true
        weatherLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        weatherLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        
        //text field that allows user to change which city's weather information is displayed
        cityInput.delegate = self
        cityInput.backgroundColor = UIColor.white
        cityInput.placeholder = "input city "
        cityInput.textColor = UIColor.blue
        cityInput.layer.borderColor = UIColor.blue.cgColor
        cityInput.layer.borderWidth = 1.0
        cityInput.layer.cornerRadius = 5.0
        cityInput.layer.masksToBounds = true
        cityInput.textAlignment = .center
        cityInput.font = UIFont(name: "American Typewriter", size: 20)
        cityInput.isUserInteractionEnabled = true
        cityInput.enablesReturnKeyAutomatically = true
        cityInput.adjustsFontSizeToFitWidth = true
        
        view.addSubview(cityInput)
        
        cityInput.translatesAutoresizingMaskIntoConstraints = false
        cityInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cityInput.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 20).isActive = true
        cityInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        
    }
    
    /*
     Recognizes which column was tapped and places new board piece here if possible
     edits color of cell and changes the data in the array
     changes the current player if the move was made
    */
    
    //when the reset button is pressed, this method resets the board and the peer's board
    @objc func pressedReset(_sender: UIButton) {
        resetButtonPressed(button: _sender)
        connectService.send(connectName: "reset")
    }
    
    
    //button becomes highlighted once it is pressed down
    @objc func pressedDown(_sender: UIButton) {
        if(_sender.isHighlighted) {
            _sender.backgroundColor = UIColor.lightGray
            _sender.titleLabel?.backgroundColor = UIColor.lightGray
            _sender.isHighlighted = false
        } else {
            _sender.backgroundColor = UIColor.white
            _sender.titleLabel?.backgroundColor = UIColor.white
            _sender.isHighlighted = true
        }
        return
    }
    
    
    //gives the columns a pressed down state
    @objc func handlePress(_sender: UITapGestureRecognizer) {
        let index = pressDownRecognizers.firstIndex(of: _sender)
        guard let indexFound: Int = index else {
            print("Something was nil")
            return
        }
        let column: ConnectColumn = columnList[indexFound]
        print("HERE I AM")
        column.backgroundColor = UIColor.lightGray

    }
    
    //allows user to tap columns to play game pieces, becomes disabled once the game is one, then reenabled
    //once the game is restarted
    @objc func handleTap(_sender: UITapGestureRecognizer) {
        
        if (self.boardData.getGameOver()) {
            return
        }
        let index = tapRecognizers.firstIndex(of: _sender)
        
        self.moveAndUpdateUI(index: index!)
        let strIndex: String = String(index!)
        connectService.send(connectName: strIndex)
    }
    
    
    //when the text field is done
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("made it to this part of the file")
        
        let newCity = textField.text
        let cityURL = newCity?.makeURLFriendly()

        Weather.getWeatherFromWeb(forCity: cityURL!) { (result: Weather) in
            DispatchQueue.main.async {
                self.weatherLabel.text = "\(newCity!) - \(result.temp)˚F - \(result.description)"
            }
        }
    }
    
    
    //when the text field returns
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //operations for executing a move and changing the UI accordingly
    func moveAndUpdateUI(index: Int) {
        
        if (self.boardData.getGameOver()) {
            return
        }
        
        let player: Player  = self.boardData.getCurrentPlayer()
        self.boardData.changeCurrentPlayer()

        guard let indexFound: Int = index else {
            print("Something was nil")
            return
        }

        print("column \(indexFound) has been tapped")
        
        let moveValid = boardData.makeMove(column: indexFound)
        if (moveValid != -1) {
            print("move is good to go")
        } else {
            print("cannot make the move for some reason")
            return
        }
        
        let column: ConnectColumn = columnList[indexFound]
        column.backgroundColor = UIColor.yellow
        column.gamePieceDrop(targetRow: moveValid, currentCount: 5, player: player, delay: 25)
        
        let win = boardData.checkWin(column: indexFound, row: moveValid)
        if (win) {
            boardData.changeGameOver()
            //playerButton.isEnabled = true
            //playerLabel.text = "\(boardData.getCurrentPlayer().rawValue) wins"
            playerButton.setTitle("\(player.rawValue) wins...Reset?", for: UIControl.State.normal)
            return
        }
        
        print("Winning move --> \(win)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            //playerLabel.text = "\(boardData.getCurrentPlayer().rawValue) is the current player"
            self.playerButton.setTitle("\(self.boardData.getCurrentPlayer().rawValue) is current player", for: UIControl.State.disabled)
        } )
    }
    

    func resetButtonPressed(button : UIButton) {
        boardData.resetBoard()
        for i in 0..<7               {
            let column = columnList[i]
            column.resetColumnColor()
        }
        if (boardData.getGameOver()) {
            boardData.changeGameOver()
        }
        //playerButton.isEnabled = false
        playerButton.setTitle("\(boardData.getCurrentPlayer().rawValue) is current player", for: UIControl.State.disabled)
        //playerButton.backgroundColor = UIColor.white
        button.backgroundColor = UIColor.white
        //playerButton.titleLabel?.backgroundColor = UIColor.white
        button.titleLabel?.backgroundColor = UIColor.white
        return
    }
}


//make URL friendly versions of Strings of cities that are more than one word
private extension String {
    func makeURLFriendly() -> String {
        return self.components(separatedBy: .whitespaces).joined(separator: "%20")
    }
}


//define cases for connection messages to be sent between devices
extension ViewController : ConnectServiceDelegate {
    func connectChanged(manager: ConnectService, connectString: String) {
        OperationQueue.main.addOperation {
            switch connectString {
            case "0":
                self.moveAndUpdateUI(index: 0)
            case "1":
                self.moveAndUpdateUI(index: 1)
            case "2":
                self.moveAndUpdateUI(index: 2)
            case "3":
                self.moveAndUpdateUI(index: 3)
            case "4":
                self.moveAndUpdateUI(index: 4)
            case "5":
                self.moveAndUpdateUI(index: 5)
            case "6":
                self.moveAndUpdateUI(index: 6)
            case "reset":
                self.resetButtonPressed(button: self.resetButton)
            default:
                NSLog("%@", "Unknown connect value received: \(connectString)")
            }
        }
    }
    

    func connectedDevicesChanged(manager: ConnectService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectedLabel.text = "Connected to opponent!"
            self.connectedImage.image = UIImage(named: "checkmark")

            
            if (self.boardData.getCurrentPlayer() == Player.black) {
                self.boardData.changeCurrentPlayer()
                self.playerButton.setTitle("\(self.boardData.getCurrentPlayer().rawValue) is current player", for: UIControl.State.disabled)
            }
    }
    }
}

