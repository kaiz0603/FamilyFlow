// A second family member for manual testing against the local emulators, so one
// phone emulator is enough for two-person flows. It writes exactly what the app writes.
//
//   node firebase/tests/scripts/actor.mjs parent <email> <name> <family>
//                                     sign up a 40-year-old Parent, create a Family, print an Invite Code
//   node firebase/tests/scripts/actor.mjs child <email> <name>   sign up a 14-year-old Child
//   node firebase/tests/scripts/actor.mjs join <email> <code>    send a Join Request
//   node firebase/tests/scripts/actor.mjs complete <email>       finish joining after approval
//   node firebase/tests/scripts/actor.mjs show <email>           print profile and membership
//   node firebase/tests/scripts/actor.mjs assess <email> <parentUid> <1..5>
//                                     save a Child View answering every item with that value
//   node firebase/tests/scripts/actor.mjs checkin <email> [YYYY-MM-DD]
//                                     check in to the newest active Challenge (default: today, local)
import { readFileSync } from 'node:fs';
import { initializeApp } from 'firebase/app';
import {
  connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signInWithEmailAndPassword,
} from 'firebase/auth';
import {
  arrayUnion, collection, connectFirestoreEmulator, doc, getDoc, getDocs, getFirestore, limit, orderBy,
  query, serverTimestamp, setDoc, Timestamp, updateDoc, where, writeBatch,
} from 'firebase/firestore';

const PASSWORD = 'testpass123'; // emulator-only test account
const app = initializeApp({ projectId: 'demo-familyflow', apiKey: 'demo-api-key' });
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const db = getFirestore(app);
connectFirestoreEmulator(db, '127.0.0.1', 8080);

const [cmd, email, arg, arg2] = process.argv.slice(2);
const signIn = async () => (await signInWithEmailAndPassword(auth, email, PASSWORD)).user.uid;
const profileOf = async (uid) => (await getDoc(doc(db, `users/${uid}`))).data();

const localDate = (t = new Date()) =>
  `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}`;

