import 'package:flutter/material.dart';

class QuestTheme {
  final String title;
  final String shortPurpose;
  final String playStyle;
  final String imagePath;
  final Color glowColor;

  const QuestTheme({
    required this.title,
    required this.shortPurpose,
    required this.playStyle,
    required this.imagePath,
    required this.glowColor,
  });
}

const List<QuestTheme> questThemes = [
  QuestTheme(
    title: 'Krallık Yolu',
    shortPurpose: 'Kavramlar kale kapılarına ve ejderha sınavlarına dönüşür.',
    playStyle: 'Destansı / cesur',
    imagePath: 'assets/images/fantasy_kingdom.jpg',
    glowColor: Color(0xFF9B5CFF),
  ),
  QuestTheme(
    title: 'Dedektif Modu',
    shortPurpose: 'Her bilgi bir ipucu, her bölüm çözülmesi gereken davadır.',
    playStyle: 'Analitik / gizemli',
    imagePath: 'assets/images/detective_story.jpg',
    glowColor: Color(0xFFFFB454),
  ),
  QuestTheme(
    title: 'Uzay Görevi',
    shortPurpose: 'Konular gezegenlere, bölümler keşif rotalarına dönüşür.',
    playStyle: 'Keşif / fütüristik',
    imagePath: 'assets/images/space_mission.jpg',
    glowColor: Color(0xFF22D3EE),
  ),
  QuestTheme(
    title: 'Antik Şehir',
    shortPurpose: 'Bilgi tapınaklarda saklanan kayıp parçalar gibi açılır.',
    playStyle: 'Mitolojik / tarihi',
    imagePath: 'assets/images/ancient_city.jpg',
    glowColor: Color(0xFFFFB020),
  ),
  QuestTheme(
    title: 'Simya Laboratuvarı',
    shortPurpose: 'Zor bilgiler deneylere ve dönüşüm aşamalarına ayrılır.',
    playStyle: 'Bilimsel / meraklı',
    imagePath: 'assets/images/laboratory.jpg',
    glowColor: Color(0xFF10B981),
  ),
  QuestTheme(
    title: 'Korku Evi',
    shortPurpose: 'Zor kavramlar kilitli odalara dönüşür; öğrendikçe açılır.',
    playStyle: 'Gerilim / meydan okuma',
    imagePath: 'assets/images/horror_house.jpg',
    glowColor: Color(0xFFFF3D6E),
  ),
];