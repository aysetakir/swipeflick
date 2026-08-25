import Foundation

enum Mood: String, CaseIterable {
    case happy = "Happy"
    case sad = "Sad"
    case excited = "Excited"
    case chill = "Chill"
    case romantic = "Romantic"
    case thoughtful = "Thoughtful"
    
    var displayName: String {
        switch self {
        case .happy: return "moodHappy".translated
        case .sad: return "moodSad".translated
        case .excited: return "moodExcited".translated
        case .chill: return "moodChill".translated
        case .romantic: return "moodRomantic".translated
        case .thoughtful: return "moodThoughtful".translated
        }
    }
    
    var intValue: Int {
         return Mood.allCases.firstIndex(of: self) ?? 0
     }
    
    var genreIDs: [Int] {
        switch self {
        case .happy:
            return [35, 10751, 16] // Comedy, Family, Animation
        case .sad:
            return [18, 10749] // Drama, Romance
        case .excited:
            return [28, 12, 878] // Action, Adventure, Sci-Fi
        case .chill:
            return [10402, 99, 10770] // Music, Documentary, TV Movie
        case .romantic:
            return [10749, 35] // Romance, Comedy
        case .thoughtful:
            return [18, 36, 9648] // Drama, History, Mystery
        }
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .excited: return "🤩"
        case .chill: return "😌"
        case .romantic: return "🥰"
        case .thoughtful: return "🤔"
        }
    }
}
