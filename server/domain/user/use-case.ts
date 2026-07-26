import { LocationCommand } from '~/domain/location/command'
import type { UserId } from '~/domain/shared/types'
import { UserCommand } from '~/domain/user/command'
import type { User } from '~/domain/user/types'

export namespace UserUseCase {
  export type Onboarding = {
    firstName: string
    house?: { name: string; icon?: string }
    rooms: { name: string; icon?: string }[]
  }

  /// The first launch, in one call: the user says how to call them, names the
  /// place they are about to fill, and picks the rooms it has.
  ///
  /// The house is optional because an account created before the onboarding
  /// existed already owns places — asking it to name a first house would hand it
  /// a duplicate. Rooms without a house are ignored for the same reason: they
  /// have nowhere to hang.
  ///
  /// Rooms are created **in sequence**, never in parallel: each one derives its
  /// `order` from the siblings already stored, so a fan-out would give them all
  /// the same rank.
  export const onboard = async (
    userId: UserId,
    input: Onboarding,
  ): Promise<User | 'already-onboarded'> => {
    const user = await UserCommand.register(userId, input.firstName)
    if (user === 'already-onboarded') return user

    if (input.house) {
      const place = await LocationCommand.createPlace(userId, {
        name: input.house.name,
        icon: input.house.icon,
      })
      for (const room of input.rooms) {
        await LocationCommand.createRoom(userId, {
          placeId: place.id,
          name: room.name,
          icon: room.icon,
        })
      }
    }

    return user
  }
}
