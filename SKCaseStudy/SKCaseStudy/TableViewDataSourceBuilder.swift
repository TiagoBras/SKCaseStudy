//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

enum HandlerResult {
    case notHandled, handled
}

typealias CellWillDisplayHandler = (UITableView, UITableViewCell, IndexPath, TableViewCellData) -> ()
typealias DidSelectCellHandler = (UITableView, UITableViewCell, IndexPath, TableViewCellData) -> HandlerResult

class TableViewCellData {
    class var reuseIdentifier: String { return String(describing: self) }
    class func nib() -> UINib? { return nil }
    var isHidden: Bool = false
    var tag: Int = -1
    var selectionStyle: UITableViewCellSelectionStyle = .default
    fileprivate var onCellWillDisplay: CellWillDisplayHandler?
    fileprivate var onDidSelectCell: DidSelectCellHandler?

    func setOnCellWillDisplay(_ handler: CellWillDisplayHandler?) {
        onCellWillDisplay = handler
    }
    
    func setOnDidSelectCell(_ handler: DidSelectCellHandler?) {
        onDidSelectCell = handler
    }
    
    private(set) weak var parentSection: TableViewSectionData?
    fileprivate init(parentSection: TableViewSectionData?) {
        self.parentSection = parentSection
        
        log.debug("Registering cell with identifier: \(type(of: self).reuseIdentifier)")
    }
}

final class UITableViewCellData: TableViewCellData {
    var accessoryView: UIView?
    var image: UIImage?
    var text: String?
    
    init(parentSection: TableViewSectionData?,  build: (UITableViewCellData) -> ()) {
        super.init(parentSection: parentSection)
        build(self)
    }
}

final class ClassicTableViewCellData: TableViewCellData {
    override class func nib() -> UINib? { return ClassicTableViewCell.nib }
    
    var image: UIImage?
    var leftText: String?
    var rightText: String?
    var disclosureImage: UIImage?
    var accessoryView: UIView?
    var backgroundColor: UIColor?
    
    init(parentSection: TableViewSectionData?,  build: (ClassicTableViewCellData) -> ()) {
        super.init(parentSection: parentSection)
        build(self)
    }
}

final class ToggleButtonTableViewCellData: TableViewCellData {
    override class func nib() -> UINib? { return ClassicTableViewCell.nib }
    
    var image: UIImage?
    var text: String?
    var isSelected: Bool = true
    var onToggleButtonValueChanged: ((ToggleButtonTableViewCellData) -> ())?
    
    init(parentSection: TableViewSectionData?,  build: (ToggleButtonTableViewCellData) -> ()) {
        super.init(parentSection: parentSection)
        build(self)
    }
}

//class DetailTableViewCellData: TableViewCellData {
//    static let reuseIdentifier: String = "DetailTableViewCellData"
//    static let nib: UINib? = ClassicTableViewCell.nib
//    var isHidden: Bool = false
//    var tag: Int = -1
//    var selectionStyle: UITableViewCellSelectionStyle = .default
//    var onCellWillDisplay: ((UITableViewCell, TableViewCellData) -> ())?
//    var onDidSelectCell: ((UITableViewCell, TableViewCellData) -> ())?
//
//    var leftLabel: String?
//    var rightLabel: String?
//    var image: String?
//
//
//    fileprivate init() { }
//    init(_ build: (DetailTableViewCellData) -> ()) { }
//}

final class CenteredTextTableViewCellData: TableViewCellData {
    override class func nib() -> UINib? { return CenteredTextTableViewCell.nib }

    var text: String?
    
    init(parentSection: TableViewSectionData?,  build: (CenteredTextTableViewCellData) -> ()) {
        super.init(parentSection: parentSection)
        build(self)
    }
}

final class MapsRecordTableViewCellData: TableViewCellData {
    override class func nib() -> UINib? { return MapsRecordTableViewCell.nib }
    
    var testId: String?
    var date: Date?
    var downloadSpeed: Double?
    var uploadSpeed: Double?
    var latency: Double?

    init(parentSection: TableViewSectionData?,  build: (MapsRecordTableViewCellData) -> ()) {
        super.init(parentSection: parentSection)
        build(self)
    }
}

final class TestDefinitionTableViewCellData: TableViewCellData {
    override class func nib() -> UINib? { return TestDefinitionTableViewCell.nib }

    var icon: UIImage?
    var title: String?
    var description: String?

    init(parentSection: TableViewSectionData?,  build: (TestDefinitionTableViewCellData) -> ()) {
        super.init(parentSection: parentSection)
        build(self)
    }
}

