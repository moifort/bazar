import Foundation

// MARK: - Item

struct Item: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let category: ItemCategory
    let quantity: Int
    var photoImageId: String?
    var addedBy: String
    let personalNotes: String
    var purchaseDate: Date?
    var purchaseLocation: String
    var invoiceImageId: String?
    let createdAt: Date
    let updatedAt: Date
    var location: LocationPath?
    var reminders: [Reminder]
}

struct ItemListItem: Identifiable, Sendable {
    let id: String
    let name: String
    let category: ItemCategory
    let quantity: Int
    var photoImageId: String?
    var locationFullPath: String?
    var addedBy: String
    let createdAt: Date
    var overdueReminderCount: Int
}

struct ItemListPage: Sendable {
    let items: [ItemListItem]
    let totalCount: Int
    let hasMore: Bool
}

// MARK: - Reminder

enum ReminderFrequency: String, Sendable, CaseIterable, Identifiable {
    case monthly
    case quarterly
    case biannual
    case annual
    case customDays = "custom_days"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .monthly: "Tous les mois"
        case .quarterly: "Tous les 3 mois"
        case .biannual: "Tous les 6 mois"
        case .annual: "Tous les ans"
        case .customDays: "Personnalisé"
        }
    }
}

struct Reminder: Identifiable, Sendable, Hashable {
    let id: String
    let itemId: String
    var title: String
    var notes: String
    var dueDate: Date
    var frequency: ReminderFrequency?
    var customIntervalDays: Int?
    let createdAt: Date
    let updatedAt: Date

    var isOverdue: Bool { dueDate <= Date() }
}

// MARK: - Item Preview (from scan)

struct ItemPreview: Identifiable, Sendable {
    let previewId: String
    var name: String
    var category: ItemCategory?
    var description: String
    var quantity: Int

    var id: String { previewId }
}

// MARK: - Location

struct LocationPath: Sendable {
    let fullPath: String
    let placeId: String
    let placeName: String
    let roomId: String
    let roomName: String
    let zoneId: String
    let zoneName: String
    let storageId: String
    let storageName: String
}

struct Place: Identifiable, Sendable {
    let id: String
    var name: String
    var icon: String?
    let order: Int
    var rooms: [Room]
}

struct Room: Identifiable, Sendable {
    let id: String
    let placeId: String
    var name: String
    var icon: String?
    let order: Int
    var zones: [Zone]
}

struct Zone: Identifiable, Sendable {
    let id: String
    let roomId: String
    var name: String
    let order: Int
    var storages: [Storage]
}

struct Storage: Identifiable, Sendable {
    let id: String
    let zoneId: String
    var name: String
    let order: Int
}

// MARK: - Dashboard

struct DashboardData: Sendable {
    let totalItems: Int
    let itemsByCategory: [CategoryCount]
    let itemsByPlace: [PlaceCount]
    let recentItems: [ItemListItem]
}

struct CategoryCount: Sendable, Identifiable {
    let category: ItemCategory
    let count: Int
    var id: String { category.rawValue }
}

struct PlaceCount: Sendable, Identifiable {
    let placeId: String
    let placeName: String
    let count: Int
    var id: String { placeId }
}

// MARK: - Search

struct SearchEntry: Identifiable, Sendable {
    let type: String
    let entityId: String
    let text: String
    var id: String { "\(type)-\(entityId)" }
}

// MARK: - Enums

enum ItemCategory: String, Sendable, CaseIterable, Identifiable {
    case tools
    case appliances
    case decor
    case clothing
    case documents
    case food
    case electronics
    case furniture
    case kitchenware
    case linen
    case sports
    case toys
    case books
    case media
    case hygiene
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .tools: "Outils"
        case .appliances: "Électroménager"
        case .decor: "Décoration"
        case .clothing: "Vêtements"
        case .documents: "Documents"
        case .food: "Alimentaire"
        case .electronics: "Électronique"
        case .furniture: "Meubles"
        case .kitchenware: "Cuisine"
        case .linen: "Linge"
        case .sports: "Sport"
        case .toys: "Jouets"
        case .books: "Livres"
        case .media: "Médias"
        case .hygiene: "Hygiène"
        case .other: "Autre"
        }
    }

    var icon: String {
        switch self {
        case .tools: "wrench.and.screwdriver"
        case .appliances: "washer"
        case .decor: "paintpalette"
        case .clothing: "tshirt"
        case .documents: "doc.text"
        case .food: "carrot"
        case .electronics: "desktopcomputer"
        case .furniture: "sofa"
        case .kitchenware: "frying.pan"
        case .linen: "bed.double"
        case .sports: "figure.run"
        case .toys: "gamecontroller"
        case .books: "book"
        case .media: "opticaldisc"
        case .hygiene: "shower"
        case .other: "questionmark.folder"
        }
    }

    var color: Color {
        switch self {
        case .tools: .orange
        case .appliances: .blue
        case .decor: .pink
        case .clothing: .purple
        case .documents: .gray
        case .food: .green
        case .electronics: .cyan
        case .furniture: .brown
        case .kitchenware: .red
        case .linen: .indigo
        case .sports: .mint
        case .toys: .yellow
        case .books: .teal
        case .media: .orange
        case .hygiene: .blue
        case .other: .secondary
        }
    }
}

import SwiftUI

enum ItemSort: String, CaseIterable, Identifiable {
    case name
    case category
    case createdAt = "created-at"
    case updatedAt = "updated-at"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .name: "Nom"
        case .category: "Catégorie"
        case .createdAt: "Date d'ajout"
        case .updatedAt: "Dernière modification"
        }
    }

    var icon: String {
        switch self {
        case .name: "textformat"
        case .category: "tag"
        case .createdAt: "calendar.badge.plus"
        case .updatedAt: "calendar.badge.clock"
        }
    }
}
