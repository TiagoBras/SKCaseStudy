//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class MapsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Maps"
        tableView.dataSource = tableViewDataSource
        tableView.rowHeight = 58
        tableView.tableFooterView = UIView()
    }

    lazy var tableViewDataSource: TableViewDataSourceDelegate = {
        return createTableViewDataSource()
    }()
    
    private func createTableViewDataSource() -> TableViewDataSourceDelegate {
        return TableViewDataSourceDelegate({ (table) in
            table.newSection({ (section) in
                section.newMapsRecordTableViewCell({ (cell) in
                    
                })
            })
        })
    }
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
}


extension MapsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = MapsSectionHeaderView(frame: .zero)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
