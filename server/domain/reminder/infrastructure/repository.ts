import type { ItemId } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'
import { db } from '~/system/firebase'
import { genericDataConverter } from '~/utils/firestore'
import type { Reminder, ReminderCompletion, ReminderCompletionId, ReminderId } from '../types'

const reminders = () => db().collection('reminders').withConverter(genericDataConverter<Reminder>())

const completions = () =>
  db().collection('reminder-completions').withConverter(genericDataConverter<ReminderCompletion>())

export const findAll = async (userId: UserId): Promise<Reminder[]> => {
  const snap = await reminders().where('userId', '==', userId).orderBy('dueDate').get()
  return snap.docs.map((doc) => doc.data())
}

export const findBy = async (userId: UserId, id: ReminderId): Promise<Reminder | undefined> => {
  const snap = await reminders().doc(id).get()
  const data = snap.data()
  return data && data.userId === userId ? data : undefined
}

export const findByItem = async (userId: UserId, itemId: ItemId): Promise<Reminder[]> => {
  const snap = await reminders()
    .where('userId', '==', userId)
    .where('itemId', '==', itemId)
    .orderBy('dueDate')
    .get()
  return snap.docs.map((doc) => doc.data())
}

export const findDueBefore = async (userId: UserId, before: Date): Promise<Reminder[]> => {
  const snap = await reminders()
    .where('userId', '==', userId)
    .where('dueDate', '<=', before)
    .orderBy('dueDate')
    .get()
  return snap.docs.map((doc) => doc.data())
}

export const save = async (reminder: Reminder): Promise<Reminder> => {
  await reminders().doc(reminder.id).set(reminder)
  return reminder
}

export const remove = async (id: ReminderId): Promise<void> => {
  await reminders().doc(id).delete()
}

export const saveCompletion = async (
  completion: ReminderCompletion,
): Promise<ReminderCompletion> => {
  await completions().doc(completion.id).set(completion)
  return completion
}

export const findCompletionsByReminder = async (
  userId: UserId,
  reminderId: ReminderId,
): Promise<ReminderCompletion[]> => {
  const snap = await completions()
    .where('userId', '==', userId)
    .where('reminderId', '==', reminderId)
    .orderBy('completedAt', 'desc')
    .get()
  return snap.docs.map((doc) => doc.data())
}

export const removeCompletion = async (id: ReminderCompletionId): Promise<void> => {
  await completions().doc(id).delete()
}
