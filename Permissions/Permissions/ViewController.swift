//
//  ViewController.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 25/06/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    enum CellType: Int, CaseIterable  {
        case notification = 0
        case photoLibrary
        case biometric
        
        func toString() -> String {
            switch self {
            case .biometric:
                return "Biometry"
            case .photoLibrary:
                return "Photo Library"
            case .notification:
                return "Notification"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Permissions"
        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == CellType.biometric.rawValue {
            let vc = BiometricViewController.fromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        } else {}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = CellType.allCases[indexPath.row].toString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allCases.count
    }
}
