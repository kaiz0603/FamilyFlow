// A second family member for manual testing against the local emulators, so one
// phone emulator is enough for two-person flows. It writes exactly what the app writes.
//
//   node firebase/tests/scripts/actor.mjs child <email> <name>   sign up a 14-year-old Child
//   node firebase/tests/scripts/actor.mjs join <email> <code>    send a Join Request
//   node firebase/tests/scripts/actor.mjs complete <email>       finish joining after approval
//   node firebase/tests/scripts/actor.mjs show <email>           print profile and membership
//   node firebase/tests/scripts/actor.mjs assess <email> <parentUid> <1..5>
//                                     save a Child View answering every item with that value
import { readFileSync } from 'node:fs';
import { initializeApp } from 'firebase/app';
import {
  connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signInWithEmailAndPassword,
} from 'firebase/auth';
import {
  collection, connectFirestoreEmulator, doc, getDoc, getFirestore, serverTimestamp, setDoc, Timestamp,
  writeBatch,
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

switch (cmd) {
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
  default:
    console.log('commands: child | join | complete | show | assess');
}
process.exit(0);
