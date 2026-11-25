import { after, before, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection, deleteDoc, doc, getDoc, getDocs, serverTimestamp, setDoc, updateDoc,
} from 'firebase/firestore';
import { testEnv, thisYear } from './helpers.js';

let env;
let dbs = new Map();
before(async () => { env = await testEnv(); });
beforeEach(() => { dbs = new Map(); return env.clearFirestore(); });
after(() => env.cleanup());

const db = (uid) => {
  if (!dbs.has(uid)) dbs.set(uid, env.authenticatedContext(uid).firestore());
  return dbs.get(uid);
};
const seed = (data) => env.withSecurityRulesDisabled(async (ctx) => {
  for (const [path, value] of Object.entries(data)) await setDoc(doc(ctx.firestore(), path), value);
});
const member = (role) => ({ role, displayName: role, joinedAt: new Date() });

// Family f1: parents mom, dad; child kid; kid2 is a second child. Outsider: stranger.
const seedFamily = () => seed({
  'users/mom': { displayName: 'mom', role: 'parent', birthYear: thisYear - 40, locale: 'en', familyId: 'f1', createdAt: new Date() },
  'users/kid': { displayName: 'kid', role: 'child', birthYear: thisYear - 14, locale: 'en', familyId: 'f1', createdAt: new Date() },
  'families/f1': { name: 'F', createdBy: 'mom', createdAt: new Date() },
  'families/f1/members/mom': member('parent'),
  'families/f1/members/dad': member('parent'),
  'families/f1/members/kid': member('child'),
  'families/f1/members/kid2': member('child'),
});

const scores = (over = {}) => ({
  raterId: 'mom', subjectParentId: 'mom', perspective: 'self',
  warmth: 75, demandingness: 40, style: 'permissive',
  contentVersion: '1.0', createdAt: serverTimestamp(), ...over,
});
const write = (uid, over, id = 'a1') =>
  setDoc(doc(db(uid), `families/f1/assessments/${id}`), scores({ raterId: uid, ...over }));

test('a parent saves a self assessment', async () => {
  await seedFamily();
  await assertSucceeds(write('mom', {}));
});

test('a self assessment must be about yourself, and only parents make one', async () => {
  await seedFamily();
  await assertFails(write('mom', { subjectParentId: 'dad' }));
  await assertFails(write('kid', { subjectParentId: 'kid' }));
});

test('a child rates a parent; not a child, not as a parent', async () => {
  await seedFamily();
  await assertSucceeds(write('kid', { perspective: 'child_view', subjectParentId: 'dad' }));
  await assertFails(write('kid', { perspective: 'child_view', subjectParentId: 'kid2' }, 'a2'));
  await assertFails(write('kid', { perspective: 'child_view', subjectParentId: 'nobody' }, 'a3'));
  await assertFails(write('mom', { perspective: 'child_view', subjectParentId: 'dad' }, 'a4'));
});

test('raterId must be the caller', async () => {
  await seedFamily();
  await assertFails(setDoc(doc(db('kid'), 'families/f1/assessments/a1'),
    scores({ raterId: 'mom' })));
});

test('scores are 0..100 integers and the style must match the quadrant', async () => {
  await seedFamily();
  await assertFails(write('mom', { warmth: 101 }));
  await assertFails(write('mom', { demandingness: -1 }));
  await assertFails(write('mom', { warmth: 70.5 }));
  await assertFails(write('mom', { style: 'authoritative' }));
  await assertSucceeds(write('mom', { warmth: 50, demandingness: 50, style: 'authoritative' }, 'edge'));
  await assertFails(write('mom', { contentVersion: 'v1' }, 'a5'));
  await assertFails(write('mom', { extra: true }, 'a6'));
});

test('outsiders cannot write or read assessments', async () => {
  await seedFamily();
  await assertFails(write('stranger', { subjectParentId: 'stranger' }));
  await seed({ 'families/f1/assessments/x': { ...scores(), createdAt: new Date() } });
  await assertSucceeds(getDocs(collection(db('kid'), 'families/f1/assessments')));
  await assertFails(getDocs(collection(db('stranger'), 'families/f1/assessments')));
});

test('assessments cannot be edited; a lost-ack replay is accepted', async () => {
  await seedFamily();
  await assertSucceeds(write('mom', {}));
  await assertSucceeds(write('mom', {})); // same set() re-sent: only createdAt changes
  await assertFails(updateDoc(doc(db('mom'), 'families/f1/assessments/a1'), { warmth: 10 }));
});

test('the rater or a parent deletes an assessment; another child cannot', async () => {
  await seedFamily();
  await seed({ 'families/f1/assessments/k': { ...scores({ raterId: 'kid', perspective: 'child_view', subjectParentId: 'mom' }), createdAt: new Date() } });
  await assertFails(deleteDoc(doc(db('kid2'), 'families/f1/assessments/k')));
  await assertSucceeds(deleteDoc(doc(db('kid'), 'families/f1/assessments/k')));
});

// ---- users/{uid}/answers: the private item answers ----
const answers = (n = 24) => Object.fromEntries(
  Array.from({ length: n }, (_, i) => [`q${i}`, 3]));

test('a child stores their answers; parents can never read them', async () => {
  await seedFamily();
  const ref = (uid) => doc(db(uid), 'users/kid/answers/a1');
  await assertSucceeds(setDoc(ref('kid'), {
    familyId: 'f1', answers: answers(), contentVersion: '1.0', createdAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(ref('kid')));
  await assertFails(getDoc(ref('mom')));
  await assertFails(getDocs(collection(db('mom'), 'users/kid/answers')));
});

test('answers need all 24 items and cannot be written for someone else', async () => {
  await seedFamily();
  const data = (n) => ({ familyId: 'f1', answers: answers(n), contentVersion: '1.0', createdAt: serverTimestamp() });
  await assertFails(setDoc(doc(db('kid'), 'users/kid/answers/a1'), data(23)));
  await assertFails(setDoc(doc(db('mom'), 'users/kid/answers/a2'), data(24)));
});
