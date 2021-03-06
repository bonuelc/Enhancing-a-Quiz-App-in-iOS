//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    let questionsPerRound = 4
    var questionsAsked = 0
    var correctQuestions = 0
    var correctAnswer: String = ""
    var triviaModel = TriviaModel()
    var mathMode: Bool = true
    
    var timer = NSTimer()
    let secondsPerQuestion: NSTimeInterval = 15
    
    var gameSound: SystemSoundID = 0
    var correctAnswerSound: SystemSoundID = 0
    var incorrectAnswerSound: SystemSoundID = 0
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var playMathButton: UIButton!
    @IBOutlet weak var playTriviaButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameSounds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayQuestionAndOptions() {
        if mathMode {
            let qD = MathModel.randomMathEquationDict()
            displayQuestionAndOptions(questionDictionary: qD)
        } else if let qD = triviaModel.randomTrivia() {
            displayQuestionAndOptions(questionDictionary: qD)
        } else {
            nextRound(true)
        }
    }
    
    func displayQuestionAndOptions(questionDictionary qD: [String : String]) {
        // begin countdown
        timer = NSTimer.scheduledTimerWithTimeInterval(secondsPerQuestion, target: self, selector: #selector(ViewController.timesUp), userInfo: nil, repeats: false)
        
        // reset buttons
        removeBoardersFromButtons()
        enableButtons()
        
        questionField.text = qD[questionKey]
        option1Button.setTitle(qD[option1Key], forState: .Normal)
        option2Button.setTitle(qD[option2Key], forState: .Normal)
        option3Button.setTitle(qD[option3Key], forState: .Normal)
        option4Button.setTitle(qD[option4Key], forState: .Normal)
        
        correctAnswer = qD["Answer"]!
    }
    
    func displayScore() {
        hideAnswerButtons()
        showPlayButtons()
        
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsAsked) correct!"
        
    }
    
    @IBAction func checkAnswer(sender: UIButton? = nil) {
        timer.invalidate()
        
        // Increment the questions asked counter
        questionsAsked += 1
        
        disableButtons()
        
        showCorrectAnswer(correctAnswer)
        
        if let button = sender {
            if (button.currentTitle == correctAnswer) {
                correctQuestions += 1
                questionField.text = "Correct!"
                playCorrectAnswerSound()
            } else {
                highlightOptionButton(button, correctAnswer: false)
                questionField.text = "Sorry, wrong answer!"
                playIncorrectAnswerSound()
            }
        } else {
            questionField.text = "Sorry, time is up!"
            playIncorrectAnswerSound()
        }
        
        loadNextRoundWithDelay(seconds: 2)
    }
    
    func timesUp() {
        checkAnswer()
    }
    
    func nextRound(noMoreQuestionsLeft: Bool = false) {
        if questionsAsked == questionsPerRound || noMoreQuestionsLeft {
            // Game is over
            displayScore()
            // Get trivia model with question that were already asked
            triviaModel = TriviaModel()
        } else {
            // Continue game
            displayQuestionAndOptions()
        }
    }
    
    @IBAction func playAgain(sender: UIButton) {
        mathMode = sender === playMathButton
        
        playGameStartSound()
        
        hidePlayButtons()
        
        showAnswerButtons()
        
        questionsAsked = 0
        correctQuestions = 0
        nextRound()
    }
    

    
    // MARK: Helper Methods
    func hidePlayButtons(hide: Bool = true) {
        playMathButton.hidden = hide
        playTriviaButton.hidden = hide
    }
    
    func showPlayButtons() {
        hidePlayButtons(false)
    }
    
    func showCorrectAnswer(answer: String) {
        if option1Button.currentTitle == answer {
            highlightOptionButton(option1Button, correctAnswer: true)
        } else if option2Button.currentTitle == answer {
            highlightOptionButton(option2Button, correctAnswer: true)
        } else if option3Button.currentTitle == answer {
            highlightOptionButton(option3Button, correctAnswer: true)
        } else if option4Button.currentTitle == answer {
            highlightOptionButton(option4Button, correctAnswer: true)
        }
    }
    
    func hideAnswerButtons(hide: Bool = true) {
        option1Button.hidden = hide
        option2Button.hidden = hide
        option3Button.hidden = hide
        option4Button.hidden = hide
    }
    
    func showAnswerButtons() {
        hideAnswerButtons(false)
    }
    
    func enableButtons(enable: Bool = true) {
        option1Button.enabled = enable
        option2Button.enabled = enable
        option3Button.enabled = enable
        option4Button.enabled = enable
    }
    
    func disableButtons() {
        enableButtons(false)
    }
    
    func removeBoardersFromButtons() {
        option1Button.layer.borderWidth = 0.0
        option2Button.layer.borderWidth = 0.0
        option3Button.layer.borderWidth = 0.0
        option4Button.layer.borderWidth = 0.0
    }
    
    func highlightOptionButton(sender: UIButton, correctAnswer: Bool) {
        if correctAnswer {
            sender.layer.borderColor = UIColor.greenColor().CGColor
        } else {
            sender.layer.borderColor = UIColor.redColor().CGColor
        }
        sender.layer.borderWidth = 2.0
    }
    
    func loadNextRoundWithDelay(seconds seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay)
        
        // Executes the nextRound method at the dispatch time on the main queue
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            self.nextRound()
        }
    }
    
    func loadGameSounds() {
        let pathToSoundFile1 = NSBundle.mainBundle().pathForResource("GameSound", ofType: "wav")
        let soundURL1 = NSURL(fileURLWithPath: pathToSoundFile1!)
        AudioServicesCreateSystemSoundID(soundURL1, &gameSound)
        
        let pathToSoundFile2 = NSBundle.mainBundle().pathForResource("doh1", ofType: "wav")
        let soundURL2 = NSURL(fileURLWithPath: pathToSoundFile2!)
        AudioServicesCreateSystemSoundID(soundURL2, &incorrectAnswerSound)
        
        let pathToSoundFile3 = NSBundle.mainBundle().pathForResource("roger-doger", ofType: "wav")
        let soundURL3 = NSURL(fileURLWithPath: pathToSoundFile3!)
        AudioServicesCreateSystemSoundID(soundURL3, &correctAnswerSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func playCorrectAnswerSound() {
        AudioServicesPlaySystemSound(correctAnswerSound)
    }
    
    func playIncorrectAnswerSound() {
        AudioServicesPlaySystemSound(incorrectAnswerSound)
    }
}

