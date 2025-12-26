"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.notifyTimeCapsules = exports.onNoteUpdated = exports.onNoteCreated = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const points_1 = require("./points");
admin.initializeApp();
const firestore = admin.firestore();
exports.onNoteCreated = functions.firestore
    .document("spaces/{spaceId}/notes/{noteId}")
    .onCreate(async (snap, context) => {
    const note = snap.data();
    const spaceId = context.params.spaceId;
    const noteId = context.params.noteId;
    const spaceRef = firestore.collection("spaces").doc(spaceId);
    const spaceSnap = await spaceRef.get();
    if (!spaceSnap.exists)
        return;
    const space = spaceSnap.data() ?? {};
    const participants = space.participantUids ?? [];
    const preview = buildPreview(note);
    await spaceRef.set({
        lastNoteId: noteId,
        lastNotePreview: preview,
        lastNoteAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    await (0, points_1.awardPoints)(note.senderUid, (0, points_1.pointsForSend)());
    await (0, points_1.updateStreak)(note.senderUid);
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
exports.onNoteUpdated = functions.firestore
    .document("spaces/{spaceId}/notes/{noteId}")
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    await handleReadPoints(before.readBy ?? {}, after.readBy ?? {});
    await handleReactionPoints(before.reactions ?? {}, after.reactions ?? {});
    await handleFavoritePoints(before.isFavoriteBy ?? {}, after.isFavoriteBy ?? {});
});
exports.notifyTimeCapsules = functions.pubsub
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
        if (!spaceRef)
            continue;
        const spaceSnap = await spaceRef.get();
        const participants = spaceSnap.get("participantUids") ?? [];
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
function buildPreview(note) {
    if (note.type === "text" && note.text) {
        return note.text.length > 80 ? `${note.text.substring(0, 80)}...` : note.text;
    }
    if (note.type === "handwriting")
        return "Handwritten note";
    if (note.type === "voice")
        return "Voice note";
    return "New note";
}
async function sendNotification(userIds, payload) {
    if (userIds.length === 0)
        return;
    const tokens = [];
    for (const uid of userIds) {
        const devicesSnap = await firestore.collection("users").doc(uid).collection("devices").get();
        devicesSnap.docs.forEach((doc) => {
            const token = doc.get("fcmToken");
            if (token)
                tokens.push(token);
        });
    }
    if (tokens.length === 0)
        return;
    await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title: payload.title, body: payload.body },
        data: payload.data ?? {},
    });
}
async function handleReadPoints(before, after) {
    const beforeKeys = new Set(Object.keys(before));
    for (const uid of Object.keys(after)) {
        if (!beforeKeys.has(uid)) {
            await (0, points_1.awardPoints)(uid, (0, points_1.pointsForRead)());
        }
    }
}
async function handleReactionPoints(before, after) {
    const beforeKeys = new Set(Object.keys(before));
    for (const uid of Object.keys(after)) {
        if (!beforeKeys.has(uid)) {
            await (0, points_1.awardPoints)(uid, (0, points_1.pointsForReact)());
        }
    }
}
async function handleFavoritePoints(before, after) {
    for (const uid of Object.keys(after)) {
        const beforeValue = before[uid] === true;
        const afterValue = after[uid] === true;
        if (!beforeValue && afterValue) {
            await (0, points_1.awardPoints)(uid, (0, points_1.pointsForFavorite)());
        }
    }
}
