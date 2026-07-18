<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\Gender;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'first_name',
        'last_name',
        'gender',
        'phone',
        'email',
        'password',
        'parish_id',
        'parish_joined_at',
        'status',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'parish_joined_at' => 'datetime',
            'password' => 'hashed',
            'gender' => Gender::class,
            'status' => UserStatus::class,
            'role' => UserRole::class,
        ];
    }

    /**
     * The parish the faithful is linked to.
     *
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    public function fullName(): string
    {
        return trim("{$this->first_name} {$this->last_name}");
    }

    public function hasParish(): bool
    {
        return $this->parish_id !== null;
    }

    public function isActive(): bool
    {
        return $this->status === UserStatus::Active;
    }

    /**
     * Whether the user may access the administration dashboard.
     */
    public function isStaff(): bool
    {
        return $this->role instanceof UserRole && $this->role->isStaff();
    }

    public function isSuperAdmin(): bool
    {
        return $this->role === UserRole::SuperAdmin;
    }

    /**
     * A super admin manages every parish; a parish admin is scoped to their own.
     * Returns null when the admin has platform-wide scope.
     */
    public function managedParishId(): ?int
    {
        return $this->isSuperAdmin() ? null : $this->parish_id;
    }
}
