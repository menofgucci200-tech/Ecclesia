<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Enums\AnnouncementCategory;
use App\Models\Announcement;
use App\Models\Parish;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class AnnouncementSeeder extends Seeder
{
    /**
     * Seed a curated parish feed for every parish so any signed-in user lands
     * on a rich "Fil paroissial".
     */
    public function run(): void
    {
        foreach (Parish::query()->get() as $parish) {
            foreach ($this->announcements() as $data) {
                Announcement::query()->updateOrCreate(
                    ['parish_id' => $parish->id, 'title' => $data['title']],
                    [...$data, 'parish_id' => $parish->id],
                );
            }
        }
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function announcements(): array
    {
        return [
            [
                'category' => AnnouncementCategory::Announcement->value,
                'title' => 'Assemblée générale paroissiale',
                'body' => "Tous les fidèles sont invités samedi 12 juillet à 10h00 en salle Saint-Joseph. Votre présence est vivement souhaitée pour préparer la rentrée pastorale.",
                'author_name' => 'Père Jean-Marie',
                'author_role' => 'Curé',
                'is_important' => true,
                'is_pinned' => true,
                'likes_count' => 42,
                'comments_count' => 12,
                'published_at' => Carbon::now()->subHours(2),
            ],
            [
                'category' => AnnouncementCategory::Announcement->value,
                'title' => 'Journée de prière pour la paix dans le monde',
                'body' => "Chapelet à 7h, messe solennelle à 9h30 et adoration eucharistique de 15h à 18h en l'église paroissiale. Venez nombreux confier le monde au Seigneur.",
                'author_name' => 'Père Jean-Marie',
                'author_role' => 'Curé',
                'likes_count' => 24,
                'comments_count' => 8,
                'published_at' => Carbon::now()->subDay(),
            ],
            [
                'category' => AnnouncementCategory::Event->value,
                'title' => "Retraite spirituelle d'été — Inscriptions ouvertes",
                'body' => "Du 18 au 20 juillet au Centre spirituel de Toumodi. Places limitées — inscrivez-vous dès maintenant auprès de la sacristie.",
                'author_name' => 'Mère Cécile',
                'author_role' => 'Responsable pastorale',
                'likes_count' => 31,
                'comments_count' => 5,
                'published_at' => Carbon::now()->subDays(2),
            ],
            [
                'category' => AnnouncementCategory::Formation->value,
                'title' => 'Reprise de la catéchèse des enfants',
                'body' => "Les inscriptions à la catéchèse sont ouvertes pour la nouvelle année. Rendez-vous chaque samedi à 15h00 à partir du 20 septembre.",
                'author_name' => 'Catherine Kouassi',
                'author_role' => 'Catéchiste',
                'likes_count' => 18,
                'comments_count' => 3,
                'published_at' => Carbon::now()->subDays(3),
            ],
        ];
    }
}
