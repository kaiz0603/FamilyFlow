import { after, before, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  arrayRemove, arrayUnion, collection, deleteDoc, doc, getDoc, getDocs, query,
  serverTimestamp, setDoc, Timestamp, updateDoc, where, writeBatch,
} from 'firebase/firestore';
import { testEnv, thisYear } from './helpers.js';

let env;
before(async () => { env = await testEnv(); });
// One Firestore instance per user per test: a batch cannot mix instances.
let dbs = new Map();
beforeEach(() => { dbs = new Map(); return env.clearFirestore(); });
after(() => env.cleanup());

const db = (uid) => {
  if (!dbs.has(uid)) dbs.set(uid, env.authenticatedContext(uid).firestore());
  return dbs.get(uid);
};
const inDays = (d) => Timestamp.fromMillis(Date.now() + d * 86400000);
const seed = (data) => env.withSecurityRulesDisabled(async (ctx) => {
  const sdb = ctx.firestore();
  for (const [path, value] of Object.entries(data)) await setDoc(doc(sdb, path), value);
});
const user = (role, extra = {}) => ({
  displayName: role === 'parent' ? 'Pat' : 'Kim', role,
  birthYear: thisYear - (role === 'parent' ? 40 : 14), locale: 'en',
  familyId: null, createdAt: new Date(), ...extra,
});
const member = (role, name = 'X') => ({ role, displayName: name, joinedAt: new Date() });

// A family f1 with parent "mom" and child "kid"; outsiders "dad" (parent) and "teen" (child).
async function seedFamily() {
  await seed({
    'users/mom': user('parent', { familyId: 'f1', displayName: 'Mom' }),
    'users/kid': user('child', { familyId: 'f1', displayName: 'Kid' }),
    'users/dad': user('parent', { displayName: 'Dad' }),
    'users/teen': user('child', { displayName: 'Teen' }),
    'families/f1': { name: 'Lins', createdBy: 'mom', createdAt: new Date(), memberIds: ['mom', 'kid'] },
    'families/f1/members/mom': member('parent', 'Mom'),
    'families/f1/members/kid': member('child', 'Kid'),
    'invites/ABC234': { familyId: 'f1', createdBy: 'mom', expiresAt: inDays(7) },
    'invites/OLD234': { familyId: 'f1', createdBy: 'mom', expiresAt: inDays(-1) },
  });
}

const createFamilyBatch = (uid, name = 'Mine', fid = 'f2') => {
  const b = writeBatch(db(uid));
  b.set(doc(db(uid), `families/${fid}`), { name, createdBy: uid, createdAt: serverTimestamp(), memberIds: [uid] });
  b.set(doc(db(uid), `families/${fid}/members/${uid}`),
    { role: 'parent', displayName: 'Dad', joinedAt: serverTimestamp() });
  b.update(doc(db(uid), `users/${uid}`), { familyId: fid });
  return b.commit();
};

const joinRequest = (role, name, code = 'ABC234') =>
  ({ code, role, displayName: name, status: 'pending', createdAt: serverTimestamp() });

// ---- families ----
test('a parent without a family creates one (family + own member + profile in one batch)', async () => {
  await seedFamily();
  await assertSucceeds(createFamilyBatch('dad'));
});

test('a child cannot create a family', async () => {
  await seedFamily();
  await assertFails(createFamilyBatch('teen'));
});

test('a parent already in a family cannot create another', async () => {
  await seedFamily();
  await assertFails(createFamilyBatch('mom'));
});

test('family name is limited to 40 characters', async () => {
  await seedFamily();
  await assertFails(createFamilyBatch('dad', 'x'.repeat(41)));
});

test('only members read the family and its members', async () => {
  await seedFamily();
  await assertSucceeds(getDoc(doc(db('kid'), 'families/f1')));
  await assertSucceeds(getDocs(collection(db('kid'), 'families/f1/members')));
  await assertFails(getDoc(doc(db('dad'), 'families/f1')));
  await assertFails(getDocs(collection(db('dad'), 'families/f1/members')));
});

test('parents rename the family, children cannot', async () => {
  await seedFamily();
  await assertSucceeds(updateDoc(doc(db('mom'), 'families/f1'), { name: 'Lin family' }));
  await assertFails(updateDoc(doc(db('kid'), 'families/f1'), { name: 'Kid rules' }));
  await assertFails(updateDoc(doc(db('mom'), 'families/f1'), { createdBy: 'kid' }));
});

