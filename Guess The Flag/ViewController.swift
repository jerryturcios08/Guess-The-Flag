//
//  ViewController.swift
//  Guess The Flag
//
//  Created by Jerry Turcios on 1/1/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!

    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var numberOfQuestionsAsked = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        countries += [
            "estonia", "france", "germany", "ireland",
            "italy", "monaco", "nigeria", "poland",
            "russia", "spain", "uk", "us"
        ]

        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1

        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        // Creates an alert when the user reaches the 10th question
        if numberOfQuestionsAsked == 10 {
            let ac = UIAlertController(
                title: "10th question asked",
                message: "You have reached the 10th question asked. Your " +
                    "final score is \(score)!",
                preferredStyle: .alert
            )

            ac.addAction(
                UIAlertAction(
                    title: "Play again",
                    style: .default,
                    handler: nil
                )
            )

            present(ac, animated: true)

            score = 0
            numberOfQuestionsAsked = 0
        }

        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        numberOfQuestionsAsked += 1

        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)

        title = "\(countries[correctAnswer].uppercased())? Score: \(score)"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var message: String

        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            message = "Your score is now \(score)."
        } else {
            title = "Wrong!"
            score -= 1
            message = "That is the flag of " +
                "\(countries[sender.tag].uppercased()). Your score is now " +
                "\(score)."
        }

        // Create the alert controller with the properties set
        let ac = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        // Add actions to alert controller so that some action is performed
        // when the user presses the "Continue" button
        ac.addAction(
            UIAlertAction(
                title: "Continue",
                style: .default,
                handler: askQuestion
            )
        )

        present(ac, animated: true)
    }
}
