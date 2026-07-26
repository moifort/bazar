// Accent- and case-insensitive form of a label. Two domains compare French
// words the user never typed the same way twice, so the fold lives here rather
// than being duplicated in each of them: decompose, drop the combining marks
// (Unicode category Mark), lowercase, collapse the spacing.
export const normalizeText = (text: string) =>
  text.normalize('NFD').replace(/\p{M}/gu, '').toLowerCase().trim().replace(/\s+/g, ' ')
