import * as admin from "firebase-admin";

const POINTS = {
  send: 5,
  read: 2,
  react: 1,
  favorite: 2,
  streak: 3,
};

const BADGES = [
  { id: "first_note", points: 20 },
  { id: "streak_3", points: 60 },
  { id: "lover", points: 250 },
  { id: "milestone", points: 100 },
];

export async function awardPoints(uid: string, delta: number) {
  if (delta === 0) return;
  const userRef = admin.firestore().collection("users").doc(uid);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(userRef);
    const currentPoints = (snap.get("points") as number | undefined) ?? 0;
    const newPoints = currentPoints + delta;
    const existingBadges = new Set<string>((snap.get("badges") as string[] | undefined) ?? []);
    for (const badge of BADGES) {
      if (newPoints >= badge.points) {
        existingBadges.add(badge.id);
      }
    }
    tx.set(
      userRef,
      {
        points: newPoints,
        badges: Array.from(existingBadges),
      },
      { merge: true },
    );
  });
}

export async function updateStreak(uid: string) {
  const userRef = admin.firestore().collection("users").doc(uid);
  let streak = 0;
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(userRef);
    const lastSent = snap.get("lastSentAt") as admin.firestore.Timestamp | undefined;
    const now = admin.firestore.Timestamp.now();
    if (!lastSent) {
      streak = 1;
    } else {
      const diffHours = (now.toMillis() - lastSent.toMillis()) / (1000 * 60 * 60);
      streak = diffHours <= 36 ? (snap.get("streakCount") as number | undefined ?? 0) + 1 : 1;
    }
    tx.set(
      userRef,
      {
        lastSentAt: now,
        streakCount: streak,
      },
      { merge: true },
    );
  });
  if (streak > 1) {
    await awardPoints(uid, POINTS.streak);
  }
}

export function pointsForSend() {
  return POINTS.send;
}

export function pointsForRead() {
  return POINTS.read;
}

export function pointsForReact() {
  return POINTS.react;
}

export function pointsForFavorite() {
  return POINTS.favorite;
}
