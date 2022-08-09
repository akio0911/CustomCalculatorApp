//
//  ViewController.swift
//  CalculatorTest
//
//  Created by 住田雅隆 on 2022/08/06.
//

import UIKit

class ViewController: UIViewController {

    let numbers = [
        ["税込"],
        ["7","8","9","÷"],
        ["4","5","6","×"],
        ["1","2","3","-"],
        ["0","⌫","=","+"],
    ]
    
    let cellId = "cellId"
    
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var calculatorCollectionView: UICollectionView!
    
    @IBOutlet weak var calculatorHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        
        calculatorCollectionView.delegate = self
        calculatorCollectionView.dataSource = self
        calculatorCollectionView.register(CalculatorViewCell.self, forCellWithReuseIdentifier: cellId)
        calculatorHeightConstraint.constant = view.frame.width * 1 - 10
        calculatorCollectionView.backgroundColor = .lightGray
        calculatorCollectionView.contentInset = .init(top: 0, left: 14, bottom: 0, right: 14)

        answerLabel.text = "0"
        formulaLabel.text = "0"
        
        view.backgroundColor = .white
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // 表示するアイテムの列の数

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numbers.count
    }
    // 表示するアイテムの行に何個表示するか
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers[section].count
    }
    
    // cellとcellの高さの間隔を調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0
        width = ((collectionView.frame.width - 100)) / 4
        let height = width
        
//        if indexPath.section == 4 && indexPath.row == 0 {
//            width = width * 4
//        }
        return .init(width: width, height: height)
    }
    
    // cellとcellの横幅の最小値
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calculatorCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CalculatorViewCell
        cell.numberLabel.text = numbers[indexPath.section][indexPath.row]
        
        numbers[indexPath.section][indexPath.row].forEach { (numberString) in
            if "0"..."9" ~= numberString || numberString.description == "." {
                cell.numberLabel.backgroundColor = .white
            }else if numberString == "⌫" {
                cell.numberLabel.backgroundColor = .lightGray
                cell.numberLabel.textColor = .black
            }else if numberString == "÷" || numberString == "×" || numberString == "+" || numberString == "-" || numberString == "="{
                
                cell.numberLabel.backgroundColor = .systemGray
            }else {
                cell.numberLabel.backgroundColor = .lightGray
                cell.numberLabel.textColor = .black
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 押された文字列を取得している
        let number = numbers[indexPath.section][indexPath.row]
        
        // ボタンが押されたら式を表示する
        guard let formulaText = formulaLabel.text else { return }
        //        let senderText =  number
        
        switch number {
        case "0"..."9":
            if formulaLabel.text == "0" {
                formulaLabel.text = "\(number)"
            }else {

                formulaLabel.text = formulaText + number
            }
        case "+", "-", "×", "÷":
            
            formulaLabel.text = formulaText.removingDuplicateSymbols() + number

//        case ".":
//            if formulaLabel.text == "0" {
//                formulaLabel.text = "0."
//            }else {
//                formulaLabel.text = formulaText.removingDuplicateSymbols() + number
//            }
        case "⌫":
            guard let deleteBackward = formulaLabel.text?.dropLast() else { return }
            if formulaLabel.text?.count == 1 {
                formulaLabel.text = "0"
            } else {
                formulaLabel.text = String(deleteBackward)
            }
        case "=":
            let answer = formattedAnswer(formulaLabel.text ?? "0")
            print(answer)
            answerLabel.text = answer
        default :
            break
        }
    }
    func formattedAnswer(_ formula: String) -> String {
        var formattedFormula: String = formula.replacingOccurrences(of: "(?<=^|[÷×\\+\\-\\(])([0-9]+)(?=[÷×\\+\\-\\)]|$)",
                                                                    with: "$1.0",
                                                                    options: NSString.CompareOptions.regularExpression,
                                                                    range: nil
        ).replacingOccurrences(of: "÷", with: "/").replacingOccurrences(of: "×", with: "*")
        if formattedFormula.hasSuffix("+") || formattedFormula.hasSuffix("-") || formattedFormula.hasSuffix("*") || formattedFormula.hasSuffix("/") || formattedFormula.hasSuffix(".") {
            let replaceFormula = String(formattedFormula.dropLast())
            print(replaceFormula)
            formattedFormula = replaceFormula
        }
        let expression = NSExpression(format: formattedFormula)
        let answer = expression.expressionValue(with: nil, context: nil) as! Double
        let answerString = String(answer)

        if answerString.hasSuffix(".0") {
            return answerString.replacingOccurrences(of: ".0", with: "")
        }
        else { return answerString }
    }
}

extension String {

    func removingDuplicateSymbols() -> String {
        let duplicateSymbol: CharacterSet = ["+", "-", "×", "÷", "."]
        return self.trimmingCharacters(in: duplicateSymbol)
    }
}
