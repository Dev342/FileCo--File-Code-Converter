
import OpenAISwift
import Foundation

class OpenAIManager {
    
    static let shared = OpenAIManager()
    
    let maxToken = 2048
    let openAI: OpenAISwift = OpenAISwift(config:OpenAISwift.Config.makeDefaultOpenAI(
                                                apiKey: "Enter your own API Key"))

}
