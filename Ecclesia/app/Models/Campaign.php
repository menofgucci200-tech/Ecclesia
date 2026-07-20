<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Campaign extends Model
{
    protected $fillable = [
        'parish_id',
        'title',
        'description',
        'type',
        'target_amount',
        'collected_amount',
        'image',
        'is_active',
        'ends_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'target_amount' => 'integer',
            'collected_amount' => 'integer',
            'is_active' => 'boolean',
            'ends_at' => 'date',
        ];
    }

    /**
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    /**
     * @return HasMany<CampaignPledge, $this>
     */
    public function pledges(): HasMany
    {
        return $this->hasMany(CampaignPledge::class);
    }

    public function typeLabel(): string
    {
        return match ($this->type) {
            'cotisation' => 'Cotisation',
            'quete' => 'Quête',
            default => 'Don',
        };
    }

    public function progress(): int
    {
        if (! $this->target_amount || $this->target_amount <= 0) {
            return 0;
        }

        return (int) min(100, round($this->collected_amount / $this->target_amount * 100));
    }
}
