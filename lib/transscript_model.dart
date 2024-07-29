class TransscriptModel {
    int pause;
    List<Speaker> speakers;

    TransscriptModel({
        required this.pause,
        required this.speakers,
    });

    factory TransscriptModel.fromJson(Map<String, dynamic> json) => TransscriptModel(
        pause: json["pause"],
        speakers: List<Speaker>.from(json["speakers"].map((x) => Speaker.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "pause": pause,
        "speakers": List<dynamic>.from(speakers.map((x) => x.toJson())),
    };
}

class Speaker {
    String name;
    List<Phrase> phrases;

    Speaker({
        required this.name,
        required this.phrases,
    });

    factory Speaker.fromJson(Map<String, dynamic> json) => Speaker(
        name: json["name"],
        phrases: List<Phrase>.from(json["phrases"].map((x) => Phrase.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "phrases": List<dynamic>.from(phrases.map((x) => x.toJson())),
    };
}

class Phrase {
    String words;
    int time;

    Phrase({
        required this.words,
        required this.time,
    });

    factory Phrase.fromJson(Map<String, dynamic> json) => Phrase(
        words: json["words"],
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "words": words,
        "time": time,
    };
}
