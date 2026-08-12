<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ParishEvent extends Model
{
    protected $fillable = [
        'parish_id',
        'title',
        'description',
        'starts_at',
        'ends_at',
        'location',
        'image',
        'is_published',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'is_published' => 'boolean',
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
     * @return HasMany<ParishEventRsvp, $this>
     */
    public function rsvps(): HasMany
    {
        return $this->hasMany(ParishEventRsvp::class);
    }
}
