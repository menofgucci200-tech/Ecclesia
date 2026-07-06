<?php

declare(strict_types=1);

namespace Tests\Feature\Auth;

use App\Enums\UserStatus;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegistrationFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_it_runs_the_full_registration_flow(): void
    {
        $parish = Parish::factory()->create();

        // 1. The phone is unknown yet.
        $this->postJson('/api/auth/check-phone', ['phone' => '0102030405'])
            ->assertOk()
            ->assertJson(['exists' => false, 'phone' => '+2250102030405']);

        // 2. Registration issues a token and normalizes the phone number.
        $register = $this->postJson('/api/auth/register', [
            'first_name' => 'Marie',
            'last_name' => 'Kouassi',
            'gender' => 'female',
            'phone' => '01 02 03 04 05',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
        ])->assertCreated()
            ->assertJsonPath('user.phone', '+2250102030405')
            ->assertJsonPath('user.has_parish', false)
            ->assertJsonStructure(['user' => ['id', 'full_name'], 'token', 'token_type']);

        $token = $register->json('token');

        $this->assertDatabaseHas('users', [
            'phone' => '+2250102030405',
            'status' => UserStatus::Active->value,
        ]);

        // 3. The token authenticates the "me" endpoint.
        $this->withToken($token)->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('user.first_name', 'Marie');

        // 4. The faithful associates a parish (automatic, by id).
        $this->withToken($token)->postJson('/api/user/parish', ['parish_id' => $parish->id])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $parish->id);

        $this->assertDatabaseHas('users', [
            'phone' => '+2250102030405',
            'parish_id' => $parish->id,
        ]);

        $this->assertNotNull(User::query()->find($register->json('user.id'))->parish_joined_at);

        // 5. The current parish is returned.
        $this->withToken($token)->getJson('/api/user/parish')
            ->assertOk()
            ->assertJsonPath('data.id', $parish->id);

        // 6. Logout revokes the token.
        $this->withToken($token)->postJson('/api/auth/logout')->assertOk();
        $this->assertDatabaseCount('personal_access_tokens', 0);

        // The revoked token can no longer authenticate a fresh request.
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/auth/me')->assertUnauthorized();
    }

    public function test_existing_user_can_log_in(): void
    {
        User::factory()->create([
            'phone' => '+2250700000001',
            'password' => 'Password123',
            'status' => UserStatus::Active->value,
        ]);

        $this->postJson('/api/auth/check-phone', ['phone' => '0700000001'])
            ->assertOk()
            ->assertJson(['exists' => true]);

        $this->postJson('/api/auth/login', [
            'phone' => '0700000001',
            'password' => 'Password123',
        ])->assertOk()->assertJsonStructure(['user', 'token']);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'phone' => '+2250700000002',
            'password' => 'Password123',
        ]);

        $this->postJson('/api/auth/login', [
            'phone' => '0700000002',
            'password' => 'WrongPassword1',
        ])->assertUnauthorized();
    }

    public function test_inactive_user_cannot_log_in(): void
    {
        User::factory()->inactive()->create([
            'phone' => '+2250700000003',
            'password' => 'Password123',
        ]);

        $this->postJson('/api/auth/login', [
            'phone' => '0700000003',
            'password' => 'Password123',
        ])->assertForbidden();
    }

    public function test_registration_rejects_a_duplicate_phone(): void
    {
        User::factory()->create(['phone' => '+2250102030405']);

        $this->postJson('/api/auth/register', [
            'first_name' => 'Jean',
            'last_name' => 'Konan',
            'gender' => 'male',
            'phone' => '0102030405',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
        ])->assertUnprocessable()->assertJsonValidationErrors('phone');
    }

    public function test_protected_routes_require_authentication(): void
    {
        $this->getJson('/api/auth/me')->assertUnauthorized();
        $this->getJson('/api/parishes')->assertUnauthorized();
    }

    public function test_associating_an_unknown_parish_is_rejected(): void
    {
        $user = User::factory()->create(['status' => UserStatus::Active->value]);

        $this->actingAs($user)->postJson('/api/user/parish', ['parish_id' => 999999])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('parish_id');

        $this->assertNull($user->fresh()->parish_id);
    }
}