switch (cmd) {
  case 'parent': {
    const { user } = await createUserWithEmailAndPassword(auth, email, PASSWORD);
    const uid = user.uid;
    await setDoc(doc(db, `users/${uid}`), {
      displayName: arg, role: 'parent', birthYear: new Date().getFullYear() - 40,
      locale: 'en', familyId: null, createdAt: serverTimestamp(),
    });
    const fid = doc(collection(db, 'families')).id;
    const b = writeBatch(db);
    b.set(doc(db, `families/${fid}`), { name: arg2 ?? 'Family', createdBy: uid, createdAt: serverTimestamp(), memberIds: [uid] });
    b.set(doc(db, `families/${fid}/members/${uid}`), { role: 'parent', displayName: arg, joinedAt: serverTimestamp() });
    b.update(doc(db, `users/${uid}`), { familyId: fid });
    await b.commit();
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    const code = Array.from({ length: 6 }, () => alphabet[Math.floor(Math.random() * alphabet.length)]).join('');
    await setDoc(doc(db, `invites/${code}`), {
      familyId: fid, createdBy: uid, expiresAt: Timestamp.fromMillis(Date.now() + 6 * 86400000),
    });
    console.log('parent created', { uid, fid, code });
    break;
  }
  case 'child': {
    const { user } = await createUserWithEmailAndPassword(auth, email, PASSWORD);
    await setDoc(doc(db, `users/${user.uid}`), {
      displayName: arg, role: 'child', birthYear: new Date().getFullYear() - 14,
      locale: 'en', familyId: null, createdAt: serverTimestamp(),
    });
    console.log('child created', user.uid);
    break;
  }
  case 'join': {
    const uid = await signIn();
    const me = await profileOf(uid);
    const invite = (await getDoc(doc(db, `invites/${arg}`))).data();
    const b = writeBatch(db);
    b.set(doc(db, `families/${invite.familyId}/joinRequests/${uid}`), {
      code: arg, role: me.role, displayName: me.displayName, status: 'pending',
      createdAt: serverTimestamp(),
    });
    b.update(doc(db, `users/${uid}`), { pendingFamilyId: invite.familyId });
    await b.commit();
    console.log('requested', invite.familyId);
    break;
  }
  case 'complete': {
    const uid = await signIn();
    const fid = (await profileOf(uid)).pendingFamilyId;
    const req = (await getDoc(doc(db, `families/${fid}/joinRequests/${uid}`))).data();
    if (req?.status !== 'approved') throw new Error(`request is ${req?.status}`);
    const b = writeBatch(db);
    b.update(doc(db, `users/${uid}`), { familyId: fid, pendingFamilyId: null });
    b.delete(doc(db, `families/${fid}/joinRequests/${uid}`));
    b.set(doc(db, `families/${fid}/activity/joined-${uid}`), {
      type: 'member_joined', actorId: uid, refId: null, createdAt: serverTimestamp(),
      expireAt: Timestamp.fromMillis(Date.now() + 90 * 86400000),
    });
    await b.commit();
    console.log('joined', fid);
    break;
  }
  case 'show': {
    const uid = await signIn();
    const me = await profileOf(uid);
    let member = 'n/a';
    if (me.familyId) {
      member = await getDoc(doc(db, `families/${me.familyId}/members/${uid}`))
        .then((s) => (s.exists() ? 'yes' : 'no'), (e) => `no access (${e.code})`);
    }
    console.log({ familyId: me.familyId, pendingFamilyId: me.pendingFamilyId ?? null, member });
    break;
  }
  case 'assess': {
    // Mirrors lib/domain/assessment/scoring.dart score() and AssessmentRepository.save.
    const answer = Number(arg2);
    if (!Number.isInteger(answer) || answer < 1 || answer > 5) throw new Error('answer must be 1..5');
    const content = JSON.parse(readFileSync(
      new URL('../../../assets/content/assessment.en.json', import.meta.url), 'utf8'));
    const items = content.forms.child_view;
    const scoreOf = (dim) => {
      const vals = items.filter((i) => i.dimension === dim).map((i) => (i.reverse ? 6 - answer : answer));
      return Math.round((vals.reduce((a, b) => a + b, 0) / vals.length - 1) / 4 * 100);
    };
    const warmth = scoreOf('warmth');
    const demandingness = scoreOf('demandingness');
    const style = warmth >= 50
      ? (demandingness >= 50 ? 'authoritative' : 'permissive')
      : (demandingness >= 50 ? 'authoritarian' : 'neglectful');
    const uid = await signIn();
    const fid = (await profileOf(uid)).familyId;
    const ref = doc(collection(db, `families/${fid}/assessments`));
    const b = writeBatch(db);
    b.set(doc(db, `users/${uid}/answers/${ref.id}`), {
      familyId: fid, answers: Object.fromEntries(items.map((i) => [i.id, answer])),
      contentVersion: content.contentVersion, createdAt: serverTimestamp(),
    });
    b.set(ref, {
      raterId: uid, subjectParentId: arg, perspective: 'child_view', warmth, demandingness,
      style, contentVersion: content.contentVersion, createdAt: serverTimestamp(),
    });
    b.set(doc(collection(db, `families/${fid}/activity`)), {
      type: 'assessment_done', actorId: uid, refId: ref.id, createdAt: serverTimestamp(),
      expireAt: Timestamp.fromMillis(Date.now() + 90 * 86400000),
    });
    await b.commit();
    console.log('assessed', { warmth, demandingness, style });
    break;
  }
  case 'checkin': {
    // Mirrors ChallengeRepository.checkIn.
    const uid = await signIn();
    const fid = (await profileOf(uid)).familyId;
    const found = await getDocs(query(collection(db, `families/${fid}/challenges`),
      where('status', '==', 'active'), orderBy('createdAt', 'desc'), limit(1)));
    if (found.empty) throw new Error('no active Challenge');
    const day = arg ?? localDate();
    await updateDoc(found.docs[0].ref, { [`checkIns.${uid}`]: arrayUnion(day) });
    console.log('checked in', found.docs[0].id, day);
    break;
  }
  default:
    console.log('commands: parent | child | join | complete | show | assess | checkin');
}
process.exit(0);
