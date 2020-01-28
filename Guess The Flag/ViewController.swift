//
//  ViewController.swift
//  Guess The Flag
//
//  Created by Jerry Turcios on 1/1/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!

    var countries = [String]()
    var score = 0
    var highScore = 0
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .pause,
            target: self,
            action: #selector(showScore)
        )

        let defaults = UserDefaults.standard

        if let savedData = defaults.object(forKey: "highScore") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                highScore = try jsonDecoder.decode(Int.self, from: savedData)
            } catch {
                print("Failed to decode data from JSON")
            }
        }

        registerNotifications()
        askQuestion()
    }

    func registerNotifications() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            [weak self] granted, error in

            if granted {
                print("YAHHH!")
                self?.scheduleReminder()
            } else {
                print("NOOOO!")
            }
        }
    }

    func scheduleReminder() {
        registerCategories()

        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Daily reminder"
        content.body = "This is your daily reminder to play again!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["userInfo": "fizzbuzz"]
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(identifier: "show", title: "Open \"Guess The Flag\"", options: .foreground)

        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let customData = userInfo["customData"] as? String {
            print("Custom data recieved: \(customData)")

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                let ac = UIAlertController(title: "Default", message: "Default identifier", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .default))
                present(ac, animated: true)
                print("Default identifier")
            default:
                break
            }
        }

        completionHandler()
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

        title = "\(countries[correctAnswer].uppercased())?"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var message: String

        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { finished in
            sender.transform = .identity
        }

        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1

            // Checks if the player beat their high score
            if score > highScore {
                highScore = score
                message = "Your new high score is \(score)"
                saveHighScore()
            } else {
                message = "Your score is now \(score). Your high score is " +
                    "\(highScore)"
            }
        } else {
            title = "Wrong!"
            score -= 1
            message = "That is the flag of " +
                "\(countries[sender.tag].uppercased()). Your score is now " +
                "\(score)"
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

    @objc func showScore() {
        let ac = UIAlertController(
            title: "Paused",
            message: "The game is paused. Your score is currently " +
                "\(score). Your high score is \(highScore)",
            preferredStyle: .alert
        )

        ac.addAction(
            UIAlertAction(
                title: "Play",
                style: .default,
                handler: nil
            )
        )

        present(ac, animated: true)
    }

    func saveHighScore() {
        let jsonEncoder = JSONEncoder()

        if let savedData = try? jsonEncoder.encode(highScore) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "highScore")
        }
    }
}
