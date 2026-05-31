import os
import json
import re
import time
from typing import List

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import google.generativeai as genai


load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    print("UYARI: GEMINI_API_KEY .env içinde bulunamadı.")

genai.configure(api_key=GEMINI_API_KEY)

app = FastAPI(
    title="Alchemy of Education API",
    description="AI destekli oyunlaştırılmış öğrenme macerası üretir.",
    version="1.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AdventureRequest(BaseModel):
    field: str
    topic: str
    level: str
    mode: str


class QuizQuestion(BaseModel):
    question: str
    options: List[str] = Field(min_length=4, max_length=4)
    correctIndex: int


class AdventureChapter(BaseModel):
    id: int
    title: str
    subtitle: str
    story: str
    explanation: str
    memoryTip: str
    question: str
    options: List[str] = Field(min_length=4, max_length=4)
    correctIndex: int
    isBoss: bool = False
    finalQuiz: List[QuizQuestion] = []


class AdventureResponse(BaseModel):
    mapTitle: str
    chapters: List[AdventureChapter]


def clean_json_text(text: str) -> str:
    text = text.strip()

    text = re.sub(r"^```json", "", text)
    text = re.sub(r"^```", "", text)
    text = re.sub(r"```$", "", text)

    start = text.find("{")
    end = text.rfind("}")

    if start != -1 and end != -1:
        text = text[start: end + 1]

    return text.strip()


def build_prompt(request: AdventureRequest) -> str:
    random_seed = int(time.time())

    return f"""
Sen bir eğitim oyunu için görev haritası oluşturan yaratıcı bir yapay zeka tasarımcısısın.

Kullanıcının seçimi:
- Alan: {request.field}
- Konu: {request.topic}
- Seviye: {request.level}
- Oyun modu: {request.mode}
- Üretim kodu: {random_seed}

Görevin:
Bu bilgilerle 6 bölümlük oyunlaştırılmış bir öğrenme macerası üret.

Çok önemli kurallar:
1. Tam olarak 6 bölüm üret.
2. İlk 5 bölüm normal görev olsun.
3. 6. bölüm final boss / final mini quiz bölümü olsun.
4. İlk 5 bölümde sadece 1 tane kontrol sorusu olsun.
5. 6. bölümde ayrıca "finalQuiz" alanında 5 soruluk mini quiz olsun.
6. İlk 5 bölümde finalQuiz boş liste olsun.
7. Konu anlatımı çok kısa olmasın. Her explanation alanı 5-8 cümle arası öğretici bir açıklama olsun.
8. Başlangıç seviyesinde bile konuyu gerçekten anlat. Sadece tanım yazıp geçme.
9. story alanı temaya uygun kısa ama etkileyici olsun.
10. memoryTip alanı akılda kalıcı benzetme içersin.
11. Görev adları her üretimde yaratıcı ve farklı olsun. Klasik, aynı, tekrar eden başlıklar kullanma.
12. Her quizde 4 seçenek olsun.
13. correctIndex 0 ile 3 arasında olmalı.
14. Cevabın SADECE geçerli JSON olsun. Markdown, açıklama, yorum yazma.
15. Türkçe üret.

Oyun modu dili:
- Fantastik Krallık: kapı, kule, kale, ejderha, büyü, kristal, muhafız.
- Dedektif Hikâyesi: dosya, ipucu, kanıt, şüpheli, dava, sorgu.
- Uzay Görevi: üs, gezegen, istasyon, galaksi, görev kontrol, kara delik.
- Antik Şehir: tapınak, obelisk, antik kapı, muhafız, taş tablet.
- Laboratuvar: deney, formül, kristal, cihaz, dönüşüm, enerji çekirdeği.
- Korku Evi: kilitli oda, karanlık koridor, ayna, bodrum, kaçış, gölge.

JSON formatı tam olarak şöyle olsun:

{{
  "mapTitle": "Kısa macera haritası adı",
  "chapters": [
    {{
      "id": 1,
      "title": "Görev adı",
      "subtitle": "Kısa alt başlık",
      "story": "Oyunlaştırılmış kısa hikaye",
      "explanation": "5-8 cümlelik öğretici açıklama",
      "memoryTip": "Akılda kalıcı hafıza ipucu",
      "question": "Normal görev kontrol sorusu",
      "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
      "correctIndex": 0,
      "isBoss": false,
      "finalQuiz": []
    }},
    {{
      "id": 6,
      "title": "Final boss adı",
      "subtitle": "Final Mini Quiz",
      "story": "Final boss hikayesi",
      "explanation": "5-8 cümlelik genel tekrar ve konu özeti",
      "memoryTip": "Final için hafıza ipucu",
      "question": "Finale giriş kontrol sorusu",
      "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
      "correctIndex": 0,
      "isBoss": true,
      "finalQuiz": [
        {{
          "question": "Final soru 1",
          "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
          "correctIndex": 0
        }},
        {{
          "question": "Final soru 2",
          "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
          "correctIndex": 1
        }},
        {{
          "question": "Final soru 3",
          "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
          "correctIndex": 2
        }},
        {{
          "question": "Final soru 4",
          "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
          "correctIndex": 3
        }},
        {{
          "question": "Final soru 5",
          "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
          "correctIndex": 0
        }}
      ]
    }}
  ]
}}
"""


def fallback_adventure(request: AdventureRequest) -> dict:
    final_quiz = [
        {
            "question": f"{request.topic} öğrenirken ilk amaç ne olmalıdır?",
            "options": [
                "Temel kavramları anlamak",
                "Konuyu tamamen ezberlemek",
                "Hiç örnek çözmemek",
                "Sadece başlıklara bakmak",
            ],
            "correctIndex": 0,
        },
        {
            "question": "Kalıcı öğrenmeyi en çok ne destekler?",
            "options": [
                "Kavramlar arasında bağlantı kurmak",
                "Konuyu bir kez okuyup bırakmak",
                "Yanlışları görmezden gelmek",
                "Sadece görsele bakmak",
            ],
            "correctIndex": 0,
        },
        {
            "question": "Bir konuyu daha iyi anlamak için ne yapılmalıdır?",
            "options": [
                "Örneklerle uygulama yapmak",
                "Hiç tekrar etmemek",
                "Soru çözmemek",
                "Not almamak",
            ],
            "correctIndex": 0,
        },
        {
            "question": "Hafıza ipuçları ne işe yarar?",
            "options": [
                "Bilgiyi akılda tutmayı kolaylaştırır",
                "Bilgiyi siler",
                "Konuyu gereksiz yapar",
                "Öğrenmeyi engeller",
            ],
            "correctIndex": 0,
        },
        {
            "question": "Final quiz neyi ölçer?",
            "options": [
                "Öğrenilen bilgilerin genel kullanımını",
                "Sadece ezber hızını",
                "Uygulamanın rengini",
                "Kullanıcının internetini",
            ],
            "correctIndex": 0,
        },
    ]

    chapters = []

    for i in range(1, 6):
        chapters.append({
            "id": i,
            "title": f"{request.topic} Görevi {i}",
            "subtitle": "Öğrenme adımı",
            "story": f"{request.mode} dünyasında {request.topic} konusunun {i}. kapısı açılıyor.",
            "explanation": (
                f"{request.topic} konusunu öğrenirken önce kavramların ne işe yaradığını anlamak gerekir. "
                "Bu bölümde konu küçük bir parçaya ayrılır ve daha kolay takip edilir. "
                "Öğrenme sürecinde sadece tanımı bilmek yeterli değildir; kavramın nerede kullanıldığını da görmek gerekir. "
                "Bu yüzden her görev seni bir adım ileri taşır. "
                "Kavramı örnekle düşündüğünde bilgi daha kalıcı hale gelir. "
                "Bu bölümün amacı konuyu ezberletmek değil, mantığını kavratmaktır."
            ),
            "memoryTip": "Konuyu bir harita gibi düşün; her görev seni final kapısına biraz daha yaklaştırır.",
            "question": f"{request.topic} öğrenirken en doğru yaklaşım nedir?",
            "options": [
                "Konuyu parçalara ayırarak anlamak",
                "Hiç tekrar etmemek",
                "Sadece başlığı okumak",
                "Yanlışları görmezden gelmek",
            ],
            "correctIndex": 0,
            "isBoss": False,
            "finalQuiz": [],
        })

    chapters.append({
        "id": 6,
        "title": f"{request.topic} Final Boss",
        "subtitle": "Final Mini Quiz",
        "story": f"{request.mode} dünyasının son kapısında final sınavı başlıyor.",
        "explanation": (
            f"Bu final bölümünde {request.topic} boyunca öğrendiğin temel fikirleri birlikte kullanman gerekir. "
            "Önceki görevlerde parçalar halinde gördüğün bilgiler burada birleşir. "
            "Final quiz sadece ezber kontrolü değildir; konunun genel mantığını kavrayıp kavramadığını ölçer. "
            "Soruları çözerken her seçeneğin ne anlama geldiğini düşünmelisin. "
            "Yanlış seçenekler genellikle konunun amacını karıştıran ifadelerdir. "
            "Bu yüzden acele etmeden, öğrendiğin bağlantıları kullanarak cevap vermen gerekir."
        ),
        "memoryTip": "Final boss, öğrendiğin tüm kapıların birleştiği son sınavdır.",
        "question": f"{request.topic} finalinde neyi kullanmalısın?",
        "options": [
            "Öğrendiğin tüm bağlantıları",
            "Sadece tahmin etmeyi",
            "Konuyu atlamayı",
            "Hiç düşünmemeyi",
        ],
        "correctIndex": 0,
        "isBoss": True,
        "finalQuiz": final_quiz,
    })

    return {
        "mapTitle": f"{request.topic} Macerası",
        "chapters": chapters,
    }


@app.get("/")
def root():
    return {
        "message": "Alchemy of Education API çalışıyor.",
        "endpoint": "/generate-adventure",
    }


@app.post("/generate-adventure")
def generate_adventure(request: AdventureRequest):
    try:
        model = genai.GenerativeModel("gemini-3-flash-preview")
        prompt = build_prompt(request)

        response = model.generate_content(prompt)
        raw_text = response.text

        json_text = clean_json_text(raw_text)
        data = json.loads(json_text)

        validated = AdventureResponse(**data)

        if len(validated.chapters) != 6:
            return fallback_adventure(request)

        for chapter in validated.chapters:
            if chapter.id == 6:
                chapter.isBoss = True
                if len(chapter.finalQuiz) != 5:
                    return fallback_adventure(request)
            else:
                chapter.isBoss = False
                chapter.finalQuiz = []

        return validated.model_dump()

    except Exception as e:
        print("AI üretim hatası:", str(e))
        return fallback_adventure(request)