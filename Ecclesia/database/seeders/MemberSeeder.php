<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Database\Seeder;

class MemberSeeder extends Seeder
{
    /**
     * Seed demonstration faithful spread across the seeded parishes.
     */
    public function run(): void
    {
        $parishes = Parish::query()->pluck('id')->all();

        if ($parishes === []) {
            return;
        }

        $statuses = [
            UserStatus::Active->value,
            UserStatus::Active->value,
            UserStatus::Active->value,
            UserStatus::Inactive->value,
            UserStatus::Suspended->value,
        ];

        foreach ($parishes as $index => $parishId) {
            // A varying number of members per parish for a realistic spread.
            $count = 3 + ($index % 5);

            User::factory()
                ->count($count)
                ->create([
                    'parish_id' => $parishId,
                    'parish_joined_at' => now()->subDays(random_int(1, 120)),
                    'role' => UserRole::Member->value,
                    'status' => $statuses[array_rand($statuses)],
                ]);
        }
    }
}
