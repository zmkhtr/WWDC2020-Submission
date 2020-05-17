import UIKit
import Foundation
import PlaygroundSupport

class ViewController : UIViewController, PieceDelegate {
    
    let buttonRollTheDice: UIButton = {
        let button = UIButton()
        button.setTitle("Roll the Dice", for: .normal)
        button.frame = CGRect(x: 780,y: 1080,width: 200,height: 70)
        button.addTarget(self, action: #selector(rollDice), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.setTitleColor(.black, for: .normal)
        button.setImage(#imageLiteral(resourceName: "dice.png"), for: .normal)
        return button
    }()

    
    let labelDiceResult: UILabel = {
        let label = UILabel()
        label.text = "Move 0 row and 0 col"
        label.frame =  CGRect(x: 680,y: 1150,width: 300,height: 50)
        label.font = label.font.withSize(24)
        label.textAlignment = .right
        return label
    }()
    
    let playerTurnLabel: UILabel = {
        let label = UILabel()
        label.text = "Player One Turn"
        label.frame =  CGRect(x: 350,y: 1150,width: 1000,height: 200)
        label.font = label.font.withSize(40)
        label.textAlignment = .left
        return label
    }()
    
    let buttonStartReset: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.4666666666666667, green: 0.7647058823529411, blue: 0.26666666666666666, alpha: 1.0)
        button.frame =  CGRect(x: 350,y: 1100,width: 300,height: 50)
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        return button
    }()
    
    let labelGameTitle: UILabel = {
        let label = UILabel()
        label.text = "Covid-19 Dice Survivor"
        label.frame =  CGRect(x: 10,y: 5,width: 1000,height: 100)
        label.font = label.font.withSize(48)
        label.textAlignment = .center
        return label
    }()
    
    let labelImageSource: UILabel = {
        let label = UILabel()
        label.text = "All asset created by @daviabelinda, and the dice from flaticon.com - casino pack"
        label.frame =  CGRect(x: 100,y: 1280,width: 1000,height: 100)
        label.font = label.font.withSize(14)
        label.textAlignment = .center
        return label
    }()
    
