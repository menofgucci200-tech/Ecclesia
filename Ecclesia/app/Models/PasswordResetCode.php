<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PasswordResetCode extends Model
{
    /**
     * @var list<string>
     */
    protected $fillable = [
        'phone',
        'code',
        'attempts',
        'expires_at',
    ];

    /**
     * @var list<string>
     */
    protected $hidden = [
        'code',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
            'attempts' => 'integer',
        ];
    }

    public function isExpired(): bool
    {
        return $this->expires_at->isPast();
    }

    public function hasReachedMaxAttempts(int $max): bool
    {
        return $this->attempts >= $max;
    }

    public function markAttempt(): void
    {
        $this->increment('attempts');
    }
}
