//
//  FlopFlopHowtoPlayVC.swift
//  TiltCrypticFlopEthereal
//
//  Created by SunTory on 2025/3/12.
//

struct HowToPlaySection {
    let title: String
    let description: String
}


import UIKit

class FlopHowtoPlayVC: UIViewController {
    
    //MARK: - Declare IBOutlets
    @IBOutlet weak var tblViewHTP: UITableView!
    
    
    //MARK: - Declare Variables
    let howToPlayData: [HowToPlaySection] = [
        HowToPlaySection(title: "Objective", description: "The goal of the game is to place cards on the board strategically and remove pairs of cards that sum up to 10. You lose if:\n1. The board is full, and there are no more removable pairs.\n2. The top card in the deck cannot be placed anywhere."),
        HowToPlaySection(title: "Gameplay", description: """
        1. Tap the "Draw" button to reveal the next card.
        2. Drag the revealed card to a valid slot on the board:
           - Face Cards (K, Q, J): Can only be placed in specific slots.
           - Number Cards: Can be placed anywhere.
        3. Tap two cards to remove them if they sum to 10.
        4. Use "Undo" to recover from mistakes.
        """),
        HowToPlaySection(title: "Winning and Losing", description: """
        - Win: Successfully play all cards and remove pairs.
        - Lose:
          1. No valid moves for the top deck card.
          2. The board is full, and no removable pairs are available.
        """),
        HowToPlaySection(title: "Tips", description: """
        - Plan placements carefully.
        - Keep track of potential pairs.
        - Use the Undo feature to fix mistakes.
        """)
    ]
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    //MARK: - Functions
    func setUpTableView() {
        self.tblViewHTP.dataSource = self
        self.tblViewHTP.delegate = self
        self.tblViewHTP.register(UINib(nibName: "FlopHowtoPlayTVCCell", bundle: nil), forCellReuseIdentifier: "FlopHowtoPlayTVCCell")
    }
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Datasource and Delegate Methods
extension FlopHowtoPlayVC : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return howToPlayData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "appColor_white")
        
        // Create a label for the section header
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50)
        headerLabel.font = UIFont(name: "STIX Two Text SemiBold", size: 24)
        headerLabel.text = howToPlayData[section].title
        headerLabel.textColor = UIColor(named: "appColor_black")  // Set text color
        headerLabel.textAlignment = .center  // Align text
        
        // Add the label to the header view
        headerView.addSubview(headerLabel)
        
        return headerView
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FlopHowtoPlayTVCCell", for: indexPath) as? FlopHowtoPlayTVCCell else { return UITableViewCell() }
        cell.lblDesc.text = howToPlayData[indexPath.section].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

