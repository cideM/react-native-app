//
//  String+Convenience.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 12.04.23.
//

import Foundation

extension String {

    // Taken from here: https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    // Taken from here: https://gist.github.com/emersonbroga/f84c7490d1813902a61b
    static func randomWord(length: Int = .random(in: 12...28)) -> String {

        let kCons = 1
        let kVows = 2

        var cons: [String] = [
            // single consonants. Beware of Q, it"s often awkward in words
            "b", "c", "d", "f", "g", "h", "j", "k", "l", "m",
            "n", "p", "r", "s", "t", "v", "w", "x", "z",
            // possible combinations excluding those which cannot start a word
            "pt", "gl", "gr", "ch", "ph", "ps", "sh", "st", "th", "wh"
        ]

        // consonant combinations that cannot start a word
        let cons_cant_start: [String] = [
            "ck", "cm",
            "dr", "ds",
            "ft",
            "gh", "gn",
            "kr", "ks",
            "ls", "lt", "lr",
            "mp", "mt", "ms",
            "ng", "ns",
            "rd", "rg", "rs", "rt",
            "ss",
            "ts", "tch"
        ]

        let vows: [String] = [
            // single vowels
            "a", "e", "i", "o", "u", "y",
            // vowel combinations your language allows
            "ee", "oa", "oo"
        ]

        // start by vowel or consonant ?
        var current = (Int(arc4random_uniform(2)) == 1 ? kCons : kVows )

        var word: String = ""
        while  word.count < length {
            // After first letter, use all consonant combos
            if word.count == 2 {
                cons = cons + cons_cant_start
            }

            // random sign from either $cons or $vows
            var rnd: String = ""
            var index: Int
            if current == kCons {
                index = Int(arc4random_uniform(UInt32(cons.count)))
                rnd = cons[index]
            } else if current == kVows {
                index = Int(arc4random_uniform(UInt32(vows.count)))
                rnd = vows[index]
            }

            // check if random sign fits in word length
            let tempWord = "\(word)\(rnd)"
            if  tempWord.count <= length {
                word = "\(word)\(rnd)"
                // alternate sounds
                current = ( current == kCons ) ? kVows : kCons
            }
        }

        return word.capitalized
    }

    static func randomSentence() -> String {
        [
            "My girl wove six dozen plaid jackets before she quit.",
            "The spectacle before us was indeed sublime.",
            "She stared through the window at the stars.",
            "The five boxing wizards jump quickly.",
            "Pack my box with five dozen liquor jugs.",
            "Fickle jinx bog dwarves spy math quiz.",
            "A shining crescent far beneath the flying vessel.",
            "Waves flung themselves at the blue evening.",
            "Silver mist suffused the deck of the ship.",
            "It was going to be a lonely trip back.",
            "The quick brown fox jumps over the lazy dog.",
            "Mist enveloped the ship three hours out from port.",
            "Quick fox jumps nightly above wizard.",
            "Foxy diva Jennifer Lopez wasn’t baking my quiche.",
            "The wizard quickly jinxed the gnomes before they vaporized.",
            "All their equipment and instruments are alive.",
            "Five quacking zephyrs jolt my wax bed.",
            "I watched the storm, so beautiful yet terrific.",
            "The recorded voice scratched in the speaker.",
            "Jim quickly realized that the beautiful gowns are expensive.",
            "A red flair silhouetted the jagged edge of a wing.",
            "The face of the moon was in shadow.",
            "My two natures had memory in common.",
            "Public junk dwarves hug my quartz fox.",
            "We promptly judged antique ivory buckles for the next prize.",
            "Grumpy wizards make a toxic brew for the jovial queen.",
            "Then came the night of the first falling star.",
            "All questions asked by five watched experts amaze the judge.",
            "Two driven jocks help fax my big quiz.",
            "Almost before we knew it, we had left the ground.",
            "When zombies arrive, quickly fax judge Pat.",
            "Back in June we delivered oxygen equipment of the same size.",
            "Woven silk pyjamas exchanged for blue quartz.",
            "The sky was cloudless and of a deep dark blue.",
            "A quivering Texas zombie fought republic linked jewelry.",
            "The quick onyx goblin jumps over the lazy dwarf."
        ].randomElement()!
    }

