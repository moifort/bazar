// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// What the first launch collected: a first name, and the first house with its rooms
  struct CompleteOnboardingInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      firstName: FirstName,
      houseIcon: GraphQLNullable<String> = nil,
      houseName: GraphQLNullable<PlaceName> = nil,
      rooms: [OnboardingRoomInput]
    ) {
      __data = InputDict([
        "firstName": firstName,
        "houseIcon": houseIcon,
        "houseName": houseName,
        "rooms": rooms
      ])
    }

    /// How to call the user, e.g. `"Thibaut"`
    var firstName: FirstName {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    /// Optional emoji icon for the house, e.g. `"🏠"`
    var houseIcon: GraphQLNullable<String> {
      get { __data["houseIcon"] }
      set { __data["houseIcon"] = newValue }
    }

    /// Name of the first house, e.g. `"Maison"` — omit it for an account that already owns places, which would otherwise end up with a duplicate
    var houseName: GraphQLNullable<PlaceName> {
      get { __data["houseName"] }
      set { __data["houseName"] = newValue }
    }

    /// Rooms to create in that house — ignored when no `houseName` is given
    var rooms: [OnboardingRoomInput] {
      get { __data["rooms"] }
      set { __data["rooms"] = newValue }
    }
  }

}