test('profile familyId can only point at a family the user is a member of', async () => {
  await seedFamily();
  await assertFails(updateDoc(doc(db('dad'), 'users/dad'), { familyId: 'f1' }));
  await assertSucceeds(updateDoc(doc(db('kid'), 'users/kid'), { familyId: null }));
});

// ---- invites ----
test('a parent member creates an invite; a child or outsider cannot', async () => {
  await seedFamily();
  const invite = (uid) => ({ familyId: 'f1', createdBy: uid, expiresAt: inDays(7) });
  await assertSucceeds(setDoc(doc(db('mom'), 'invites/NEW234'), invite('mom')));
  await assertFails(setDoc(doc(db('kid'), 'invites/KID234'), invite('kid')));
  await assertFails(setDoc(doc(db('dad'), 'invites/DAD234'), invite('dad')));
});

test('invites expire within 7 days and use the code alphabet', async () => {
  await seedFamily();
  const mom = db('mom');
  await assertFails(setDoc(doc(mom, 'invites/LONG23'), { familyId: 'f1', createdBy: 'mom', expiresAt: inDays(8) }));
  await assertFails(setDoc(doc(mom, 'invites/abc234'), { familyId: 'f1', createdBy: 'mom', expiresAt: inDays(7) }));
  await assertFails(setDoc(doc(mom, 'invites/ABC0O1'), { familyId: 'f1', createdBy: 'mom', expiresAt: inDays(7) }));
});

test('an existing invite code cannot be overwritten (collision = retry)', async () => {
  await seedFamily();
  await assertFails(setDoc(doc(db('mom'), 'invites/ABC234'), { familyId: 'f1', createdBy: 'mom', expiresAt: inDays(7) }));
});

test('anyone signed in can look up one code; only parents list their family\'s codes', async () => {
  await seedFamily();
  await assertSucceeds(getDoc(doc(db('teen'), 'invites/ABC234')));
  await assertFails(getDocs(collection(db('teen'), 'invites')));
  await assertFails(getDocs(query(collection(db('kid'), 'invites'), where('familyId', '==', 'f1'))));
  await assertSucceeds(getDocs(query(collection(db('mom'), 'invites'), where('familyId', '==', 'f1'))));
});

// ---- join requests ----
const requestBatch = (uid, role, name, code = 'ABC234') => {
  const b = writeBatch(db(uid));
  b.set(doc(db(uid), `families/f1/joinRequests/${uid}`), joinRequest(role, name, code));
  b.update(doc(db(uid), `users/${uid}`), { pendingFamilyId: 'f1' });
  return b.commit();
};

test('an outsider requests to join with a valid code', async () => {
  await seedFamily();
  await assertSucceeds(requestBatch('teen', 'child', 'Teen'));
});

test('an expired or wrong-family code cannot create a request', async () => {
  await seedFamily();
  await seed({ 'invites/OTH234': { familyId: 'f9', createdBy: 'x', expiresAt: inDays(7) } });
  await assertFails(requestBatch('teen', 'child', 'Teen', 'OLD234'));
  await assertFails(requestBatch('teen', 'child', 'Teen', 'OTH234'));
  await assertFails(requestBatch('teen', 'child', 'Teen', 'NONE23'));
});

test('a request must copy the profile role and name', async () => {
  await seedFamily();
  await assertFails(requestBatch('teen', 'parent', 'Teen'));
  await assertFails(requestBatch('teen', 'child', 'Somebody else'));
});

test('members and people already in a family cannot request', async () => {
  await seedFamily();
  await assertFails(requestBatch('kid', 'child', 'Kid'));
});

test('the requester and parents read a request; others cannot', async () => {
  await seedFamily();
  await seed({ 'families/f1/joinRequests/teen': { ...joinRequest('child', 'Teen'), createdAt: new Date() } });
  const path = 'families/f1/joinRequests/teen';
  await assertSucceeds(getDoc(doc(db('teen'), path)));
  await assertSucceeds(getDoc(doc(db('mom'), path)));
  await assertFails(getDoc(doc(db('kid'), path)));
  await assertFails(getDoc(doc(db('dad'), path)));
});

