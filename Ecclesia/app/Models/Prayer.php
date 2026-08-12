<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\PrayerCategory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * A piece of spiritual content (prayer, rosary, novena, litany) authored by
 * super administrators and surfaced in the app's "Vie & Foi" hub.
 */
class Prayer extends Model
{
    protected $fillable = [
        'parish_id',
        'category',
        'title',
        'subtitle',
        'body',
        'reference',
        'image',
        'position',
        'is_published',
    ];

    protected $casts = [
        'category' => PrayerCategory::class,
        'is_published' => 'boolean',
        'position' => 'integer',
    ];

    /**
     * @return BelongsTo<\App\Models\Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }

    /** Common library (null parish) + the given parish's own content. */
    public function scopeVisibleTo(Builder $query, ?int $parishId): Builder
    {
        return $query->where(function (Builder $q) use ($parishId) {
            $q->whereNull('parish_id');
            if ($parishId !== null) {
                $q->orWhere('parish_id', $parishId);
            }
        });
    }

    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('position')->orderBy('title');
    }
}
