// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class AnalyzeItemPhotoMutation: GraphQLMutation {
    static let operationName: String = "AnalyzeItemPhoto"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AnalyzeItemPhoto($imageBase64: String!) { analyzeItemPhoto(imageBase64: $imageBase64) { __typename previewId name category description quantity } }"#
      ))

    public var imageBase64: String

    public init(imageBase64: String) {
      self.imageBase64 = imageBase64
    }

    public var __variables: Variables? { ["imageBase64": imageBase64] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("analyzeItemPhoto", [AnalyzeItemPhoto].self, arguments: ["imageBase64": .variable("imageBase64")]),
      ] }

      /// Analyze a photo with Gemini AI to identify household items
      var analyzeItemPhoto: [AnalyzeItemPhoto] { __data["analyzeItemPhoto"] }

      /// AnalyzeItemPhoto
      ///
      /// Parent Type: `ItemPreview`
      struct AnalyzeItemPhoto: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.ItemPreview }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("previewId", String.self),
          .field("name", String.self),
          .field("category", String?.self),
          .field("description", String.self),
          .field("quantity", Int.self),
        ] }

        /// Preview identifier
        var previewId: String { __data["previewId"] }
        /// Identified item name
        var name: String { __data["name"] }
        /// Suggested category
        var category: String? { __data["category"] }
        /// Item description
        var description: String { __data["description"] }
        /// Number of identical items
        var quantity: Int { __data["quantity"] }
      }
    }
  }

}