    let buttonHowToplay: UIButton = {
        let button = UIButton()
        button.setTitle("How to Play?", for: .normal)
        button.frame = CGRect(x: 850,y: 20,width: 120,height: 50)
        button.addTarget(self, action: #selector(showHowToPlay), for: .touchUpInside)
        button.backgroundColor = UIColor.black
        return button
    }()
    
    let boardView: BoardView = {
        let view = BoardView()
        view.frame = CGRect(x: 10,y:100,width: 950,height: 950)
        view.backgroundColor = #colorLiteral(red: 0.803921568627451, green: 0.803921568627451, blue: 0.803921568627451, alpha: 1.0)
        return view
    }()
    
    let imageLegend: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "legend.png")
        image.frame = CGRect(x: 10,y: 1080,width: 300,height: 250)
        return image
    }()
    
    var pieceDelegate: PieceDelegate?
    var gameEngine = GameEngine()
    var isGameStart = false 
    var playerOne: Player?
    var playerTwo: Player?
    var virus: Player?
    
    var currentTurn : Player?
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.30980392156862746, green: 0.20392156862745098, blue: 0.0392156862745098, alpha: 1.0)
        self.view = view
        
        addView()
    }
    
    func addView(){
        labelDiceResult.isHidden = true
        buttonRollTheDice.isHidden = true
        playerTurnLabel.isHidden = true
        imageLegend.isHidden = true
        pieceDelegate = self
        
        view.addSubview(boardView)
        view.addSubview(labelImageSource)
        view.addSubview(buttonRollTheDice)
        view.addSubview(imageLegend)
        view.addSubview(labelDiceResult)
        view.addSubview(buttonStartReset)
        view.addSubview(labelGameTitle)
        view.addSubview(buttonHowToplay)
        view.addSubview(playerTurnLabel)
    }
    
    func movePiece(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int) {
        var rowIn = fromRow + -toRow
        var colIn = fromCol + toCol
        if(rowIn > 18) {
            rowIn = 18
        }
        if(rowIn < 0) {
            rowIn = 0
        }
        if(colIn > 18) {
            colIn = 18
        }
        if(colIn < 0) {
            colIn = 0
        }
        
        gameEngine.movePiece(fromCol: fromCol, fromRow: fromRow, toCol: colIn, toRow: rowIn)

        playerOne = gameEngine.playerOne
        playerTwo = gameEngine.playerTwo
        
        
        if (playerOne?.infected == true && playerTwo?.infected == true){
            playerTurnLabel.text = "YOU LOSE ! All Players get infected"
            playerTurnLabel.textColor = #colorLiteral(red: 0.807843137254902, green: 0.027450980392156862, blue: 0.3333333333333333, alpha: 1.0)
        } else if (playerOne?.turn == true && playerTwo?.turn == true) {
            playerTurnLabel.text = "YOU WIN ! All Players safe"
            playerTurnLabel.textColor = #colorLiteral(red: 0.3411764705882353, green: 0.6235294117647059, blue: 0.16862745098039217, alpha: 1.0)
        }
        
        virus = gameEngine.virus
        boardView.players = gameEngine.players
        boardView.setNeedsDisplay()
        
    }
    
    @objc func rollDice() {
        var diceRow = Int.random(in: -6...6)
        var diceCol = Int.random(in: -6...6)
        if (diceRow == 0){
            diceRow = 1
        }
        if (diceCol == 0){
            diceCol = 1
        }
        labelDiceResult.text = "Move \(diceCol) col \(diceRow) row"
        labelDiceResult.isHidden = false
        
        pieceDelegate?.movePiece(fromCol: virus!.col, fromRow: virus!.row, toCol: Int.random(in: -6...6), toRow: Int.random(in: -6...6))
        
        if (playerTurnLabel.text == "Player One Turn") {
            if (playerTwo?.turn == false){
                playerTurnLabel.text = "Player Two Turn"
                pieceDelegate?.movePiece(fromCol: playerOne!.col, fromRow: playerOne!.row, toCol:  diceCol, toRow: diceRow)
            }else {
                pieceDelegate?.movePiece(fromCol: playerOne!.col, fromRow: playerOne!.row, toCol:  diceCol, toRow: diceRow)
            }
        }else if (playerTurnLabel.text == "Player Two Turn"){
            if (playerOne?.turn == false){
                playerTurnLabel.text = "Player One Turn"
                pieceDelegate?.movePiece(fromCol: playerTwo!.col, fromRow: playerTwo!.row, toCol:  diceCol, toRow: diceRow)
            }else {
                pieceDelegate?.movePiece(fromCol: playerTwo!.col, fromRow: playerTwo!.row, toCol:  diceCol, toRow: diceRow)
            }
        }
        
        
    }
    
    @objc func showHowToPlay(){
        self.present(HowToPlayViewController(), animated: true, completion: nil)
    }
    
    @objc func startGame(){
        if (isGameStart == false){
            buttonRollTheDice.isHidden = false
            playerTurnLabel.isHidden = false
            imageLegend.isHidden = false
            gameEngine.initGame()
            playerOne = gameEngine.playerOne
            playerTwo = gameEngine.playerTwo
            virus = gameEngine.virus
            boardView.players = gameEngine.players
            boardView.pieceDelegate = self
            boardView.setNeedsDisplay()
            
            playerTurnLabel.text = "Player One Turn"
            currentTurn = playerOne
            
            isGameStart = true 
            
            buttonStartReset.setTitle("Reset", for: .normal)
            buttonStartReset.backgroundColor = #colorLiteral(red: 0.09019607843137255, green: 0.13333333333333333, blue: 0.0392156862745098, alpha: 1.0)
        } else if (isGameStart == true){
            gameEngine.initGame()
            playerTurnLabel.text = "Player One Turn"
            currentTurn = playerOne
            boardView.players = gameEngine.players
            boardView.pieceDelegate = self
            boardView.setNeedsDisplay()
        }
    }
}

