import { after, before, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  arrayUnion, deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc,
} from 'firebase/firestore';
import { testEnv } from './helpers.js';

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

// Family f1: mom (parent), kid and kid2 (children). Outsider: stranger.
const seedFamily = () => seed({
  'families/f1': { name: 'F', createdBy: 'mom', createdAt: new Date() },
  'families/f1/members/mom': member('parent'),
  'families/f1/members/kid': member('child'),
  'families/f1/members/kid2': member('child'),
});

const challenge = (over = {}) => ({
  adviceId: 'parent.authoritative.1', title: 'Ask one open question a day',
  createdBy: 'mom', participants: ['mom', 'kid'],
  startDate: '2026-11-19', endDate: '2026-11-25', status: 'active',
  checkIns: {}, createdAt: serverTimestamp(), ...over,
});
const ref = (uid, id = 'c1') => doc(db(uid), `families/f1/challenges/${id}`);
const seedChallenge = (over = {}) =>
  seed({ 'families/f1/challenges/c1': { ...challenge(over), createdAt: new Date() } });
const checkIn = (uid, who, date) => updateDoc(ref(uid), { [`checkIns.${who}`]: arrayUnion(date) });

test('a member starts an active challenge; outsiders cannot', async () => {
  await seedFamily();
  await assertSucceeds(setDoc(ref('kid'), challenge({ createdBy: 'kid' })));
  await assertFails(setDoc(ref('stranger', 'c2'), challenge({ createdBy: 'stranger' })));
});

test('a new challenge is active, empty, by the caller, with valid fields', async () => {
  await seedFamily();
  await assertFails(setDoc(ref('mom'), challenge({ status: 'finished' })));
  await assertFails(setDoc(ref('mom'), challenge({ createdBy: 'kid' })));
  await assertFails(setDoc(ref('mom'), challenge({ checkIns: { mom: ['2026-11-19'] } })));
  await assertFails(setDoc(ref('mom'), challenge({ participants: [] })));
  await assertFails(setDoc(ref('mom'), challenge({ startDate: '19/11/2026' })));
  await assertFails(setDoc(ref('mom'), challenge({ endDate: '2026-11-18' })));
  await assertFails(setDoc(ref('mom'), challenge({ title: '' })));
  await assertFails(setDoc(ref('mom'), challenge({ extra: 1 })));
});

test('members read challenges; outsiders cannot', async () => {
  await seedFamily();
  await seedChallenge();
  await assertSucceeds(getDoc(ref('kid2')));
  await assertFails(getDoc(ref('stranger')));
});

test('a participant checks in once per day within the week', async () => {
  await seedFamily();
  await seedChallenge();
  await assertSucceeds(checkIn('kid', 'kid', '2026-11-19'));
  await assertSucceeds(checkIn('kid', 'kid', '2026-11-20'));
  await assertFails(updateDoc(ref('kid'), { 'checkIns.kid': ['2026-11-19', '2026-11-20', '2026-11-20'] }));
  await assertFails(checkIn('kid', 'kid', '2026-11-26'));
  await assertFails(checkIn('kid', 'kid', '2026-11-18'));
  await assertFails(checkIn('kid', 'kid', 'today'));
  await assertFails(updateDoc(ref('kid'), { 'checkIns.kid': ['2026-11-19', '2026-11-20', '2026-11-21', '2026-11-22'] }));
});

test('a participant cannot edit another participant\'s check-ins', async () => {
  await seedFamily();
  await seedChallenge({ checkIns: { mom: ['2026-11-19'] } });
  await assertFails(checkIn('kid', 'mom', '2026-11-20'));
  await assertFails(updateDoc(ref('kid'), { 'checkIns.mom': [] }));
  await assertFails(updateDoc(ref('mom'), { 'checkIns.mom': [] }));
});

test('non-participants cannot check in; other fields stay fixed', async () => {
  await seedFamily();
  await seedChallenge();
  await assertFails(checkIn('kid2', 'kid2', '2026-11-19'));
  await assertFails(updateDoc(ref('kid'), { title: 'x' }));
  await assertFails(updateDoc(ref('kid'), { participants: ['mom', 'kid', 'kid2'] }));
});

test('a lost-ack replay of a check-in or a create is accepted', async () => {
  await seedFamily();
  await assertSucceeds(setDoc(ref('mom'), challenge()));
  await assertSucceeds(setDoc(ref('mom'), challenge())); // replayed create: only createdAt changes
  await assertSucceeds(checkIn('kid', 'kid', '2026-11-19'));
  await assertSucceeds(checkIn('kid', 'kid', '2026-11-19')); // arrayUnion re-sent: no change
});

test('a participant finishes the challenge; then no more check-ins', async () => {
  await seedFamily();
  await seedChallenge();
  await assertFails(updateDoc(ref('kid2'), { status: 'finished' }));
  await assertFails(updateDoc(ref('kid'), { status: 'paused' }));
  await assertSucceeds(updateDoc(ref('kid'), { status: 'finished' }));
  await assertFails(checkIn('kid', 'kid', '2026-11-20'));
  await assertFails(updateDoc(ref('kid'), { status: 'active' }));
});

test('the creator or a parent deletes a challenge; another child cannot', async () => {
  await seedFamily();
  await seedChallenge({ createdBy: 'kid' });
  await assertFails(deleteDoc(ref('kid2')));
  await assertSucceeds(deleteDoc(ref('mom'))); // dissolving the Family deletes the tree
  await seedChallenge({ createdBy: 'kid' });
  await assertSucceeds(deleteDoc(ref('kid')));
});

test('check-ins must be a list; ids and titles are bounded', async () => {
  await seedFamily();
  await assertFails(setDoc(ref('mom'), challenge({ adviceId: 'x'.repeat(101) })));
  await assertFails(setDoc(ref('mom'), challenge({ title: 'x'.repeat(301) })));
  await seedChallenge();
  await assertFails(updateDoc(ref('kid'), { 'checkIns.kid': '2026-11-19' }));
});
