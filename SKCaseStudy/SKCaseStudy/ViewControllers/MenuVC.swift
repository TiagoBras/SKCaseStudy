//
//  MenuVC.swift
//  SKCaseStudy
//
//  Created by Tiago Bras on 21/04/2018.
//  Copyright © 2018 Tiago Bras. All rights reserved.
//

import UIKit
import SafariServices

class MenuVC: UIViewController {
    enum Tags: Int {
        case testDefinitions = 1000, privacyPolicy, dataCap, samLetter, whiteBox
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Menu"
        
        tableView.rowHeight = 59
        tableView.tableFooterView = UIView()
//        tableView.register(ClassicTableViewCell.nib,
//                           forCellReuseIdentifier: ClassicTableViewCell.className)
//        tableView.register(CenteredTextTableViewCell.nib,
//                           forCellReuseIdentifier: CenteredTextTableViewCell.className)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Private Fields
    private var version: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "v\(version)"
        } else {
            log.warning("Could not retrieve app version")
            return "Unknow"
        }
    }
    
    private var build: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "b\(build)"
        } else {
            log.warning("Could not retrieve app build")
            return "Unknow"
        }
    }
    
    // Code completion doesn't work inside closures of lazy fields
    private func createTableViewDataSource() -> TableViewDataSourceDelegate {
        let dataSource = TableViewDataSourceDelegate({ (table) in
            table.newSection({ (section) in
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Test definitions"
                    cell.image = UIImage(named: "menu_test_definitions")
                    cell.disclosureImage = UIImage(named: "selectDisclosure")
                    cell.tag = Tags.testDefinitions.rawValue
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Letters from Sam"
                    cell.image = UIImage(named: "menu_letter")
                    cell.disclosureImage = UIImage(named: "selectDisclosure")
                    cell.tag = Tags.samLetter.rawValue
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Whitebox information"
                    cell.image = UIImage(named: "menu_whitebox")
                    cell.disclosureImage = UIImage(named: "selectDisclosure")
                    cell.tag = Tags.whiteBox.rawValue
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Privacy policy"
                    cell.image = UIImage(named: "menu_privacy")
                    cell.tag = Tags.privacyPolicy.rawValue
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Monthly data limit notification"
                    cell.image = UIImage(named: "menu_data_limit")
                    cell.tag = Tags.dataCap.rawValue
                })
                
                section.newCenteredTextTableViewCell({ (cell) in
                    cell.text = "\(version) \(build)"
                    cell.selectionStyle = .none
                    
                    cell.setOnCellWillDisplay({ (_, tableCell, _, _) in
                        tableCell.contentView.backgroundColor = UIColor(red: 0.216,
                                                                        green: 0.310,
                                                                        blue: 0.380,
                                                                        alpha: 1.00)
                    })
                })
            })
        })
        
        return dataSource
    }
    
    private lazy var tableViewDataSource: TableViewDataSourceDelegate = {
        return createTableViewDataSource()
    }()
}

extension MenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tag = tableViewDataSource.sections[indexPath.section].visibleCells[indexPath.row].tag
    
        if tag == Tags.testDefinitions.rawValue {
            let vc = TestDefinitionsVC(nibName: TestDefinitionsVC.className, bundle: nil)
            
            navigationController?.pushViewController(vc, animated: true)
        } else  if tag == Tags.samLetter.rawValue {
            let vc = LetterFromSamVC(nibName: LetterFromSamVC.className, bundle: nil)
            
            navigationController?.pushViewController(vc, animated: true)
        } else if tag == Tags.whiteBox.rawValue {
            let vc = WhiteBoxVC(nibName: WhiteBoxVC.className, bundle: nil)
            
            navigationController?.pushViewController(vc, animated: true)
        } else if tag == Tags.privacyPolicy.rawValue {
            guard let url = URL(string: "https://www.samknows.com/legal/privacy-policy") else { return }
            
            let config = SFSafariViewController.Configuration()
            
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.modalPresentationStyle = .overFullScreen

            if #available(iOS 10.0, *) {
                vc.preferredBarTintColor =  Color.safariTintColor
                vc.preferredControlTintColor = .white
            } else {
                vc.view.tintColor = Color.safariTintColor
            }

            present(vc, animated: true, completion: nil)
        } else if tag == Tags.dataCap.rawValue {
            let vc = CellularDataCapVC(nibName: CellularDataCapVC.className, bundle: nil)

            present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        }
    }
}