class BoardView: UIView {
    var players = Set<Player>()
    var pieceDelegate: PieceDelegate?
    var fromCol = -1
    var fromRow = -1
    
    override func draw(_ rect: CGRect) {
        drawBoard()
        drawHealArea()
        drawWinArea()
        drawPlayerStartArea()
        drawVirusStartArea()
        drawPieces()
    }
    func drawPieces() {
        for player in players {
            let playerImage = UIImage(named: player.imageName)
            playerImage?.draw(in: CGRect(x: player.col * 50, y: player.row * 50, width: 50, height: 50))
        }
    }

    func drawBoard() {
        drawTwoRowsAt(y: 0 * 50)
        drawTwoRowsAt(y: 2 * 50)
        drawTwoRowsAt(y: 4 * 50)
        drawTwoRowsAt(y: 6 * 50)
        drawTwoRowsAt(y: 8 * 50)
        drawTwoRowsAt(y: 10 * 50)
        drawTwoRowsAt(y: 12 * 50)
        drawTwoRowsAt(y: 14 * 50)
        drawTwoRowsAt(y: 16 * 50)
        drawTwoRowsAt(y: 18 * 50)
    }
    
    func drawTwoRowsAt(y: CGFloat) {
        drawSquareAt(x: 1 * 50, y: y)
        drawSquareAt(x: 3 * 50, y: y)
        drawSquareAt(x: 5 * 50, y: y)
        drawSquareAt(x: 7 * 50, y: y)
        drawSquareAt(x: 9 * 50, y: y)
        drawSquareAt(x: 11 * 50, y: y)
        drawSquareAt(x: 13 * 50, y: y)
        drawSquareAt(x: 15 * 50, y: y)
        drawSquareAt(x: 17 * 50, y: y)
        drawSquareAt(x: 19 * 50, y: y)
        
        drawSquareAt(x: 0 * 50, y: y + 50)
        drawSquareAt(x: 2 * 50, y: y + 50)
        drawSquareAt(x: 4 * 50, y: y + 50)
        drawSquareAt(x: 6 * 50, y: y + 50)
        drawSquareAt(x: 8 * 50, y: y + 50)
        drawSquareAt(x: 10 * 50, y: y + 50)
        drawSquareAt(x: 12 * 50, y: y + 50)
        drawSquareAt(x: 14 * 50, y: y + 50)
        drawSquareAt(x: 16 * 50, y: y + 50)
        drawSquareAt(x: 18 * 50, y: y + 50)
    }
    
    func drawSquareAt(x: CGFloat, y: CGFloat) {
        let path = UIBezierPath(rect: CGRect(x: x, y: y, width: 50, height: 50))
        UIColor.lightGray.setFill()
        path.fill()
    }
    
    func drawHealArea(){
        let healPathOne = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
        UIColor.green.setFill()
        healPathOne.fill()
        let healPathTwo = UIBezierPath(rect: CGRect(x: 17 * 50, y: 17  * 50, width: 100, height: 100))
        UIColor.green.setFill()
        healPathTwo.fill()
        
        let iconOne = UIImage(named: "health_care.png")
        iconOne?.draw(in: CGRect(x: 0  * 50, y: 0 * 50, width: 50, height: 50))
        let iconTwo = UIImage(named: "health_care.png")
        iconTwo?.draw(in: CGRect(x: 18  * 50, y: 18  * 50, width: 50, height: 50))
    }
    
    func drawWinArea(){
        let winPath = UIBezierPath(rect: CGRect(x: 17 * 50, y: 0, width: 100, height: 100))
        UIColor.blue.setFill()
        winPath.fill()
        let icon = UIImage(named: "final_place.png")
        icon?.draw(in: CGRect(x: 18 * 50, y: 0 * 50, width: 50, height: 50))
    }
    
    func drawVirusStartArea(){
        let virusPath = UIBezierPath(rect: CGRect(x: 8 * 50, y: 400, width: 150, height:150))
        UIColor.red.setFill()
        virusPath.fill()
    }
    
