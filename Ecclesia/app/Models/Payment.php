<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\PaymentStatus;
use App\Enums\PaymentType;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Str;

class Payment extends Model
{
    protected $fillable = [
        'reference',
        'parish_id',
        'user_id',
        'type',
        'label',
        'amount',
        'currency',
        'status',
        'channel',
        'operator',
        'cinetpay_token',
        'payment_url',
        'meta',
        'paid_at',
    ];

    protected $casts = [
        'type' => PaymentType::class,
        'status' => PaymentStatus::class,
        'amount' => 'integer',
        'meta' => 'array',
        'paid_at' => 'datetime',
    ];

    public static function generateReference(): string
    {
        return 'ECC-'.now()->format('ymd').'-'.strtoupper(Str::random(8));
    }

    /**
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return HasOne<MassIntention, $this>
     */
    public function massIntention(): HasOne
    {
        return $this->hasOne(MassIntention::class);
    }

    public function scopePaid(Builder $query): Builder
    {
        return $query->where('status', PaymentStatus::Paid->value);
    }

    public function markPaid(?string $channel = null, ?string $operator = null): void
    {
        $this->update([
            'status' => PaymentStatus::Paid,
            'channel' => $channel ?? $this->channel,
            'operator' => $operator ?? $this->operator,
            'paid_at' => now(),
        ]);

        $this->massIntention?->update(['status' => 'paid']);
    }
}
