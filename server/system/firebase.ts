import { getApps, initializeApp } from 'firebase-admin/app'
import { getFirestore } from 'firebase-admin/firestore'

if (getApps().length === 0) {
  initializeApp()
  getFirestore().settings({ ignoreUndefinedProperties: true })
}

export const db = () => getFirestore()