    func drawPlayerStartArea(){
        let playerPath = UIBezierPath(rect: CGRect(x: 0 ,y: 17 * 50, width: 100, height: 100))
        UIColor.yellow.setFill()
        playerPath.fill()
        
        
        let icon = UIImage(named: "start_place.png")
        icon?.draw(in: CGRect(x: 0 * 50, y: 18 * 50, width: 50, height: 50))
    }
    
    
}

struct Player: Hashable {
    let id : Int
    var col: Int
    var row: Int
    let imageName: String
    let turn: Bool
    let infected : Bool
}

struct GameEngine {
    var players = Set<Player>()
    var virus : Player?
    var playerOne : Player?
    var playerTwo : Player?
    var playerOneWin = false
    var playerTwoWin = false
    
    mutating func initGame(){
        players.removeAll()
        players.insert(Player(id : 1, col: 0, row: 17, imageName: "player_one.png",turn : false, infected : false))
        
        players.insert(Player(id : 2, col: 9, row: 9, imageName: "virus.png",turn : false, infected : true))
        
        players.insert(Player(id : 3, col: 1, row: 17, imageName: "player2.png",turn : false, infected : false))
        
        for player in players {
            if player.id == 1 {
                playerOne = player
            }
            if player.id == 2 {
                virus = player
            }
            if player.id == 3 {
                playerTwo = player
            }
        }
    }
    
    mutating func movePiece(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int) {
        guard let movingPiece = playerAt(col: fromCol, row: fromRow) else {
            return
        }
        
        checkInfected(player : movingPiece,toCol :  toCol, toRow : toRow)
    }
    
