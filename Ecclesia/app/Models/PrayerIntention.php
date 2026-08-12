<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class PrayerIntention extends Model
{
    protected $fillable = [
        'parish_id',
        'user_id',
        'author_name',
        'is_anonymous',
        'intention',
        'prayers_count',
        'is_approved',
    ];

    protected $casts = [
        'is_anonymous' => 'boolean',
        'is_approved' => 'boolean',
        'prayers_count' => 'integer',
    ];

    public function displayName(): string
    {
        return $this->is_anonymous ? 'Anonyme' : ($this->author_name ?: 'Un fidèle');
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
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * The faithful who have prayed for this intention.
     *
     * @return BelongsToMany<User, $this>
     */
    public function prayedBy(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'prayer_intention_user')->withTimestamps();
    }
}
