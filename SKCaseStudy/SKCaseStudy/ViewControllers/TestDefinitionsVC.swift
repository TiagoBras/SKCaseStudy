//
//  TestDefinitionsVC.swift
//  SKCaseStudy
//
//  Created by Tiago Bras on 20/05/2018.
//  Copyright © 2018 Tiago Bras. All rights reserved.
//

import UIKit

class TestDefinitionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataSource()
        
        tableView.register(TestDefinitionTableViewCell.nib,
                           forCellReuseIdentifier: TestDefinitionTableViewCell.className)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableHeaderView = tableHeaderView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadDataSource() {
        guard let url = Bundle.main.url(forResource: "test_definitions", withExtension: "json") else {
            log.error("test_definitions.json not found")
            return
        }
        
        do {
            guard let data = try String(contentsOf: url, encoding: .utf8).data(using: .utf8) else {
                log.error("could not enconde contents of test_definitions.json")
                return
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] else {
                log.error("could not decode contents of test_definitions.json")
                return
            }
            
            dataSource = json
        } catch {
            log.error(error)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TestDefinitionTableViewCell.className,
                                                       for: indexPath) as! TestDefinitionTableViewCell
        
        cell.titleLabel.text = dataSource[indexPath.row]["title"]
        cell.descriptionTextView.text = dataSource[indexPath.row]["text"]
        
        if let imageName = dataSource[indexPath.row]["icon"] {
            cell.iconImageView.image = UIImage(named: imageName)
        }
        cell.descriptionTextView.sizeToFit()
        cell.selectionStyle = .none
        
        return cell
    }
    

    private lazy var tableHeaderView: UITableViewHeaderFooterView = {
        let header = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0,
                                                             width: view.bounds.width,
                                                             height: 137+60))
        
        let imageView = UIImageView(image: UIImage(named: "dataCap"))
        header.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 137).isActive = true
        
        let title = UILabel(frame: .zero)
        title.font = UIFont.boldSystemFont(ofSize: 26)
        title.text = "Test Definition"
        title.textColor = Color.mainTextColor
        header.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20).isActive = true
        title.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        title.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return header
    }()
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return titleHeaderView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
}
