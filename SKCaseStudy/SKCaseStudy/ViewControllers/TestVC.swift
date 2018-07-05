//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit
import SystemConfiguration.CaptiveNetwork

import Designables

class TestVC: UIViewController {
    private var headerView = UIView()
    private var footerView = UIView()

    fileprivate enum CellTags: Int {
        case selectDisclosure = 648213
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Test your internet"

        tableView.backgroundColor = Color.darkMainCalor
        tableView.rowHeight = 59
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
//        tableView.register(ClassicTableViewCell.nib,
//                           forCellReuseIdentifier: ClassicTableViewCellData.reuseIdentifier)
//        tableView.register(ToggleButtonTableViewCellData.nib(),
//                           forCellReuseIdentifier: ToggleButtonTableViewCellData.reuseIdentifier)
        
        tableView.dataSourceDelegate = tableViewDataSource
        tableView.tableFooterView = MascotMessage.newFromNib()
        tableView.tableFooterView?.frame.size.height = 250
        
        headerView.backgroundColor = UIColor(red: 0.216, green: 0.310, blue: 0.380, alpha: 1.00)
        headerView.frame = CGRect(x: 0, y: tableView.frame.origin.y, width: tableView.bounds.width, height: 0)
        view.addSubview(headerView)
        
        footerView.backgroundColor = UIColor.white
        footerView.frame = CGRect(x: 0, y: tableView.frame.origin.y + tableView.bounds.height, width: tableView.bounds.width, height: 0)
        view.addSubview(footerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
    }
    
    // URL: https://forums.developer.apple.com/thread/50302
    func fetchSSIDInfo() ->  String? {
        if let interfaces = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                
                if let unsafeInterfaceData = unsafeInterfaceData as? Dictionary<AnyHashable, Any> {
                    return unsafeInterfaceData["SSID"] as? String
                }
            }
        }
        return nil
    }

    // Code completion doesn't work inside closures of lazy fields
    private func createTableViewDataSource() -> TableViewDataSourceDelegate {
        let dataSource = TableViewDataSourceDelegate({ (table) in
            table.newSection({ (section) in
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Test server"
                    cell.rightText = "London, GB"
                    cell.image = UIImage(named: "testServer")
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Service provider"
                    cell.rightText = "MEO"
                    cell.image = UIImage(named: "serviceProvider")
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Wi-Fi"
                    cell.rightText = fetchSSIDInfo()
                    cell.image = UIImage(named: "wifi")
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Device"
                    cell.rightText = UIDevice.current.name
                    cell.image = UIImage(named: "device")
                })
                
                section.newClassicTableViewCell({ (cell) in
                    cell.leftText = "Test to run"
                    cell.rightText = "Select"
                    cell.image = UIImage(named: "testsCounter")
                    cell.disclosureImage = UIImage(named: "selectDisclosure")
                    cell.tag = CellTags.selectDisclosure.rawValue
                    
                    cell.setOnCellWillDisplay({ [weak self] (_, _, _, data) in
                        guard let cellData = data as? ClassicTableViewCellData else { return }
                        guard let dataSource = self?.tableViewDataSource else { return }
                        guard dataSource.sections.count >= 2 else { return }
                        
                        if !dataSource.sections[1].isHidden {
                            cellData.rightText = "Close"
                            cellData.disclosureImage = UIImage(named: "closeDisclosure")
                        } else {
                            cellData.rightText = "Select"
                            cellData.disclosureImage = UIImage(named: "selectDisclosure")
                        }
                    })
                })
            })
            
            table.newSection({ (section) in
                section.isHidden = true
                
                let optionalTests: [TestType] = [.download, .upload, .latency, .youtube, .webBrowsing]
                
                for test in optionalTests {
                    section.newToggleButtonTableViewCell({ (cell) in
                        cell.image = test.bigIcon
                        cell.text = test.name
                        cell.tag = test.hashValue
                        
                        cell.onToggleButtonValueChanged = { (data) in
                            UserDefaults.standard.setShouldInclude(test: test, value: data.isSelected)
                        }
                    })
                }
            })
        })
        
        return dataSource
    }
    
    private lazy var tableViewDataSource: TableViewDataSourceDelegate = {
        return createTableViewDataSource()
    }()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update header view height so it covers the area between navigation bar and first cell
        let height = -scrollView.contentOffset.y
        
        if height >= 0 {
            headerView.frame.size.height = height
        }
        
        let footerHeight = -(scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height)
        
        if footerHeight >= 0 {
            footerView.frame = CGRect(x: 0,
                                      y: tableView.frame.origin.y + tableView.bounds.height - footerHeight,
                                      width: tableView.bounds.width,
                                      height: footerHeight)
        }
        
        log.info(footerHeight)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(x: 0, y: tableView.frame.origin.y, width: tableView.bounds.width, height: 0)
        footerView.frame = CGRect(x: 0, y: tableView.frame.origin.y + tableView.bounds.height, width: tableView.bounds.width, height: 0)
    }
}

extension TestVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellData = tableViewDataSource.sections[indexPath.section].cells[indexPath.row]
        
        if indexPath.section == 0 {
            if cell.tag == CellTags.selectDisclosure.rawValue {
                guard let cell = cell as? ClassicTableViewCell else { return }
                guard let classicalCellData = cellData as? ClassicTableViewCellData else { return }
                
                tableView.beginUpdates()
                let bg = view.backgroundColor
                tableView.backgroundColor = cell.backgroundColor

                if tableViewDataSource.sections[1].isHidden {
                    tableViewDataSource.sections[1].isHidden = false
                    tableView.insertSections(IndexSet(integer: 1), with: .top)
                } else {
                    tableViewDataSource.sections[1].isHidden = true
                    tableView.deleteSections(IndexSet(integer: 1), with: .top)
                }
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.tableView.backgroundColor = bg
                }
                
                
                print(tableView.numberOfSections)
            }
        } else if indexPath.section == 1 {
            if let index = TestType.allCases.index(where: { $0.hashValue == cell.tag }) {
                if let toggleData = cellData as? ToggleButtonTableViewCellData {
                    toggleData.isSelected.toggle()
                    
                    // Update user defaults
                    UserDefaults.standard.setShouldInclude(test: TestType.allCases[index],
                                                           value: toggleData.isSelected)
                }
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSection = tableView.numberOfSections - 1
        
        guard lastSection >= 0 else { return }
        
        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
        let showSeparator = lastSection == indexPath.section && lastRow == indexPath.row
        
        var separator = cell.viewWithTag(1234)
        
        if separator == nil {
            separator = UIView()
            separator?.backgroundColor = tableView.separatorColor
            cell.contentView.addSubview(separator!)
            
            separator?.translatesAutoresizingMaskIntoConstraints = false
            separator?.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            separator?.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            separator?.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            separator?.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        }
        
        separator?.isHidden = !showSeparator
    }
}
