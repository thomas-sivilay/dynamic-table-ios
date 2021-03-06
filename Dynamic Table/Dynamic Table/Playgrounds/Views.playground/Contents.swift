import UIKit
import PlaygroundSupport
import SnapKit

typealias JSON = [String : Any]

protocol Data { }

protocol Style {
    var padding: Padding { get }
}

extension Style {
    var padding: Padding { return Padding() }
}

struct TextData: Codable, Data {
    let text: String
}

struct ImageData: Codable, Data {
    let url: String
}

enum FontWeight: String, Codable {
    case normal
    case bold
}

struct TextStyle: Codable, Style {
    let size: Float
    let padding: Padding
    var weight: FontWeight?
    let hexColor: String
}

struct Padding: Codable {
    let left: Int
    let right: Int
    let top: Int
    let bottom: Int
    
    init() {
        self.top = 0
        self.bottom = 0
        self.left = 0
        self.right = 0
    }
}

struct ImageStyle: Codable, Style { }

struct Collection: Decodable {
    let style: Padding
    let data: [UIElement]
}

final class Element<Data, Style> {
    var data: Data
    var style: Style
    
    init(data: Data, style: Style) {
        self.data = data
        self.style = style
    }
}

enum UIElement: Decodable {
    case title(Element<TextData, TextStyle>)
    case text(Element<TextData, TextStyle>)
    
    case image(data: ImageData, style: ImageStyle)
}

extension UIElement {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case data
        case style
    }
    
    enum UIElementCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let type = try? values.decode(String.self, forKey: .type) {
            switch type {
            case "text":
                if
                    let data = try? values.decode(TextData.self, forKey: .data),
                    let style = try? values.decode(TextStyle.self, forKey: .style)
                {
                    self = .text(Element(data: data, style: style))
                    return
                } else {
                    throw UIElementCodingError.decoding("Text Error")
                }
            case "title":
                if
                    let data = try? values.decode(TextData.self, forKey: .data),
                    let style = try? values.decode(TextStyle.self, forKey: .style)
                {
                    self = .title(Element(data: data, style: style))
                    return
                } else {
                    throw UIElementCodingError.decoding("Title Error")
                }
            case "image":
                if
                    let data = try? values.decode(ImageData.self, forKey: .data),
                    let style = try? values.decode(ImageStyle.self, forKey: .style)
                {
                    self = .image(data: data, style: style)
                    return
                } else {
                    throw UIElementCodingError.decoding("Image Error")
                }
            default:
                throw UIElementCodingError.decoding("Unknown key \(type)")
            }
        } else {
            throw UIElementCodingError.decoding("Wow Error")
        }
    }
}

let style = """
{
    "text":
    {"size": 16},
    "title":
    {"size": 24}
}
""".data(using: .utf8)!

let json = """
{
    "type": "collection",
    "data":
[
    {
        "type": "title",
        "data": {"text": "Hello!"},
         "style": {"padding": {"top": 0, "bottom": 0, "left": 20, "right": 20}, "size": 24, "weight": "bold", "hexColor": "#161616"}
    },
    {
        "type": "text",
        "data": {"text": "Hello, this is a text written in multiline that should be long enough to test."},
         "style": {"padding": {"top": 0, "bottom": 0, "left": 20, "right": 20}, "size": 14, "hexColor": "#646464"}
    },
],
    "style": {"top": 120, "bottom": 20, "left": 20, "right": 20}
}
""".data(using: .utf8)!

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
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
    
    func configure(with data: TextData, style: Style) {
        label.text = data.text
        label.numberOfLines = 0
        
        if let style = style as? TextStyle {
            label.textColor = hexStringToUIColor(hex: style.hexColor)
            label.font = UIFont.systemFont(ofSize: CGFloat(style.size))
            
            if let weight = style.weight {
                switch weight {
                case .bold:
                    label.font = UIFont.systemFont(ofSize: CGFloat(style.size), weight: UIFont.Weight.bold)
                case .normal:
                    label.font = UIFont.systemFont(ofSize: CGFloat(style.size), weight: UIFont.Weight.medium)
                }
            }
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
            make.right.equalToSuperview().inset(style.padding.right)
        }
    }
}

final class ViewController: UIViewController {
    
    private var layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var collection = Collection(style: Padding(), data: [UIElement]()) {
        didSet {
            makeConstraints(with: collection.style)
            collectionView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp(view)
        loadData()
    }
    
    private func setUp(_ view: UIView) {
        view.backgroundColor = .white
        
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "textCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        makeConstraints(with: collection.style)
    }
    
    private func makeConstraints(with padding: Padding) {
        collectionView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(padding.top)
            make.bottom.equalToSuperview().offset(padding.bottom)
            make.left.equalToSuperview().offset(padding.left)
            make.right.equalToSuperview().inset(padding.right)
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        do {
            collection = try decoder.decode(Collection.self, from: json)
        } catch {
            print(error)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let element = collection.data[indexPath.row]
        return configuredCell(for: element, at: indexPath)
    }
    
    private func configuredCell(for element: UIElement, at indexPath: IndexPath) -> UICollectionViewCell {
        
        switch element {
        case let .image(data: _, style: _):
            print("oops")
            return UICollectionViewCell()
        case let .text(element):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            cell.configure(with: element.data, style: element.style)
            return cell
        case let .title(element):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            cell.configure(with: element.data, style: element.style)
            return cell
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // DEFINE THE HEIGHT FOR A GIVEN DATA
        
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

PlaygroundPage.current.liveView = ViewController()
