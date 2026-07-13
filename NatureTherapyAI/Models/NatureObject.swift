import Foundation
import SwiftData

@Model
final class NatureObject {
    var id: String
    var name: String
    var emoji: String
    var objectDescription: String
    var funFact: String
    var educationalInfo: String
    var category: String
    var dateDiscovered: Date
    var timesSeen: Int
    
    init(id: String = UUID().uuidString,
         name: String,
         emoji: String,
         objectDescription: String,
         funFact: String,
         educationalInfo: String,
         category: String,
         dateDiscovered: Date = Date(),
         timesSeen: Int = 1) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.objectDescription = objectDescription
        self.funFact = funFact
        self.educationalInfo = educationalInfo
        self.category = category
        self.dateDiscovered = dateDiscovered
        self.timesSeen = timesSeen
    }
    
    static let samples: [NatureObject] = [
        NatureObject(name: "Tree", emoji: "🌳",
                     objectDescription: "Tall trees with wide trunks and large canopies that form the roof of the rainforest.",
                     funFact: "Some rainforest trees are over 1000 years old!",
                     educationalInfo: "Trees absorb carbon dioxide and release oxygen. They help keep our air clean and provide homes for animals.",
                     category: "Trees"),
        NatureObject(name: "Leaf", emoji: "🍃",
                     objectDescription: "Flat, green parts of plants that grow on branches and stems.",
                     funFact: "Leaves use sunlight to make food for the plant through photosynthesis!",
                     educationalInfo: "Leaves come in many shapes — round, pointy, jagged. Each shape helps the plant survive in its environment.",
                     category: "Plants"),
        NatureObject(name: "Flower", emoji: "🌸",
                     objectDescription: "Colorful and fragrant parts of plants that bloom in many shapes and sizes.",
                     funFact: "The largest flower in the world can grow up to 1 meter wide!",
                     educationalInfo: "Flowers are how plants reproduce. They attract bees and butterflies with their colors and scents.",
                     category: "Plants"),
        NatureObject(name: "Bird", emoji: "🐦",
                     objectDescription: "Feathered animals with wings and beaks that sing beautiful songs.",
                     funFact: "Some birds can mimic human speech and other sounds they hear.",
                     educationalInfo: "Birds build nests to lay eggs and raise their babies. They help spread seeds throughout the forest.",
                     category: "Animals"),
        NatureObject(name: "Butterfly", emoji: "🦋",
                     objectDescription: "Colorful insects with large wings found near flowers in sunny areas.",
                     funFact: "Butterflies taste with their feet!",
                     educationalInfo: "Butterflies help pollinate flowers just like bees. They start as caterpillars and transform completely.",
                     category: "Animals"),
        NatureObject(name: "River", emoji: "🏞️",
                     objectDescription: "Flowing water that moves through the forest, making gentle sounds.",
                     funFact: "The longest river in the world is the Nile River, over 6,600 km long!",
                     educationalInfo: "Rivers provide water for plants, animals, and people. They shape the landscape over time.",
                     category: "Natural Objects"),
        NatureObject(name: "Rock", emoji: "🪨",
                     objectDescription: "Hard natural objects found on the ground, smooth or rough with different colors.",
                     funFact: "The oldest rocks on Earth are over 4 billion years old!",
                     educationalInfo: "Rocks are made of minerals and come in three types: igneous, sedimentary, and metamorphic.",
                     category: "Natural Objects"),
        NatureObject(name: "Mushroom", emoji: "🍄",
                     objectDescription: "Fungi that grow in damp, shaded areas of the forest floor.",
                     funFact: "Some mushrooms can glow in the dark through bioluminescence!",
                     educationalInfo: "Mushrooms help decompose dead plants and return nutrients to the soil.",
                     category: "Fungi"),
        NatureObject(name: "Animal", emoji: "🐾",
                     objectDescription: "Living creatures that move through the forest, from tiny insects to large mammals.",
                     funFact: "Malaysia's rainforest is home to over 200 species of mammals!",
                     educationalInfo: "Animals need forests for food, shelter, and water. Protecting forests helps protect animal homes.",
                     category: "Animals"),
        NatureObject(name: "Fruit", emoji: "🍎",
                     objectDescription: "Seed-bearing structures produced by flowering plants, often colorful and nutritious.",
                     funFact: "The durian, known as the king of fruits, is native to Malaysian rainforests!",
                     educationalInfo: "Fruits help plants spread their seeds. Animals eat fruits and carry the seeds to new places.",
                     category: "Plants")
    ]
    
    static func sample(for name: String) -> NatureObject? {
        samples.first { $0.name.lowercased() == name.lowercased() }
            ?? samples.first { name.lowercased().contains($0.name.lowercased().split(separator: " ").last?.lowercased() ?? "") }
            ?? NatureObject(name: name, emoji: "🌱",
                          objectDescription: "A wonderful part of nature waiting to be explored!",
                          funFact: "Every part of nature has a special role in the ecosystem.",
                          educationalInfo: "Take a closer look and observe its colors, shapes, and textures.",
                          category: "General")
    }
}
