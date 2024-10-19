class Game {
  final int id;
  final String title;
  final String description;
  final String image;

  Game({required this.id, required this.title, required this.description, required this.image});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
    );
  }
}
