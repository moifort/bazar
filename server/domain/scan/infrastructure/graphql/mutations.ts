import { match, P } from 'ts-pattern'
import { builder } from '~/domain/shared/graphql/builder'
import { domainError } from '~/domain/shared/graphql/errors'
import { ScanUseCase } from '../../use-case'
import { ItemPreviewType } from './types'

builder.mutationField('analyzeItemPhoto', (t) =>
  t.field({
    type: [ItemPreviewType],
    description: [
      'Analyze a photo with Gemini AI to identify household items. Nothing is stored in the ' +
        'inventory: the answer is a batch of previews, confirmed or thrown away afterwards.',
      '',
      'This is the one metered action. Answers `QUOTA_EXHAUSTED` when the plan allows no ' +
        'further scan — see the `quota` query for what is left.',
    ].join('\n'),
    args: {
      imageBase64: t.arg.string({
        required: true,
        description: 'Photo as base64 encoded JPEG',
      }),
    },
    resolve: async (_root, { imageBase64 }, ctx) =>
      match(await ScanUseCase.analyze(ctx.userId, imageBase64))
        .with('quota-exhausted', domainError)
        .with(P.not(P.string), (result) => result.previews)
        .exhaustive(),
  }),
)
