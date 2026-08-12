<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ParishEventRsvp extends Model
{
    protected $fillable = [
        'parish_event_id',
        'user_id',
    ];

    /**
     * @return BelongsTo<ParishEvent, $this>
     */
    public function event(): BelongsTo
    {
        return $this->belongsTo(ParishEvent::class, 'parish_event_id');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
