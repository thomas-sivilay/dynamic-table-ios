import UIKit
import PlaygroundSupport
import SnapKit

typealias JSON = [String: Any]

let style: JSON = [
    "text":
        ["size": 16],
    "title":
        ["size": 24]
]

let json: [JSON] = [
    ["title":
        ["data": "Hello!",
         "style":
            ["padding": ["top": 0, "bottom": 0, "left": 10, "right": 10]]
        ]
    ],
    ["text":
        ["data": "Product description!",
         "style":
            ["padding": ["top": 0, "bottom": 0, "left": 30, "right": 10],
             "size": 13]
        ]
    ],
    ["text":
        ["data": "Save it!",
         "style":
            ["padding": ["top": 0, "bottom": 0, "left": 10, "right": 10]]
        ]
    ],
]

struct Padding {
    let left: Int
    let right: Int
    let top: Int
    let bottom: Int
    
    init(with json: JSON) {
        guard
            let top = json["top"] as? Int,
            let bottom = json["bottom"] as? Int,
            let left = json["left"] as? Int,
            let right = json["right"] as? Int
        else {
                fatalError()
        }
        
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
    
    init(left: Int, right: Int, top: Int, bottom: Int) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}

struct TextStyle {
    let size: Int
    
    init(with json: JSON) {
        guard
            let size = json["size"] as? Int
        else {
            fatalError()
        }
        
        self.size = size
    }
}

struct Theme {
    let textStyle: TextStyle
    let titleStyle: TextStyle
    
    init(with json: JSON) {
        guard
            let textStyle = json["text"] as? JSON,
            let titleStyle = json["title"] as? JSON
        else {
            fatalError()
        }
        
        self.textStyle = TextStyle(with: textStyle)
        self.titleStyle = TextStyle(with: titleStyle)
    }
}

struct Style {
    let padding: Padding
    var size: Int?
    
    init(with json: JSON) {
        guard
            let padding = json["padding"] as? JSON
        else {
                fatalError()
        }
        
        self.padding = Padding(with: padding)
        
        if let size = json["size"] as? Int {
            self.size = size
        }
    }
}

struct Text {
    let data: String
    let style: Style
    
    init(with json: JSON) {
        guard
            let data = json["data"] as? String,
            let style = json["style"] as? JSON
        else {
            // Better error handling
            fatalError()
        }
        self.data = data
        self.style = Style(with: style)
    }
}

final class TextCell: UICollectionViewCell {
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        addSubview(label)
    }
    
    func configure(with text: String, style: Style, textStyle: TextStyle) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: CGFloat(textStyle.size))
        
        // OVERLOAD
        if let size = style.size {
            label.font = UIFont.systemFont(ofSize: CGFloat(size))
        }
        
        // DEBUG
        layer.borderColor = UIColor.cyan.cgColor
        layer.borderWidth = 1
        
        makeConstraints(with: style)
    }
    
    private func makeConstraints(with style: Style) {
        label.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(style.padding.top)
            make.bottom.equalToSuperview().offset(style.padding.bottom)
            make.left.equalToSuperview().offset(style.padding.left)
            make.right.equalToSuperview().offset(style.padding.right)
        }
    }
}

final class ViewController: UIViewController {
    
    private let loadedJSON: [JSON] = json
    private let styleJSON: JSON = style
    
    private var layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp(view)
    }
    
    private func setUp(_ view: UIView) {
        view.backgroundColor = .blue
        
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "textCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedJSON.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let json = loadedJSON[indexPath.row]
        return configuredCell(for: json, at: indexPath)
    }
    
    private func configuredCell(for json: JSON, at indexPath: IndexPath) -> UICollectionViewCell {
        if let textJSON = json["text"] as? JSON {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            let text = Text(with: textJSON)
            cell.configure(with: text.data, style: text.style, textStyle: Theme(with: style).textStyle)
            return cell
        } else if let titleJSON = json["title"] as? JSON {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            let text = Text(with: titleJSON)
            cell.configure(with: text.data, style: text.style, textStyle: Theme(with: style).titleStyle)
            return cell
        } else {
            print("oops")
            return UICollectionViewCell()
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // DEFINE THE HEIGHT FOR A GIVEN DATA
        
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

PlaygroundPage.current.liveView = ViewController()
