import { builder } from '~/domain/shared/graphql/builder'

export const OnboardingRoomInput = builder.inputType('OnboardingRoomInput', {
  description: 'A room to create in the house the onboarding names',
  fields: (t) => ({
    name: t.field({ type: 'RoomName', required: true, description: 'Room name, e.g. `"Cuisine"`' }),
    icon: t.string({ description: 'Optional emoji icon, e.g. `"🍳"`' }),
  }),
})

export const CompleteOnboardingInput = builder.inputType('CompleteOnboardingInput', {
  description: 'What the first launch collected: a first name, and the first house with its rooms',
  fields: (t) => ({
    firstName: t.field({
      type: 'FirstName',
      required: true,
      description: 'How to call the user, e.g. `"Thibaut"`',
    }),
    houseName: t.field({
      type: 'PlaceName',
      description:
        'Name of the first house, e.g. `"Maison"` — omit it for an account that already owns ' +
        'places, which would otherwise end up with a duplicate',
    }),
    houseIcon: t.string({ description: 'Optional emoji icon for the house, e.g. `"🏠"`' }),
    rooms: t.field({
      type: [OnboardingRoomInput],
      required: true,
      description: 'Rooms to create in that house — ignored when no `houseName` is given',
    }),
  }),
})