final class TableViewSectionData {
    var tag: Int
    var cells: [TableViewCellData] = []
    var isHidden: Bool = false
    weak var dataSourceDelegate: TableViewDataSourceDelegate?
    
    convenience init(build: (TableViewSectionData) -> ()) {
        self.init(tag: -1, build: build)
    }
    
    init(tag: Int, build: (TableViewSectionData) -> ()) {
        self.tag = tag
        build(self)
    }
    
    func newTableViewCell(_ build: (UITableViewCellData) -> ()) {
        cells.append(UITableViewCellData(parentSection: self, build: build))
    }
    
    func newClassicTableViewCell(_ build: (ClassicTableViewCellData) -> ()) {
        cells.append(ClassicTableViewCellData(parentSection: self, build: build))
    }
    
//    func newDetailTableViewCell(_ build: (DetailTableViewCellData) -> ()) {
//        let cell = DetailTableViewCellData()
//        build(cell)
//        cells.append(cell)
//    }
    
    func newToggleButtonTableViewCell(_ build: (ToggleButtonTableViewCellData) -> ()) {
        cells.append(ToggleButtonTableViewCellData(parentSection: self, build: build))
    }
    
    func newCenteredTextTableViewCell(_ build: (CenteredTextTableViewCellData) -> ()) {
        cells.append(CenteredTextTableViewCellData(parentSection: self, build: build))
    }
    
    func newMapsRecordTableViewCell(_ build: (MapsRecordTableViewCellData) -> ()) {
        cells.append(MapsRecordTableViewCellData(parentSection: self, build: build))
    }
    
    func newTestDefinitionTableViewCell(_ build: (TestDefinitionTableViewCellData) -> ()) {
        cells.append(TestDefinitionTableViewCellData(parentSection: self, build: build))
    }
    
    var visibleCells: [TableViewCellData] {
        return cells.filter({ !$0.isHidden })
    }
}

