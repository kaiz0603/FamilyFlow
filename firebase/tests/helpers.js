import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

export const testEnv = () =>
  initializeTestEnvironment({
    projectId: 'demo-familyflow',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });

export const thisYear = new Date().getUTCFullYear();
