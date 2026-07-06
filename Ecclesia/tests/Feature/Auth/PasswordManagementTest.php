<?php

declare(strict_types=1);

namespace Tests\Feature\Auth;

use App\Mail\PasswordResetCodeMail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class PasswordManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_change_password(): void
    {
        $user = User::factory()->create(['password' => 'oldpass']);

        $this->actingAs($user)->postJson('/api/auth/change-password', [
            'current_password' => 'oldpass',
            'password' => 'newpass',
            'password_confirmation' => 'newpass',
        ])->assertOk();

        $this->assertTrue(Hash::check('newpass', $user->fresh()->password));
    }

    public function test_change_password_rejects_wrong_current_password(): void
    {
        $user = User::factory()->create(['password' => 'oldpass']);

        $this->actingAs($user)->postJson('/api/auth/change-password', [
            'current_password' => 'wrong',
            'password' => 'newpass',
            'password_confirmation' => 'newpass',
        ])->assertUnprocessable()->assertJsonValidationErrors('current_password');
    }

    public function test_forgot_and_reset_password_flow_by_email(): void
    {
        Mail::fake();

        $user = User::factory()->create([
            'phone' => '+2250700000010',
            'email' => 'fidele@example.com',
            'password' => 'oldpass',
        ]);

        $this->postJson('/api/auth/forgot-password', ['phone' => '0700000010'])
            ->assertOk()
            ->assertJsonPath('email_hint', 'fi****@example.com');

        $code = null;
        Mail::assertSent(PasswordResetCodeMail::class, function (PasswordResetCodeMail $mail) use (&$code, $user) {
            $code = $mail->code;

            return $mail->hasTo($user->email);
        });

        $this->assertNotNull($code);

        $this->postJson('/api/auth/reset-password', [
            'phone' => '0700000010',
            'code' => $code,
            'password' => 'freshpass',
            'password_confirmation' => 'freshpass',
        ])->assertOk()->assertJsonStructure(['user', 'token']);

        $this->assertTrue(Hash::check('freshpass', $user->fresh()->password));
        $this->assertDatabaseCount('password_reset_codes', 0);
    }

    public function test_forgot_password_requires_an_email_on_the_account(): void
    {
        User::factory()->create(['phone' => '+2250700000011', 'email' => null]);

        $this->postJson('/api/auth/forgot-password', ['phone' => '0700000011'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('phone');
    }

    public function test_reset_password_rejects_an_invalid_code(): void
    {
        Mail::fake();

        User::factory()->create([
            'phone' => '+2250700000012',
            'email' => 'someone@example.com',
        ]);

        $this->postJson('/api/auth/forgot-password', ['phone' => '0700000012'])->assertOk();

        $this->postJson('/api/auth/reset-password', [
            'phone' => '0700000012',
            'code' => '000000',
            'password' => 'whatever',
            'password_confirmation' => 'whatever',
        ])->assertUnprocessable()->assertJsonValidationErrors('code');
    }
}
