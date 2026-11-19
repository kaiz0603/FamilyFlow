// Run inside the emulator: firebase emulators:exec --only firestore "npm test --prefix firebase/tests"
import { readFileSync } from 'node:fs';
import { after, before, test } from 'node:test';
import {
  assertFails,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-familyflow',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(() => env.cleanup());

test('signed-out users cannot read anything', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/alice')));
});

test('signed-in users cannot write before rules exist', async () => {
  const db = env.authenticatedContext('alice').firestore();
  await assertFails(setDoc(doc(db, 'users/alice'), { displayName: 'Alice' }));
});
