<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Enums\AnnouncementCategory;
use App\Models\Announcement;
use App\Models\Parish;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Announcement>
 */
class AnnouncementFactory extends Factory
{
    protected $model = Announcement::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $category = fake()->randomElement(AnnouncementCategory::cases());

        return [
            'parish_id' => Parish::factory(),
            'category' => $category->value,
            'title' => fake()->sentence(6),
            'body' => fake()->paragraph(3),
            'image_url' => null,
            'video_url' => null,
            'author_name' => 'Père '.fake()->firstName('male'),
            'author_role' => 'Curé',
            'is_pinned' => false,
            'is_important' => false,
            'likes_count' => fake()->numberBetween(0, 60),
            'comments_count' => fake()->numberBetween(0, 25),
            'published_at' => fake()->dateTimeBetween('-10 days', 'now'),
        ];
    }

    public function pinned(): static
    {
        return $this->state(fn (): array => ['is_pinned' => true]);
    }

    public function important(): static
    {
        return $this->state(fn (): array => ['is_important' => true, 'is_pinned' => true]);
    }
}
