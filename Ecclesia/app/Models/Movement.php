<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\UserRole;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Movement extends Model
{
    protected $fillable = [
        'parish_id',
        'name',
        'category',
        'description',
        'logo',
        'meeting_info',
        'is_active',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    /**
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    /**
     * The faithful who joined this movement.
     *
     * @return BelongsToMany<User, $this>
     */
    public function members(): BelongsToMany
    {
        return $this->belongsToMany(User::class)->withTimestamps()->withPivot('joined_at');
    }

    /**
     * The leader account attached to this movement.
     *
     * @return HasOne<User, $this>
     */
    public function admin(): HasOne
    {
        return $this->hasOne(User::class, 'movement_id')->where('role', UserRole::MovementAdmin->value);
    }

    /**
     * @return HasMany<MovementPost, $this>
     */
    public function posts(): HasMany
    {
        return $this->hasMany(MovementPost::class)->latest('published_at');
    }

    /**
     * @return HasMany<MovementDocument, $this>
     */
    public function documents(): HasMany
    {
        return $this->hasMany(MovementDocument::class)->latest();
    }
}
