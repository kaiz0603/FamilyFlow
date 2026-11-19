import { after, before, test } from 'node:test';
import { assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { testEnv } from './helpers.js';

let env;
before(async () => { env = await testEnv(); });
after(() => env.cleanup());

test('signed-out users cannot read profiles', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/alice')));
});

test('collections without rules stay closed', async () => {
  const db = env.authenticatedContext('alice').firestore();
  await assertFails(setDoc(doc(db, 'families/f1'), { name: 'x' }));
  await assertFails(getDoc(doc(db, 'families/f1')));
});