// ---- approval ----
const approveBatch = (by, uid, role = 'child', name = 'Teen', addToList = true) => {
  const b = writeBatch(db(by));
  b.set(doc(db(by), `families/f1/members/${uid}`), { role, displayName: name, joinedAt: serverTimestamp() });
  b.update(doc(db(by), `families/f1/joinRequests/${uid}`), { status: 'approved' });
  if (addToList) b.update(doc(db(by), 'families/f1'), { memberIds: arrayUnion(uid) });
  return b.commit();
};

test('a parent approves a pending request; the joiner then sets familyId', async () => {
  await seedFamily();
  await seed({
    'users/teen': user('child', { displayName: 'Teen', pendingFamilyId: 'f1' }),
    'families/f1/joinRequests/teen': { ...joinRequest('child', 'Teen'), createdAt: new Date() },
  });
  await assertSucceeds(approveBatch('mom', 'teen'));
  const b = writeBatch(db('teen'));
  b.update(doc(db('teen'), 'users/teen'), { familyId: 'f1', pendingFamilyId: null });
  b.delete(doc(db('teen'), 'families/f1/joinRequests/teen'));
  b.set(doc(db('teen'), 'families/f1/activity/a1'), {
    type: 'member_joined', actorId: 'teen', refId: null,
    createdAt: serverTimestamp(), expireAt: inDays(90),
  });
  await assertSucceeds(b.commit());
});

test('a child cannot approve, and nobody becomes a member without a request', async () => {
  await seedFamily();
  await seed({ 'families/f1/joinRequests/teen': { ...joinRequest('child', 'Teen'), createdAt: new Date() } });
  await assertFails(approveBatch('kid', 'teen'));
  await assertFails(approveBatch('mom', 'dad', 'parent', 'Dad'));
  await assertFails(setDoc(doc(db('teen'), 'families/f1/members/teen'), member('child', 'Teen')));
});

test('approval must add the new member to memberIds', async () => {
  await seedFamily();
  await seed({ 'families/f1/joinRequests/teen': { ...joinRequest('child', 'Teen'), createdAt: new Date() } });
  await assertFails(approveBatch('mom', 'teen', 'child', 'Teen', false));
});

test('approval must keep the requested role', async () => {
  await seedFamily();
  await seed({ 'families/f1/joinRequests/teen': { ...joinRequest('child', 'Teen'), createdAt: new Date() } });
  await assertFails(approveBatch('mom', 'teen', 'parent'));
});

test('a parent rejects; the requester cannot approve themselves', async () => {
  await seedFamily();
  await seed({ 'families/f1/joinRequests/teen': { ...joinRequest('child', 'Teen'), createdAt: new Date() } });
  await assertFails(updateDoc(doc(db('teen'), 'families/f1/joinRequests/teen'), { status: 'approved' }));
  await assertSucceeds(updateDoc(doc(db('mom'), 'families/f1/joinRequests/teen'), { status: 'rejected' }));
});

// ---- leaving and removing ----
test('a member leaves; a parent removes a member; a child cannot remove anyone', async () => {
  await seedFamily();
  await seed({ 'families/f1/members/teen': member('child', 'Teen') });
  await assertFails(deleteDoc(doc(db('kid'), 'families/f1/members/teen')));
  await assertSucceeds(deleteDoc(doc(db('kid'), 'families/f1/members/kid')));
  await assertSucceeds(deleteDoc(doc(db('mom'), 'families/f1/members/teen')));
});

test('members only rename themselves', async () => {
  await seedFamily();
  await assertSucceeds(updateDoc(doc(db('kid'), 'families/f1/members/kid'), { displayName: 'Kiddo' }));
  await assertFails(updateDoc(doc(db('kid'), 'families/f1/members/kid'), { role: 'parent' }));
  await assertFails(updateDoc(doc(db('mom'), 'families/f1/members/kid'), { displayName: 'Bob' }));
});

// Leaving or removing takes the uid out of memberIds in the same batch.
const removeBatch = (by, uid) => {
  const b = writeBatch(db(by));
  b.delete(doc(db(by), `families/f1/members/${uid}`));
  b.update(doc(db(by), 'families/f1'), { memberIds: arrayRemove(uid) });
  return b.commit();
};
const deleteFamilyBatch = (uid) => {
  const b = writeBatch(db(uid));
  b.delete(doc(db(uid), 'families/f1'));
  b.delete(doc(db(uid), `families/f1/members/${uid}`));
  return b.commit();
};

