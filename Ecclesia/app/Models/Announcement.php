<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\AnnouncementCategory;
use Database\Factories\AnnouncementFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Announcement extends Model
{
    /** @use HasFactory<AnnouncementFactory> */
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'parish_id',
        'category',
        'title',
        'body',
        'image_url',
        'video_url',
        'author_name',
        'author_role',
        'is_pinned',
        'is_important',
        'likes_count',
        'comments_count',
        'published_at',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'category' => AnnouncementCategory::class,
            'is_pinned' => 'boolean',
            'is_important' => 'boolean',
            'likes_count' => 'integer',
            'comments_count' => 'integer',
            'published_at' => 'datetime',
        ];
    }

    /**
     * The parish this announcement belongs to.
     *
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    /**
     * @param  Builder<Announcement>  $query
     * @return Builder<Announcement>
     */
    public function scopeForParish(Builder $query, int $parishId): Builder
    {
        return $query->where('parish_id', $parishId);
    }

    /**
     * Only announcements whose publication date has come.
     *
     * @param  Builder<Announcement>  $query
     * @return Builder<Announcement>
     */
    public function scopePublished(Builder $query): Builder
    {
        return $query->whereNotNull('published_at')->where('published_at', '<=', now());
    }
}
