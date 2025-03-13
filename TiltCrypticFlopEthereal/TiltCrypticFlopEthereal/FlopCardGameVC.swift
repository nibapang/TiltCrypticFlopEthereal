//
//  FlopCardGameVC.swift
//  TiltCrypticFlopEthereal
//
//  Created by SunTory on 2025/3/12.
//

struct Card {
    let rank: String
    let suit: String
    
    var isFaceCard: Bool {
        return ["K", "Q", "J"].contains(rank)
    }
    
    var numericValue: Int? {
        switch rank {
        case "A": return 1
        case "2": return 2
        case "3": return 3
        case "4": return 4
        case "5": return 5
        case "6": return 6
        case "7": return 7
        case "8": return 8
        case "9": return 9
        case "10": return 10
        default: return nil
        }
    }
    
    var imageName: String {
        return "\(rank)\(suit)"
    }
    
    static func generateDeck() -> [Card] {
        let suits = ["♠️", "♥️", "♦️", "♣️"]
        let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        
        return suits.flatMap { suit in
            ranks.map { rank in
                Card(rank: rank, suit: suit)
            }
        }
    }
}

import UIKit

class FlopCardGameVC: UIViewController {
    
    //MARK: - Declare IBOutlets
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var deckButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var cardImageView: UIImageView!