test('memberIds only drops a uid whose member doc goes, and only adds one that arrives', async () => {
  await seedFamily();
  const f1 = (uid) => doc(db(uid), 'families/f1');
  await assertFails(updateDoc(f1('kid'), { memberIds: arrayRemove('mom') }));
  await assertFails(updateDoc(f1('mom'), { memberIds: arrayRemove('kid') }));
  await assertFails(updateDoc(f1('mom'), { memberIds: arrayUnion('dad') }));
  await assertFails(updateDoc(f1('mom'), { memberIds: ['mom'] }));
  await assertFails(updateDoc(f1('dad'), { memberIds: arrayRemove('kid') }));
  await assertSucceeds(updateDoc(f1('kid'), { memberIds: arrayUnion('kid') })); // a replay changes nothing
  await assertSucceeds(removeBatch('kid', 'kid'));
});

test('a parent removes a member together with the memberIds entry', async () => {
  await seedFamily();
  await assertFails(removeBatch('kid', 'mom'));
  await assertSucceeds(removeBatch('mom', 'kid'));
});

test('the family document goes only with its last member, a parent', async () => {
  await seedFamily();
  await seed({
    'families/f1/members/dad': member('parent', 'Dad'),
    'families/f1': { name: 'Lins', createdBy: 'mom', createdAt: new Date(), memberIds: ['mom', 'kid', 'dad'] },
  });
  await assertFails(deleteDoc(doc(db('mom'), 'families/f1')));
  await assertFails(deleteFamilyBatch('mom'));
  await assertSucceeds(removeBatch('mom', 'kid'));
  await assertFails(deleteFamilyBatch('mom')); // dad is still a Parent
  await assertSucceeds(removeBatch('mom', 'dad'));
  await assertFails(deleteDoc(doc(db('mom'), 'families/f1'))); // own member doc must go too
  await assertSucceeds(deleteFamilyBatch('mom'));
});

test('a child who is the last member cannot delete the family', async () => {
  await seedFamily();
  await seed({ 'families/f1': { name: 'Lins', createdBy: 'mom', createdAt: new Date(), memberIds: ['kid'] } });
  await assertFails(deleteFamilyBatch('kid'));
});

test('nobody can delete a family doc to re-found it and read what is left', async () => {
  await seedFamily();
  await assertFails(deleteDoc(doc(db('mom'), 'families/f1')));
  await assertFails(createFamilyBatch('dad', 'Mine', 'f1'));
  await assertFails(getDocs(collection(db('dad'), 'families/f1/members')));
});

// ---- activity ----
test('members write their own activity; nobody edits it', async () => {
  await seedFamily();
  const entry = (actorId) => ({
    type: 'member_left', actorId, refId: null, createdAt: serverTimestamp(), expireAt: inDays(90),
  });
  await assertSucceeds(setDoc(doc(db('kid'), 'families/f1/activity/a1'), entry('kid')));
  await assertFails(setDoc(doc(db('kid'), 'families/f1/activity/a2'), entry('mom')));
  await assertFails(setDoc(doc(db('dad'), 'families/f1/activity/a3'), entry('dad')));
  await assertFails(updateDoc(doc(db('kid'), 'families/f1/activity/a1'), { type: 'member_joined' }));
  await assertSucceeds(getDocs(collection(db('mom'), 'families/f1/activity')));
  await assertFails(getDocs(collection(db('dad'), 'families/f1/activity')));
});

test('a re-sent activity write (lost acknowledgement) is accepted, other edits are not', async () => {
  await seedFamily();
  const entry = { type: 'member_left', actorId: 'mom', refId: 'kid', expireAt: inDays(90) };
  const ref = doc(db('mom'), 'families/f1/activity/a1');
  await assertSucceeds(setDoc(ref, { ...entry, createdAt: serverTimestamp() }));
  await assertSucceeds(setDoc(ref, { ...entry, createdAt: serverTimestamp(), expireAt: inDays(91) }));
  await assertFails(setDoc(ref, { ...entry, type: 'member_joined', createdAt: serverTimestamp() }));
  await assertFails(setDoc(doc(db('kid'), 'families/f1/activity/a1'), { ...entry, createdAt: serverTimestamp() }));
});
