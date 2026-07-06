<?php

declare(strict_types=1);

namespace Tests\Feature\Parish;

use App\Models\Parish;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ParishSelectionTest extends TestCase
{
    use RefreshDatabase;

    public function test_it_lists_active_parishes_paginated(): void
    {
        Parish::factory()->count(3)->create();
        Parish::factory()->inactive()->create();

        $this->actingAs(User::factory()->create())
            ->getJson('/api/parishes')
            ->assertOk()
            ->assertJsonStructure([
                'data' => [['id', 'name', 'code', 'city', 'commune', 'region', 'country']],
                'meta' => ['current_page', 'last_page', 'total'],
            ])
            ->assertJsonPath('meta.total', 3);
    }

    public function test_it_searches_parishes_by_name_commune_and_code(): void
    {
        Parish::factory()->create(['name' => 'Paroisse Saint-Jean-Baptiste', 'commune' => 'Yopougon', 'code' => 'STJB01']);
        Parish::factory()->create(['name' => 'Paroisse Sacré-Cœur', 'commune' => 'Marcory', 'code' => 'SACRE02']);

        $user = User::factory()->create();

        $this->actingAs($user)->getJson('/api/parishes/search?q=Baptiste')
            ->assertOk()->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.code', 'STJB01');

        $this->actingAs($user)->getJson('/api/parishes/search?q=Marcory')
            ->assertOk()->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.code', 'SACRE02');

        $this->actingAs($user)->getJson('/api/parishes/search?q=STJB01')
            ->assertOk()->assertJsonPath('meta.total', 1);
    }

    public function test_search_requires_a_query(): void
    {
        $this->actingAs(User::factory()->create())
            ->getJson('/api/parishes/search')
            ->assertUnprocessable()
            ->assertJsonValidationErrors('q');
    }

    public function test_it_shows_full_parish_details(): void
    {
        $parish = Parish::factory()->create(['email' => 'contact@paroisse.ci', 'phone' => '+2252700000000']);

        $this->actingAs(User::factory()->create())
            ->getJson("/api/parishes/{$parish->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $parish->id)
            ->assertJsonPath('data.email', 'contact@paroisse.ci')
            ->assertJsonPath('data.phone', '+2252700000000');
    }

    public function test_showing_an_unknown_parish_returns_404(): void
    {
        $this->actingAs(User::factory()->create())
            ->getJson('/api/parishes/999999')
            ->assertNotFound()
            ->assertJsonPath('message', 'Cette paroisse est introuvable.');
    }

    public function test_it_associates_a_parish_and_returns_current(): void
    {
        $parish = Parish::factory()->create();
        $user = User::factory()->create(['parish_id' => null]);

        $this->actingAs($user)->postJson('/api/user/parish', ['parish_id' => $parish->id])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Paroisse associée avec succès.')
            ->assertJsonPath('data.id', $parish->id);

        $user->refresh();
        $this->assertSame($parish->id, $user->parish_id);
        $this->assertNotNull($user->parish_joined_at);

        $this->actingAs($user)->getJson('/api/user/parish')
            ->assertOk()
            ->assertJsonPath('data.id', $parish->id);
    }

    public function test_a_user_can_change_parish(): void
    {
        $first = Parish::factory()->create();
        $second = Parish::factory()->create();
        $user = User::factory()->create(['parish_id' => $first->id]);

        $this->actingAs($user)->postJson('/api/user/parish', ['parish_id' => $second->id])
            ->assertOk()
            ->assertJsonPath('data.id', $second->id);

        $this->assertSame($second->id, $user->fresh()->parish_id);
    }

    public function test_an_inactive_parish_cannot_be_associated(): void
    {
        $parish = Parish::factory()->inactive()->create();
        $user = User::factory()->create(['parish_id' => null]);

        $this->actingAs($user)->postJson('/api/user/parish', ['parish_id' => $parish->id])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('parish_id');

        $this->assertNull($user->fresh()->parish_id);
    }

    public function test_parish_routes_require_authentication(): void
    {
        $this->getJson('/api/parishes')->assertUnauthorized();
        $this->getJson('/api/user/parish')->assertUnauthorized();
        $this->postJson('/api/user/parish', ['parish_id' => 1])->assertUnauthorized();
    }
}
