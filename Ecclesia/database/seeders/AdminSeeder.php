<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Enums\Gender;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Seed the dashboard administrators.
     */
    public function run(): void
    {
        // Platform super administrator — sees every parish.
        User::query()->updateOrCreate(
            ['email' => 'admin@ecclesia.app'],
            [
                'first_name' => 'Super',
                'last_name' => 'Admin',
                'gender' => Gender::Male->value,
                'phone' => '+2250700000000',
                'password' => Hash::make('password'),
                'status' => UserStatus::Active->value,
                'role' => UserRole::SuperAdmin->value,
                'email_verified_at' => now(),
            ],
        );

        // Parish administrator — scoped to the cathedral as an example.
        $parish = Parish::query()->where('code', 'CATHPLATEAU')->first();

        if ($parish !== null) {
            User::query()->updateOrCreate(
                ['email' => 'cure@ecclesia.app'],
                [
                    'first_name' => 'Curé',
                    'last_name' => 'de la Cathédrale',
                    'gender' => Gender::Male->value,
                    'phone' => '+2250700000001',
                    'password' => Hash::make('password'),
                    'status' => UserStatus::Active->value,
                    'role' => UserRole::Admin->value,
                    'parish_id' => $parish->id,
                    'parish_joined_at' => now(),
                    'email_verified_at' => now(),
                ],
            );
        }
    }
}