    //MARK: - Declare Variables
    var deck: [Card] = []
    var board: [Card?] = Array(repeating: nil, count: 16)
    var placedCards: [(card: Card, index: Int)] = []
    var selectedCards: [Int] = []
    var currentDraggedCard: Card?

    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    //MARK: - Functions
    func setupGame() {
        deck = Card.generateDeck()
        deck.shuffle()
        if let lastCard = deck.last {
            deckButton.setImage(UIImage(named: lastCard.imageName), for: .normal)
        }
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        boardCollectionView.dragInteractionEnabled = true
        boardCollectionView.reloadData()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        cardImageView.addGestureRecognizer(panGesture)
        cardImageView.isUserInteractionEnabled = true
    }
    

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)

        switch gesture.state {
        case .began:
            print("Drag started")
        case .changed:
            cardImageView.center = location
        case .ended:
            let pointInCollectionView = gesture.location(in: boardCollectionView)

            if let indexPath = boardCollectionView.indexPathForItem(at: pointInCollectionView),
               let card = currentDraggedCard,
               board[indexPath.item] == nil {
                let validIndexes = validIndexesForCard(card)
                if validIndexes.contains(indexPath.item) || card.numericValue != nil {
                    placeCard(card, at: indexPath.item)
                    cardImageView.image = nil
                    cardImageView.center = view.center
                    currentDraggedCard = nil
                    deckButton.isEnabled = true
                } else {
                    showAlert(title: "Invalid Move", message: "You can't place this card here.")
                    resetCardImageView()
                }
            } else {
                resetCardImageView()
            }
        default:
            break
        }
    }
    
    func resetCardImageView() {
        UIView.animate(withDuration: 0.3) {
            // Reset the image view position to its default center (original position)
            self.cardImageView.center = self.view.center
        }
    }
    
    func validIndexesForCard(_ card: Card) -> [Int] {
        switch card.rank {
        case "K":
            return [0, 3, 12, 15].filter { board[$0] == nil }
        case "Q":
            return [1, 2, 13, 14].filter { board[$0] == nil }
        case "J":
            return [4, 7, 8, 11].filter { board[$0] == nil }
        default:
            return Array(0..<board.count).filter { board[$0] == nil } // Other cards can be placed anywhere
        }
    }
    
    func placeCard(_ card: Card, at index: Int) {
        guard board[index] == nil else { return }

        board[index] = card
        placedCards.append((card, index))
        boardCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        deckButton.isEnabled = true
    }

    func enablePlacement(for card: Card) {
        let validIndexes = validIndexesForCard(card)

        for (index, slot) in board.enumerated() {
            if slot == nil, validIndexes.contains(index) {
                if let cell = boardCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                    cell.contentView.layer.borderWidth = 2
                    cell.contentView.layer.borderColor = UIColor.green.cgColor
                }
            } else {
                if let cell = boardCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                    cell.contentView.layer.borderWidth = 0
                    cell.contentView.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
    }


    func checkForLoss() {
        if board.allSatisfy({ $0 != nil }) {
            if !hasRemovablePairs() {
                showAlert(title: "Game Over", message: "No moves left!")
            }
        }
        
        if let topCard = deck.last {
            let validIndexes = validIndexesForCard(topCard)
            if validIndexes.isEmpty {
                showAlert(title: "Game Over", message: "No valid slots for the next card!")
            }
        }
    }


    func checkRemovals() {
        guard selectedCards.count == 2 else { return }

        let firstIndex = selectedCards[0]
        let secondIndex = selectedCards[1]

        guard let firstCard = board[firstIndex], let secondCard = board[secondIndex] else {
            selectedCards.removeAll()
            return
        }

        if let firstValueisTen = firstCard.numericValue, firstValueisTen == 10 {
            board[firstIndex] = nil
            selectedCards.removeAll()
            boardCollectionView.reloadData()
        } else if let firstValue = firstCard.numericValue, let secondValue = secondCard.numericValue, firstValue + secondValue == 10 {
            board[firstIndex] = nil
            board[secondIndex] = nil

            selectedCards.removeAll()
            boardCollectionView.reloadData()
        } else {
            showAlert(title: "Invalid Pair", message: "Selected cards do not sum to 10.")
            selectedCards.removeAll()
        }
    }

    func hasRemovablePairs() -> Bool {
        for i in 0..<board.count {
            for j in i+1..<board.count {
                if let card1 = board[i], let card2 = board[j],
                   let value1 = card1.numericValue, let value2 = card2.numericValue,
                   value1 + value2 == 10 {
                    return true
                }
            }
        }
        return false
    }
    

    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func drawCard(_ sender: UIButton) {
        // Check if the board is full
        if board.allSatisfy({ $0 != nil }) {
            showAlert(title: "Board Full", message: "No space available on the board!")
            return
        }

        guard let topCard = deck.popLast() else {
            showAlert(title: "Game Over", message: "No more cards in the deck!")
            return
        }
        currentDraggedCard = topCard
        cardImageView.image = UIImage(named: topCard.imageName)
        cardImageView.isUserInteractionEnabled = true
        deckButton.isEnabled = false

        if let nextCard = deck.last {
            deckButton.setImage(UIImage(named: nextCard.imageName), for: .normal)
        } else {
            deckButton.setImage(nil, for: .normal)
        }
    }


    
    @IBAction func undoAction(_ sender: UIButton) {
        guard let lastPlaced = placedCards.popLast() else {
            showAlert(title: "Undo Unavailable", message: "No more actions to undo!")
            return
        }
        board[lastPlaced.index] = nil
        deck.append(lastPlaced.card)
        deckButton.setImage(UIImage(named: lastPlaced.card.imageName), for: .normal)
        cardImageView.image = nil
        deckButton.isEnabled = true
        boardCollectionView.reloadItems(at: [IndexPath(item: lastPlaced.index, section: 0)])
    }

}

//MARK: - Datasource and Delegate Methods
extension FlopCardGameVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return board.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let card = board[indexPath.item]
        cell.configure(with: card)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCards.count < 2 {
            selectedCards.append(indexPath.item)
        }
        
        if selectedCards.count == 2 {
            checkRemovals()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 4 - 2, height: collectionView.frame.size.width / 4 - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let card = board[indexPath.item] else { return [] }
        let itemProvider = NSItemProvider(object: card.imageName as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = card
        return [dragItem]
    }
    



}

class CardCell: UICollectionViewCell {
    @IBOutlet weak var cardImageView: UIImageView!
    
    func configure(with card: Card?) {
        if let card = card {
            cardImageView.image = UIImage(named: card.imageName)
            print(card.imageName)
        } else {
            cardImageView.image = nil
        }
    }
}
