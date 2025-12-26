enum NoteType {
  text,
  handwriting,
  voice,
}

NoteType noteTypeFromString(String value) {
  switch (value) {
    case "handwriting":
      return NoteType.handwriting;
    case "voice":
      return NoteType.voice;
    default:
      return NoteType.text;
  }
}

String noteTypeToString(NoteType type) {
  switch (type) {
    case NoteType.handwriting:
      return "handwriting";
    case NoteType.voice:
      return "voice";
    case NoteType.text:
    default:
      return "text";
  }
}
