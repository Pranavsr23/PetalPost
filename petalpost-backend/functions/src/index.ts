import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {
  awardPoints,
  pointsForFavorite,
  pointsForRead,
  pointsForReact,
  pointsForSend,
  updateStreak,
} from "./points";

admin.initializeApp();

const firestore = admin.firestore();

export const onNoteCreated = functions.firestore
  .document("spaces/{spaceId}/notes/{noteId}")
  .onCreate(async (snap, context) => {
    const note = snap.data();
    const spaceId = context.params.spaceId as string;
    const noteId = context.params.noteId as string;

    const spaceRef = firestore.collection("spaces").doc(spaceId);
    const spaceSnap = await spaceRef.get();
    if (!spaceSnap.exists) return;
    const space = spaceSnap.data() ?? {};
    const participants = (space.participantUids as string[]) ?? [];

    const preview = buildPreview(note);
    await spaceRef.set(
      {
        lastNoteId: noteId,
        lastNotePreview: preview,
        lastNoteAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    await awardPoints(note.senderUid, pointsForSend());
    await updateStreak(note.senderUid);

    const recipientUids = participants.filter((uid) => uid !== note.senderUid);
    await sendNotification(recipientUids, {
      title: "New PetalPost",
      body: preview,
      data: {
        spaceId,
        noteId,
        type: note.type ?? "text",
        surprise: String(note.surprise ?? false),
      },
    });
  });

export const onNoteUpdated = functions.firestore
  .document("spaces/{spaceId}/notes/{noteId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    await handleReadPoints(before.readBy ?? {}, after.readBy ?? {});
    await handleReactionPoints(before.reactions ?? {}, after.reactions ?? {});
    await handleFavoritePoints(before.isFavoriteBy ?? {}, after.isFavoriteBy ?? {});
  });

export const notifyTimeCapsules = functions.pubsub
  .schedule("every 15 minutes")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const query = await firestore
      .collectionGroup("notes")
      .where("timeCapsule", "==", true)
      .where("unlockAt", "<=", now)
      .where("unlockNotified", "!=", true)
      .limit(50)
      .get();

    const batch = firestore.batch();
    for (const doc of query.docs) {
      const note = doc.data();
      const spaceRef = doc.ref.parent.parent;
      if (!spaceRef) continue;
      const spaceSnap = await spaceRef.get();
      const participants = (spaceSnap.get("participantUids") as string[]) ?? [];
      const recipients = participants.filter((uid) => uid !== note.senderUid);
      await sendNotification(recipients, {
        title: "Time capsule opened",
        body: "Tap to reveal your note.",
        data: {
          spaceId: spaceRef.id,
          noteId: doc.id,
          type: note.type ?? "text",
        },
      });
      batch.set(doc.ref, { unlockNotified: true }, { merge: true });
    }
    await batch.commit();
    return null;
  });

function buildPreview(note: FirebaseFirestore.DocumentData) {
  if (note.type === "text" && note.text) {
    return note.text.length > 80 ? `${note.text.substring(0, 80)}...` : note.text;
  }
  if (note.type === "handwriting") return "Handwritten note";
  if (note.type === "voice") return "Voice note";
  return "New note";
}

async function sendNotification(
  userIds: string[],
  payload: { title: string; body: string; data?: Record<string, string> },
) {
  if (userIds.length === 0) return;
  const tokens: string[] = [];
  for (const uid of userIds) {
    const devicesSnap = await firestore.collection("users").doc(uid).collection("devices").get();
    devicesSnap.docs.forEach((doc) => {
      const token = doc.get("fcmToken");
      if (token) tokens.push(token);
    });
  }
  if (tokens.length === 0) return;
  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title: payload.title, body: payload.body },
    data: payload.data ?? {},
  });
}

async function handleReadPoints(before: Record<string, unknown>, after: Record<string, unknown>) {
  const beforeKeys = new Set(Object.keys(before));
  for (const uid of Object.keys(after)) {
    if (!beforeKeys.has(uid)) {
      await awardPoints(uid, pointsForRead());
    }
  }
}

async function handleReactionPoints(before: Record<string, unknown>, after: Record<string, unknown>) {
  const beforeKeys = new Set(Object.keys(before));
  for (const uid of Object.keys(after)) {
    if (!beforeKeys.has(uid)) {
      await awardPoints(uid, pointsForReact());
    }
  }
}

async function handleFavoritePoints(before: Record<string, boolean>, after: Record<string, boolean>) {
  for (const uid of Object.keys(after)) {
    const beforeValue = before[uid] === true;
    const afterValue = after[uid] === true;
    if (!beforeValue && afterValue) {
      await awardPoints(uid, pointsForFavorite());
    }
  }
}
