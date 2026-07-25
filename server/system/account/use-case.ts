import { ItemCommand } from '~/domain/item/command'
import { LocationCommand } from '~/domain/location/command'
import { NotificationCommand } from '~/domain/notification/command'
import { ReminderCommand } from '~/domain/reminder/command'
import type { UserId } from '~/domain/shared/types'
import { auth } from '~/system/firebase'

export namespace AccountUseCase {
  /// Erase a user and everything the app holds on them. Irreversible, and immediate:
  /// there is no grace period to reason about and no scheduled job to watch.
  ///
  /// Each domain forgets its own documents — none of them knows about the others —
  /// and the account itself goes last. The order is the point: an account deleted
  /// before its data would leave documents keyed to a user nobody can authenticate
  /// as, unreachable and unclaimable. The reverse merely leaves an empty account,
  /// which the next attempt finishes off.
  export const remove = async (userId: UserId): Promise<void> => {
    await ItemCommand.forget(userId)
    await ReminderCommand.forget(userId)
    await LocationCommand.forget(userId)
    await NotificationCommand.forget(userId)
    await auth().deleteUser(userId)
  }
}
