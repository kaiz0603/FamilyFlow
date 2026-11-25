import { after, before, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc,
} from 'firebase/firestore';
import { testEnv, thisYear } from './helpers.js';

let env;
before(async () => { env = await testEnv(); });
beforeEach(() => env.clearFirestore());
after(() => env.cleanup());

const db = (uid) => env.authenticatedContext(uid).firestore();
const profile = (overrides = {}) => ({
  displayName: 'Alice',
  role: 'parent',
  birthYear: thisYear - 40,
  locale: 'en',
  familyId: null,
  createdAt: serverTimestamp(),
  ...overrides,
});
const seed = (uid, data) =>
  env.withSecurityRulesDisabled((ctx) =>
    setDoc(doc(ctx.firestore(), `users/${uid}`), { ...data, createdAt: new Date() }));

test('a parent creates their own profile', async () => {
  await assertSucceeds(setDoc(doc(db('alice'), 'users/alice'), profile()));
});

test('a 13-year-old child can sign up', async () => {
  await assertSucceeds(setDoc(doc(db('kid'), 'users/kid'),
    profile({ role: 'child', birthYear: thisYear - 13 })));
});

test('under 13 is rejected', async () => {
  await assertFails(setDoc(doc(db('kid'), 'users/kid'),
    profile({ role: 'child', birthYear: thisYear - 12 })));
});

test('a parent must be 18 or older', async () => {
  await assertFails(setDoc(doc(db('teen'), 'users/teen'),
    profile({ role: 'parent', birthYear: thisYear - 17 })));
});

test('nobody creates a profile for someone else', async () => {
  await assertFails(setDoc(doc(db('mallory'), 'users/alice'), profile()));
});

test('profile shape is checked on create', async () => {
  const ref = doc(db('alice'), 'users/alice');
  await assertFails(setDoc(ref, profile({ role: 'admin' })));
  await assertFails(setDoc(ref, profile({ displayName: '' })));
  await assertFails(setDoc(ref, profile({ displayName: 'x'.repeat(31) })));
  await assertFails(setDoc(ref, profile({ locale: 'fr' })));
  await assertFails(setDoc(ref, profile({ familyId: 'f1' })));
  await assertFails(setDoc(ref, profile({ isAdmin: true })));
  await assertFails(setDoc(ref, profile({ createdAt: new Date(0) })));
});

test('only the owner reads a profile', async () => {
  await seed('alice', profile());
  await assertSucceeds(getDoc(doc(db('alice'), 'users/alice')));
  await assertFails(getDoc(doc(db('bob'), 'users/alice')));
});

test('owner can change display name and language', async () => {
  await seed('alice', profile());
  await assertSucceeds(updateDoc(doc(db('alice'), 'users/alice'),
    { displayName: 'Ali', locale: 'zh' }));
});

test('role and birth year are fixed after sign-up', async () => {
  await seed('kid', profile({ role: 'child', birthYear: thisYear - 14 }));
  const ref = doc(db('kid'), 'users/kid');
  await assertFails(updateDoc(ref, { role: 'parent' }));
  await assertFails(updateDoc(ref, { birthYear: thisYear - 30 }));
  await assertFails(updateDoc(ref, { createdAt: serverTimestamp() }));
});

test('familyId cannot point at a family the user is not a member of', async () => {
  await seed('alice', profile());
  await assertFails(updateDoc(doc(db('alice'), 'users/alice'), { familyId: 'f1' }));
});

test('owner deletes their own profile, others cannot', async () => {
  await seed('alice', profile());
  await assertFails(deleteDoc(doc(db('bob'), 'users/alice')));
  await assertSucceeds(deleteDoc(doc(db('alice'), 'users/alice')));
});
