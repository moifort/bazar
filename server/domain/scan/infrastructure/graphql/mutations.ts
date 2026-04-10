import { builder } from '~/domain/shared/graphql/builder'
import * as scanRepository from '../../infrastructure/repository'
import { analyzePhoto } from '../../scanner'
import { ItemPreviewType } from './types'

builder.mutationField('analyzeItemPhoto', (t) =>
  t.field({
    type: [ItemPreviewType],
    description: 'Analyze a photo with Gemini AI to identify household items',
    args: {
      imageBase64: t.arg.string({
        required: true,
        description: 'Photo as base64 encoded JPEG',
      }),
    },
    resolve: async (_root, { imageBase64 }) => {
      const result = await analyzePhoto(imageBase64)
      await scanRepository.save(result)
      return result.previews
    },
  }),
)
