<?php

namespace Database\Seeders;

use App\Models\Quest;
use Illuminate\Database\Seeder;

class QuestSeeder extends Seeder
{
    public function run(): void
    {
        $quests = [
            [
                'title' => 'AR Green Gate',
                'type' => 'AR',
                'mode' => 'gps',
                'latitude' => -6.5981200,
                'longitude' => 106.7981020,
                'points' => 50,
                'unlock_radius_m' => 24,
                'accuracy_threshold_m' => 12,
                'qr_code' => 'AR-GATE-01',
                'instruction' => 'Temukan gapura AR, scan QR di papan hijau untuk membuka quest.',
                'quiz_question' => null,
                'quiz_options' => null,
                'quiz_answer' => null,
                'timer_seconds' => 60,
                'is_active' => true,
                'status' => 'approach_to_unlock',
            ],
            [
                'title' => 'GPS Orchid Track',
                'type' => 'GPS',
                'mode' => 'gps',
                'latitude' => -6.5985200,
                'longitude' => 106.7993020,
                'points' => 40,
                'unlock_radius_m' => 18,
                'accuracy_threshold_m' => 10,
                'qr_code' => 'GPS-ORCHID-02',
                'instruction' => 'Temukan papan informasi anggrek dan masukkan kode QR yang tertempel.',
                'quiz_question' => null,
                'quiz_options' => null,
                'quiz_answer' => null,
                'timer_seconds' => 60,
                'is_active' => true,
                'status' => 'approach_to_unlock',
            ],
            [
                'title' => 'Quiz Corner',
                'type' => 'Quiz',
                'mode' => 'quiz',
                'latitude' => -6.5992100,
                'longitude' => 106.7998020,
                'points' => 30,
                'unlock_radius_m' => 20,
                'accuracy_threshold_m' => 12,
                'qr_code' => null,
                'instruction' => 'Baca petunjuk area lalu jawab quiz sebelum timer habis.',
                'quiz_question' => 'Bagian tumbuhan apa yang bertanggung jawab utama untuk fotosintesis?',
                'quiz_options' => ['Akar', 'Daun', 'Batang', 'Bunga'],
                'quiz_answer' => 'Daun',
                'timer_seconds' => 45,
                'is_active' => true,
                'status' => 'approach_to_unlock',
            ],
            [
                'title' => 'Plant ID Zone',
                'type' => 'Plant ID',
                'mode' => 'quiz',
                'latitude' => -6.5997000,
                'longitude' => 106.7986020,
                'points' => 45,
                'unlock_radius_m' => 22,
                'accuracy_threshold_m' => 10,
                'qr_code' => 'PLANT-ID-03',
                'instruction' => 'Dekati zona identifikasi tanaman, scan QR, lalu jawab pertanyaan singkat.',
                'quiz_question' => 'Tanaman dengan batang berkayu disebut tanaman?',
                'quiz_options' => ['Herba', 'Semak', 'Pohon', 'Lumut'],
                'quiz_answer' => 'Pohon',
                'timer_seconds' => 50,
                'is_active' => true,
                'status' => 'approach_to_unlock',
            ],
            [
                'title' => 'Treasure Garden Hunt',
                'type' => 'Treasure Hunt',
                'mode' => 'gps',
                'latitude' => -6.6002000,
                'longitude' => 106.7990000,
                'points' => 60,
                'unlock_radius_m' => 15,
                'accuracy_threshold_m' => 8,
                'qr_code' => 'TREASURE-04',
                'instruction' => 'Cari peti mini di sekitar spot dan scan QR untuk trigger harta.',
                'quiz_question' => null,
                'quiz_options' => null,
                'quiz_answer' => null,
                'timer_seconds' => 60,
                'is_active' => true,
                'status' => 'approach_to_unlock',
            ],
            [
                'title' => 'Puzzle Pavilion',
                'type' => 'Puzzle',
                'mode' => 'puzzle',
                'latitude' => -6.5989100,
                'longitude' => 106.7978000,
                'points' => 35,
                'unlock_radius_m' => 16,
                'accuracy_threshold_m' => 8,
                'qr_code' => 'PUZZLE-05',
                'instruction' => 'Datangi pavilion puzzle, scan QR lalu selesaikan teka-teki.',
                'quiz_question' => 'Jika semua mawar adalah bunga dan sebagian bunga cepat layu, maka...',
                'quiz_options' => [
                    'Semua mawar cepat layu',
                    'Sebagian mawar mungkin cepat layu',
                    'Tidak ada mawar yang layu',
                    'Semua bunga adalah mawar',
                ],
                'quiz_answer' => 'Sebagian mawar mungkin cepat layu',
                'timer_seconds' => 55,
                'is_active' => true,
                'status' => 'approach_to_unlock',
            ],
        ];

        foreach ($quests as $quest) {
            Quest::query()->updateOrCreate(
                ['title' => $quest['title']],
                $quest
            );
        }
    }
}
