import { builder } from '~/domain/shared/graphql/builder'
import { NotificationCommand } from '../../command'

builder.mutationField('subscribeToNotifications', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Register an FCM device token for push notifications',
    args: { token: t.arg.string({ required: true }) },
    resolve: async (_root, { token }, ctx) => {
      await NotificationCommand.subscribe({ userId: ctx.userId, token, platform: 'ios' })
      return true
    },
  }),
)

builder.mutationField('unsubscribeFromNotifications', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Unregister an FCM device token from push notifications',
    args: { token: t.arg.string({ required: true }) },
    resolve: async (_root, { token }) => {
      await NotificationCommand.unsubscribe(token)
      return true
    },
  }),
)