    static func alllCharacters() -> String {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n1234567890"
    }
    static func randomQuote() -> String {
        [
            "I know I’m a handful but that’s why you got two hands.",
            "Failure is the condiment that gives success its flavor.",
            "If you think you are too small to be effective, you have never been in the dark with a mosquito.",
            "Taking naps sounds so childish. I prefer to call them horizontal life pauses.",
            "I walk around like everything’s fine, but deep down, inside my shoe, my sock is sliding off.",
            "If we’re not meant to have midnight snacks, why is there a light in the fridge?",
            "The best thing about the future is that it comes one day at a time.",
            "I’m not good at the advice. Can I interest you in a sarcastic comment?",
            "My ability to turn good news into anxiety is rivaled only by my ability to turn anxiety into chin acne.",
            "So it turns out that being an adult is really just Googling how to do stuff.",
            "It’s okay to look at the past and the future. Just don’t stare.",
            "Always remember that you are unique – just like everybody else.",
            "Would I rather be feared or loved? Easy. Both. I want people to be afraid of how much they love me.",
            "All you need is love. But a little chocolate now and then doesn’t hurt.",
            "Before you marry a person, you should first make them use a computer with slow Internet to see who they really are.",
            "I love being married. It’s so great to find one special person you want to annoy for the rest of your life.",
            "If love is the answer, can you please rephrase the question?",
            "Love can change a person the way a parent can change a baby—awkwardly, and often with a great deal of mess.",
            "Love is a fire. But whether it is going to warm your hearth or burn down your house, you can never tell.",
            "A successful marriage requires falling in love many times, always with the same person.",
            "I love you with all my belly. I would say my heart, but my belly is bigger.",
            "The four most important words in any marriage—I’ll do the dishes.",
            "I love you more than coffee but not always before coffee.",
            "I like long romantic walks down every aisle at Target.",
            "You know that tingly little feeling you get when you like someone? That’s your common sense leaving your body.",
            "It’s important to have a twinkle in your wrinkle.",
            "We don’t grow old. When we cease to grow, we become old.",
            "Age is an issue of mind over matter. If you don’t mind, it doesn’t matter.",
            "You’re not as young as you used to be. But you’re not as old as you’re going to be.",
            "You’re in mint condition for a vintage model. Happy Birthday.",
            "You know you’re getting old when the candles cost more than the cake.",
            "After 30, a body has a mind of its own.",
            "You’re not forty, you’re eighteen with twenty-two years experience.",
            "Forget about the past, you can’t change it. Forget about the future, you can’t predict it. And forget about the present, I didn’t get you one. Happy birthday!",
            "Don’t get all weird about getting older! Our age is merely the number of years the world has been enjoying us!",
            "As you get older three things happen. The first is your memory goes, and I can’t remember the other two. Happy birthday!",
            "To quote Shakespeare: ‘Party thine ass off!’",
            "You are only young once, but you can be immature for a lifetime. Happy birthday!",
            "On your birthday, I thought of giving you the cutest gift in the world. But then I realized that is not possible because you yourself are the cutest gift in the world.",
            "I choose a lazy person to do a hard job, because a lazy person will find an easy way to do it.",
            "Doing nothing is very hard to do… you never know when you’re finished.",
            "It takes less time to do a thing right, than it does to explain why you did it wrong.",
            "Most of what we call management consists of making it difficult for people to get their work done.",
            "It is better to have one person working with you than three people working for you.",
            "The best way to appreciate your job is to imagine yourself without one.",
            "I hate when I lose things at work, like pens, papers, sanity and dreams.",
            "Creativity is allowing yourself to make mistakes. Art is knowing which ones to keep.",
            "My keyboard must be broken, I keep hitting the escape key, but I’m still at work.",
            "Work is against human nature. The proof is that it makes us tired.",
            "The reward for good work is more work.",
            "Executive ability is deciding quickly and getting somebody else to do the work.",
            "People say nothing is impossible, but I do nothing every day.",
            "I like to think of myself less like ‘an adult’ and more like a ‘former fetus.’",
            "I always wanted to be somebody, but now I realize I should have been more specific.",
            "Every day in high school, I was looking for the snack, not knowing that I was the snack after all.",
            "Turned all my Ls into lessons.",
            "The roof is not my son, but I will raise it.",
            "Welp, glad that’s over.",
            "Don’t follow your dreams, follow my Twitter: [insert Twitter handle].",
            "Goodbye, everyone! I’ll remember you all in therapy.",
            "The bell doesn’t dismiss you.",
            "The only time I set the bar low is for limbo",
            "Pain is temporary, GPA is forever",
            "You’re doing amazing, sweetie!",
            "We put the ‘fun’ in dysfunctional",
            "Happiness is having a large, loving, caring, close-knit family in another city.",
            "The informality of family life is a blessed condition that allows us all to become our best while looking our worst.",
            "Families are like fudge – mostly sweet with a few nuts.",
            "Being part of a family means smiling for photos.",
            "Family ties mean that no matter how much you might want to run from your family, you can’t.",
            "The advantage of growing up with siblings is that you become very good at fractions.",
            "Children really can brighten up a house, because they never turn the lights off.",
            "The reason grandparents and grandchildren get along so well is that they have a common enemy.",
            "One day you will do things for me that you hate. That is what it means to be family.",
            "It’s fun to complain with someone. Nothing brings us together more than complaining about other people. That might be the thing that holds us together more than anything.",
            "Friends are people who know you really well and like you anyway.",
            "It is one of the blessings of old friends that you can afford to be stupid with them.",
            "It is more fun to talk with someone who doesn’t use long, difficult words but rather short, easy words like ‘What about lunch?’",
            "There is nothing better than a friend, unless it is a friend with chocolate.",
            "If you have friends who are as weird as you, then you have everything.",
            "We are best friends. Always remember that if you fall, I will pick you up… after I finish laughing.",
            "God made up best friends because he knew our mom couldn’t handle us as sisters.",
            "Friendship must be built on a solid foundation of alcohol, sarcasm, inappropriateness and shenanigans.",
            "Real friends don’t get offended when you insult them. They smile and call you something even more offensive."
        ].randomElement()!
    }
}
