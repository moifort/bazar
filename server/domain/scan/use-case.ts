import { EntitlementQuery } from '~/domain/entitlement/query'
import { QuotaCommand } from '~/domain/quota/command'
import { QuotaQuery } from '~/domain/quota/query'
import type { UserId } from '~/domain/shared/types'
import { ScanCommand } from './command'
import type { ScanResult } from './types'

export namespace ScanUseCase {
  // The AI scan is the app's only metered action, so this is where the plan is
  // enforced. Two rules, in this order:
  //
  // 1. The allowance is checked BEFORE the AI is called — a refusal must cost
  //    nothing, neither a Gemini call nor a scan off the user's month.
  // 2. The scan is recorded AFTER the AI answered — a failed analysis is not a
  //    scan the user spent.
  export const analyze = async (
    userId: UserId,
    imageBase64: string,
  ): Promise<ScanResult | 'quota-exhausted'> => {
    const plan = await EntitlementQuery.planOf(userId)
    if (await QuotaQuery.exhaustedFor(userId, plan)) return 'quota-exhausted'

    const result = await ScanCommand.analyze(userId, imageBase64)
    await QuotaCommand.record(userId)
    return result
  }
}