    mutating func checkInfected(player : Player, toCol: Int, toRow: Int){
            if player.id == 2 {
                if (playerOne!.infected == false){
                if toCol == playerOne?.col && toRow == playerOne?.row {
                    players.remove(playerOne!)
                    playerOne = Player(id : playerOne!.id, col: playerOne!.col, row: playerOne!.row, imageName: "player_one_infected.png", turn : false, infected: true)
                    players.insert(playerOne!)
                    
                    players.remove(player)
                    virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                    players.insert(virus!)
                } else if toCol...toCol+1 ~= playerOne!.col && toRow...toRow+1 ~= playerOne!.row {
                    players.remove(playerOne!)
                    playerOne = Player(id : playerOne!.id, col: playerOne!.col, row: playerOne!.row, imageName: "player_one_infected.png", turn : false, infected: true)
                    players.insert(playerOne!)
                    
                    players.remove(player)
                    virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                    players.insert(virus!)
                }else if toCol-1...toCol+1 ~= playerOne!.col && toRow-1...toRow+1 ~= playerOne!.row {
                    players.remove(playerOne!)
                    playerOne = Player(id : playerOne!.id, col: playerOne!.col, row: playerOne!.row, imageName: "player_one_infected.png", turn : false, infected: true)
                    players.insert(playerOne!)
                    
                    players.remove(player)
                    virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                    players.insert(virus!)
                } else {
                    players.remove(player)
                    virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                    players.insert(virus!)
                }
                    
                }
                if (playerTwo!.infected == false){
                    if toCol == playerTwo?.col && toRow == playerTwo?.row {
                        players.remove(playerTwo!)
                        playerTwo = Player(id : playerTwo!.id, col: playerTwo!.col, row: playerTwo!.row, imageName:"player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                        
                        players.remove(player)
                        virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(virus!)
                    } else if toCol...toCol+1 ~= playerTwo!.col && toRow...toRow+1 ~= playerTwo!.row {
                        players.remove(playerTwo!)
                        playerTwo = Player(id : playerTwo!.id, col: playerTwo!.col, row: playerTwo!.row, imageName:"player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                        
                        players.remove(player)
                        virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(virus!)
                    }else if toCol-1...toCol+1 ~= playerTwo!.col && toRow-1...toRow+1 ~= playerTwo!.row {
                        players.remove(playerTwo!)
                        playerTwo = Player(id : playerTwo!.id, col: playerTwo!.col, row: playerTwo!.row, imageName:"player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                        
                        players.remove(player)
                        virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(virus!)
                    } else {
                        players.remove(player)
                        virus = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(virus!)
                    }
                }
        } else if player.id == 1 {
                if player.infected == true{
                    if 0...1 ~= toCol && 0...1 ~= toRow {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one.png", turn : false, infected: false)
                        players.insert(playerOne!)
                    } else if 17...18 ~= toCol && 17...18 ~= toRow {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one.png", turn : false, infected: false)
                        players.insert(playerOne!)
                    } else if playerTwo!.infected == false {
                        if toCol == playerTwo?.col && toRow == playerTwo?.row {
                            let playerIn = Player(id : playerTwo!.id, col: playerTwo!.col, row: playerTwo!.row, imageName:   "player2_infected.png" , turn : false, infected: true)
                            players.remove(playerTwo!)
                            players.insert(playerIn)
                            playerTwo = playerIn
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: "player_one_infected.png", turn : false, infected: true)
                            players.insert(playerOne!)
                        } else if toCol...toCol+1 ~= playerTwo!.col && toRow...toRow+1 ~= playerTwo!.row {
                            let playerIn = Player(id : playerTwo!.id, col: playerTwo!.col, row: playerTwo!.row, imageName:   "player2_infected.png" , turn : false, infected: true)
                            players.remove(playerTwo!)
                            players.insert(playerIn)
                            playerTwo = playerIn
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: "player_one_infected.png", turn : false, infected: true)
                            players.insert(playerOne!)
                        }else if toCol-1...toCol+1 ~= playerTwo!.col && toRow-1...toRow+1 ~= playerTwo!.row {
                            let playerIn = Player(id : playerTwo!.id, col: playerTwo!.col, row: playerTwo!.row, imageName:   "player2_infected.png" , turn : false, infected: true)
                            players.remove(playerTwo!)
                            players.insert(playerIn)
                            playerTwo = playerIn
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: "player_one_infected.png", turn : false, infected: true)
                            players.insert(playerOne!)
                        } else {
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                            players.insert(playerOne!)
                        }
                    } else {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(playerOne!)
                    }
                } else if player.infected == false {
                    if 17...18 ~= toCol && 0...1 ~= toRow {
                        if (playerTwoWin == true){
                            players.remove(virus!)
                        }
                        playerOneWin = true
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : true, infected: player.infected)
                        players.insert(playerOne!)
                    } else if toCol == virus?.col && toRow == virus?.row {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one_infected.png", turn : false, infected: true)
                        players.insert(playerOne!)
                    } else if toCol...toCol+1 ~= virus!.col && toRow...toRow+1 ~= virus!.row {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one_infected.png", turn : false, infected: true)
                        players.insert(playerOne!)
                    }else if toCol-1...toCol+1 ~= virus!.col && toRow-1...toRow+1 ~= virus!.row {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one_infected.png", turn : false, infected: true)
                        players.insert(playerOne!)
                    }  else if 8...10 ~= toCol && 8...10 ~= toRow {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one_infected.png", turn : false, infected: true)
                        players.insert(playerOne!)
                    } else if playerTwo!.infected == true {
                        if toCol == playerTwo?.col && toRow == playerTwo?.row {
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:   "player_one_infected.png", turn : false, infected: true)
                            players.insert(playerOne!)
                        } else if toCol...toCol+1 ~= playerTwo!.col && toRow...toRow+1 ~= playerTwo!.row {
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:  "player_one_infected.png", turn : false, infected: true)
                            players.insert(playerOne!)
                        }else if toCol-1...toCol+1 ~= playerTwo!.col && toRow-1...toRow+1 ~= playerTwo!.row {
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName:   "player_one_infected.png", turn : false, infected: true)
                            players.insert(playerOne!)
                        } else {
                            players.remove(player)
                            playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                            players.insert(playerOne!)
                        }
                    } else {
                        players.remove(player)
                        playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(playerOne!)
                    }
                }
            } else if player.id == 3 {
                if player.infected == true{
                    if 0...1 ~= toCol && 0...1 ~= toRow {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2.png", turn : false, infected: false)
                        players.insert(playerTwo!)
                    } else if 17...18 ~= toCol && 17...18 ~= toRow {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2.png", turn : false, infected: false)
                        players.insert(playerTwo!)
                    } else if playerOne!.infected == false {
                        if toCol == playerOne?.col && toRow == playerOne?.row {
                            let playerIn = Player(id : playerOne!.id, col: playerOne!.col, row: playerOne!.row, imageName: "player_one_infected.png", turn : false, infected: true)
                            players.remove(playerOne!)
                            players.insert(playerIn)
                            playerOne = playerIn
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                            players.insert(playerTwo!)
                        } else if toCol...toCol+1 ~= playerOne!.col && toRow...toRow+1 ~= playerOne!.row {
                            let playerIn = Player(id : playerOne!.id, col: playerOne!.col, row: playerOne!.row, imageName:   "player_one_infected.png", turn : false, infected: true)
                            players.remove(playerOne!)
                            players.insert(playerIn)
                            playerOne = playerIn
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                            players.insert(playerTwo!)
                        }else if toCol-1...toCol+1 ~= playerOne!.col && toRow-1...toRow+1 ~= playerOne!.row {
                            let playerIn = Player(id : playerOne!.id, col: playerOne!.col, row: playerOne!.row, imageName:   "player_one_infected.png", turn : false, infected: true)
                            players.remove(playerOne!)
                            players.insert(playerIn)
                            playerOne = playerIn
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                            players.insert(playerTwo!)
                        } else {
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                            players.insert(playerTwo!)
                        }
                    } else {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(playerTwo!)
                    }
                } else if player.infected == false {
                    if 17...18 ~= toCol && 0...1 ~= toRow {
                        if (playerOneWin == true){
                            players.remove(virus!)
                        }
                        playerTwoWin = true
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : true, infected: player.infected)
                        players.insert(playerTwo!)
                    } else if toCol == virus?.col && toRow == virus?.row {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                    } else if toCol...toCol+1 ~= virus!.col && toRow...toRow+1 ~= virus!.row {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                    }else if toCol-1...toCol+1 ~= virus!.col && toRow-1...toRow+1 ~= virus!.row {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                    }  else if 8...10 ~= toCol && 8...10 ~= toRow {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                        players.insert(playerTwo!)
                    } else if playerOne!.infected == true {
                        if toCol == playerOne?.col && toRow == playerOne?.row {
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                            players.insert(playerTwo!)
                        } else if toCol...toCol+1 ~= playerOne!.col && toRow...toRow+1 ~= playerOne!.row {
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                            players.insert(playerTwo!)
                        }else if toCol-1...toCol+1 ~= playerOne!.col && toRow-1...toRow+1 ~= playerOne!.row {
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName:  "player2_infected.png", turn : false, infected: true)
                            players.insert(playerTwo!)
                        } else {
                            players.remove(player)
                            playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                            players.insert(playerTwo!)
                        }
                    } else {
                        players.remove(player)
                        playerTwo = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                        players.insert(playerTwo!)
                    } 
                } 
            } else {
                players.remove(player)
                playerOne = Player(id : player.id, col: toCol, row: toRow, imageName: player.imageName, turn : false, infected: player.infected)
                players.insert(playerOne!)
        }
        }
    
    func playerAt(col: Int, row: Int) -> Player? {
        for player in players {
            if player.col == col && player.row == row {
                return player
            }
        }
        return nil
    }
}

protocol PieceDelegate {
    func movePiece(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int)
}

class HowToPlayViewController : ViewController {
    
    let buttonBack: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.frame = CGRect(x: 5,y: 0,width: 100,height: 100)
        return button
    }()
    
    let imageHowToPlay: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "howtoplay.png")
        image.frame = CGRect(x: 10,y: 100,width: 700,height: 850)
        return image
    }()
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .brown
        self.view = view
        
        buttonBack.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        view.addSubview(buttonBack)
        view.addSubview(imageHowToPlay)
    }
    
    @objc private func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


PlaygroundPage.current.liveView = ViewController()


