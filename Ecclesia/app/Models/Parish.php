<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\ParishStatus;
use App\Enums\UserRole;
use Database\Factories\ParishFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Parish extends Model
{
    /** @use HasFactory<ParishFactory> */
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'code',
        'diocese',
        'address',
        'city',
        'commune',
        'region',
        'country',
        'phone',
        'email',
        'logo',
        'status',
        'subscription_amount',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => ParishStatus::class,
            'subscription_amount' => 'integer',
        ];
    }

    /**
     * The faithful linked to this parish.
     *
     * @return HasMany<User, $this>
     */
    public function members(): HasMany
    {
        return $this->hasMany(User::class);
    }

    /**
     * @param  Builder<Parish>  $query
     * @return Builder<Parish>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', ParishStatus::Active->value);
    }

    /**
     * Full-text-ish search across name, code and location fields.
     *
     * @param  Builder<Parish>  $query
     * @return Builder<Parish>
     */
    public function scopeSearch(Builder $query, string $term): Builder
    {
        $like = '%'.$term.'%';

        return $query->where(function (Builder $query) use ($like) {
            $query->where('name', 'like', $like)
                ->orWhere('code', 'like', $like)
                ->orWhere('city', 'like', $like)
                ->orWhere('commune', 'like', $like)
                ->orWhere('region', 'like', $like)
                ->orWhere('diocese', 'like', $like)
                ->orWhere('address', 'like', $like);
        });
    }

    public function isJoinable(): bool
    {
        return $this->status->isJoinable();
    }

    /**
     * The mass schedule for this parish.
     *
     * @return HasMany<MassTime, $this>
     */
    public function massTimes(): HasMany
    {
        return $this->hasMany(MassTime::class)->orderBy('day_of_week')->orderBy('time');
    }

    /**
     * The administrator account attached to this parish (scoped to /admin).
     *
     * @return HasOne<User, $this>
     */
    public function admin(): HasOne
    {
        return $this->hasOne(User::class)->where('role', UserRole::Admin->value);
    }

    /**
     * The annual subscription formatted for display, e.g. "2 000 F CFA".
     */
    public function formattedSubscription(): string
    {
        return number_format((int) $this->subscription_amount, 0, ',', ' ').' F CFA';
    }
}
