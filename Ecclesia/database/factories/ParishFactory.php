<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Enums\ParishStatus;
use App\Models\Parish;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Parish>
 */
class ParishFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $commune = fake()->randomElement(['Yopougon', 'Cocody', 'Abobo', 'Marcory', 'Treichville', 'Koumassi', 'Adjamé']);

        return [
            'name' => 'Paroisse '.fake()->firstName(),
            'code' => Str::upper(Str::random(8)),
            'diocese' => 'Archidiocèse d\'Abidjan',
            'address' => fake()->streetAddress(),
            'city' => 'Abidjan',
            'commune' => $commune,
            'region' => 'District Autonome d\'Abidjan',
            'country' => 'Côte d\'Ivoire',
            'phone' => '+225'.fake()->numerify('27########'),
            'email' => fake()->unique()->companyEmail(),
            'logo' => null,
            'status' => ParishStatus::Active->value,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => ParishStatus::Inactive->value,
        ]);
    }
}