final class TableViewDataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    fileprivate var onCellWillDisplay: CellWillDisplayHandler?
    fileprivate var onDidSelectCell: DidSelectCellHandler?
    
    func setOnCellWillDisplay(_ handler: CellWillDisplayHandler?) {
        onCellWillDisplay = handler
    }
    
    func setOnDidSelectCell(_ handler: DidSelectCellHandler?) {
        onDidSelectCell = handler
    }
    
    var sections: [TableViewSectionData] = []
    var visibleSections: [TableViewSectionData] {
        return sections.filter({ !$0.isHidden })
    }
    
    func newSection(tag: Int, _ build: (TableViewSectionData) -> ()) {
        sections.append(TableViewSectionData(tag: tag, build: build))
    }
    
    func newSection(_ build: (TableViewSectionData) -> ()) {
        newSection(tag: -1, build)
    }
    
    func sectionData(withTag tag: Int) -> TableViewSectionData? {
        return sections.first(where: { $0.tag == tag })
    }
    
    func cellData(withTag tag: Int) -> TableViewCellData? {
        for section in sections {
            if let cellData = section.cells.first(where: { $0.tag == tag }) {
                return cellData
            }
        }
        
        return nil
    }
    
    private var areCellsRegistered = false
    init(_ build: (TableViewDataSourceDelegate) -> ()) {
        super.init()
        
        build(self)
    }
    
    // MARK:- UITablieViewDataSource
    @available(iOS 2.0, *)
    func numberOfSections(in tableView: UITableView) -> Int {
        func registerCellsIfNeeded(tableView: UITableView) {
            if !areCellsRegistered {
                var registeredCells = Set<String>()
                
                for section in sections {
                    for cell in section.cells {
                        let cellType = type(of: cell)
                        
                        if !registeredCells.contains(cellType.reuseIdentifier) {
                            if let nib = cellType.nib() {
                                tableView.register(nib, forCellReuseIdentifier: cellType.reuseIdentifier)
                            } else {
                                tableView.register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
                            }
                            
                            registeredCells.insert(cellType.reuseIdentifier)
                        }
                    }
                }
                
                areCellsRegistered = true
            }
        }
        
        registerCellsIfNeeded(tableView: tableView)
        
        return visibleSections.count
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].visibleCells.count
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = visibleSections[indexPath.section].visibleCells[indexPath.row]
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: cellData).reuseIdentifier,
                                                 for: indexPath)
        
        cell.selectionStyle = cellData.selectionStyle
        cell.tag = cellData.tag
        
        if let classicCell = cell as? ClassicTableViewCell {
            if let data = cellData as? ClassicTableViewCellData {
                setupClassicTableViewCell(cell: classicCell, data: data)
            } else  if let data = cellData as? ToggleButtonTableViewCellData {
                setupToggleButtonTableViewCell(cell: classicCell, data: data)
            }
        } else if let centeredTextCell = cell as? CenteredTextTableViewCell {
            setupCenteredTextTableViewCell(cell: centeredTextCell, data: cellData)
        } else if let mapsCell = cell as? MapsRecordTableViewCell {
            setupMapsRecordTableViewCell(cell: mapsCell, data: cellData)
        } else {
            setupUITableViewCell(cell: cell, data: cellData)
        }

        return cell
    }
    
    // MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellData = visibleSections[indexPath.section].visibleCells[indexPath.row]
        
        cellData.onCellWillDisplay?(tableView, cell, indexPath, cellData)
        
        onCellWillDisplay?(tableView, cell, indexPath, cellData)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellData = visibleSections[indexPath.section].visibleCells[indexPath.row]
        
        if let result = cellData.onDidSelectCell?(tableView, cell, indexPath, cellData), result == .handled {
            // Event handled
        } else {
            _ = onDidSelectCell?(tableView, cell, indexPath, cellData)
        }
    }
    
    // MARK:- Private Methods
    private func setupClassicTableViewCell(cell: ClassicTableViewCell, data: ClassicTableViewCellData) {
        cell.leftImageView.image = data.image
        cell.leftLabel.text = data.leftText
        cell.rightLabel.text = data.rightText
        cell.accessoryImageView.image = data.disclosureImage
        cell.accessoryView = data.accessoryView
        cell.backgroundColor = data.backgroundColor ?? Color.mainColor
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        guard let cell = sender.superview as? ClassicTableViewCell else { return }
        guard let toggleData = cell.associatedValue as? ToggleButtonTableViewCellData else { return }
        
        toggleData.isSelected.toggle()
        toggleData.onToggleButtonValueChanged?(toggleData)
    }
    
    private func setupToggleButtonTableViewCell(cell: ClassicTableViewCell, data: ToggleButtonTableViewCellData) {
        cell.leftLabel.text = data.text
        cell.imageView?.image = data.image
        cell.backgroundColor = Color.darkMainCalor
        cell.associatedValue = data
        
        if cell.accessoryView == nil {
            let toggleSwitch = UISwitch(frame: .zero)
            toggleSwitch.layer.cornerRadius = 16
            toggleSwitch.backgroundColor = Color.disabledColor
            toggleSwitch.tintColor = Color.disabledColor
            toggleSwitch.onTintColor = Color.enabledButtonColor
            toggleSwitch.thumbTintColor = Color.darkMainCalor
            toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)

            cell.accessoryView = toggleSwitch
        }
        
        (cell.accessoryView as! UISwitch).isOn = data.isSelected
    }
    
    private func setupCenteredTextTableViewCell(cell: CenteredTextTableViewCell, data: TableViewCellData) {
        guard let data = data as? CenteredTextTableViewCellData else {
            log.warning("Data should be of type: 'CenteredTextTableViewCellData'")
            return
        }
        
        cell.centeredTextLabel.text = data.text
    }
    
    private func setupMapsRecordTableViewCell(cell: MapsRecordTableViewCell,
                                              data: TableViewCellData) {
        guard let data = data as? MapsRecordTableViewCellData else {
            log.warning("Data should be of type: 'MapsRecordTableViewCellData'")
            return
        }
        
        // TODO: complete
    }
    
    private func setupUITableViewCell(cell: UITableViewCell, data: TableViewCellData) {
        guard let data = data as? UITableViewCellData else {
            log.warning("Data should be of type: 'ClassicTableViewCellData'")
            return
        }
        
        cell.backgroundColor = Color.darkMainCalor
        cell.textLabel?.text = data.text
        cell.imageView?.image = data.image
        cell.accessoryView = data.accessoryView
    }
    
    // MARK:- Ignore
    // TODO: implement a way to override this
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @available(iOS 2.0, *)
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    // Data manipulation - insert and delete support
    
    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
    // Data manipulation - reorder / moving support
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}

extension UITableView {
    weak var dataSourceDelegate: TableViewDataSourceDelegate? {
        set {
            dataSource = newValue
            delegate = newValue
        }
        get {
            if let dataSource = self.dataSource as? TableViewDataSourceDelegate {
                return dataSource
            }
            
            return nil
        }
    }
}
