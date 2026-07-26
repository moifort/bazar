import { match, P } from 'ts-pattern'
import { builder } from '~/domain/shared/graphql/builder'
import { domainError } from '~/domain/shared/graphql/errors'
import { UserUseCase } from '~/domain/user/use-case'
import { CompleteOnboardingInput } from './inputs'
import { UserType } from './types'

builder.mutationField('completeOnboarding', (t) =>
  t.field({
    type: UserType,
    description: [
      'Close the first launch: record how to call you, create your first house and the rooms ' +
        'you picked, all at once. Everything that follows has somewhere to go.',
      '',
      'Answers `ALREADY_ONBOARDED` when you have already been through it — running it twice ' +
        'would hand you a second house.',
      '',
      '```graphql',
      'completeOnboarding(input: {',
      '  firstName: "Thibaut"',
      '  houseName: "Maison"',
      '  houseIcon: "🏠"',
      '  rooms: [{ name: "Cuisine", icon: "🍳" }]',
      '}) {',
      '  firstName',
      '}',
      '```',
    ].join('\n'),
    args: {
      input: t.arg({ type: CompleteOnboardingInput, required: true }),
    },
    resolve: async (_root, { input }, { userId }) => {
      const result = await UserUseCase.onboard(userId, {
        firstName: input.firstName,
        ...(input.houseName
          ? { house: { name: input.houseName, icon: input.houseIcon ?? undefined } }
          : {}),
        rooms: input.rooms.map((room) => ({ name: room.name, icon: room.icon ?? undefined })),
      })
      return match(result)
        .with('already-onboarded', domainError)
        .with(P.not(P.string), (user) => user)
        .exhaustive()
    },
  }),
)
